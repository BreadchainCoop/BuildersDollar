// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {OwnableUpgradeable} from '@openzeppelin-upgradeable/access/OwnableUpgradeable.sol';
import {Checkpoints} from '@openzeppelin/utils/structs/Checkpoints.sol';
import {ERC20Votes} from '@openzeppelin/token/ERC20/extensions/ERC20Votes.sol';
import {Bread} from '@bread-token/src/Bread.sol';
import {IYieldDistributor} from 'interfaces/IYieldDistributor.sol';

/**
 * @title Breadchain Yield Distributor
 * @notice Distribute $OBD yield to eligible member projects based on a voted distribution
 * @author Breadchain Collective
 */
contract YieldDistributor is OwnableUpgradeable, IYieldDistributor {
  // --- Registry ---

  /**
   * @notice The address of the $BASE_TOKEN token contract
   * @dev BASE_TOKEN is an implementation of BREAD
   */
  Bread public BASE_TOKEN;
  /// @notice The address of the $REWARD_TOKEN token contract
  ERC20Votes public REWARD_TOKEN;

  // --- Params ---

  /// @notice The parameters for the yield distributor
  YieldDistributorParams internal _params;

  // --- Data ---

  /// @inheritdoc IYieldDistributor
  uint256 public currentVotes;
  /// @inheritdoc IYieldDistributor
  uint256 public prevCycleStartBlock;

  /// @notice Array of projects eligible for yield distribution
  address[] public projects;
  /// @notice Array of projects queued for addition to the next cycle
  address[] public queuedProjectsForAddition;
  /// @notice Array of projects queued for removal from the next cycle
  address[] public queuedProjectsForRemoval;
  /// @notice The voting power allocated to projects by voters in the current cycle
  uint256[] public projectDistributions;

  /// @inheritdoc IYieldDistributor
  mapping(address => uint256) public accountLastVoted;
  /// @notice The voting power allocated to projects by voters in the current cycle
  mapping(address => uint256[]) internal _voterDistributions;

  // --- Initializer ---

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize(
    address _baseToken,
    address _rewardToken,
    YieldDistributorParams memory __params,
    address[] memory _projects
  ) public initializer enforceParams(__params) {
    if (_baseToken == address(0) || _rewardToken == address(0)) revert ZeroValue();
    __Ownable_init(msg.sender);

    BASE_TOKEN = Bread(_baseToken);
    REWARD_TOKEN = ERC20Votes(_rewardToken);
    _params = __params;

    uint256 _l = _projects.length;
    projectDistributions = new uint256[](_l);
    projects = new address[](_l);
    for (uint256 i; i < _l; ++i) {
      projects[i] = _projects[i];
    }
  }

  // --- View Methods ---

  /// @inheritdoc IYieldDistributor
  function getParams() external view returns (YieldDistributorParams memory) {
    return _params;
  }

  /// @inheritdoc IYieldDistributor
  function getCurrentVotingDistribution() external view returns (address[] memory, uint256[] memory) {
    return (projects, projectDistributions);
  }

  // --- External Methods ---

  /// @inheritdoc IYieldDistributor
  function castVote(uint256[] calldata _points) external {
    uint256 _currentVotingPower = getCurrentVotingPower(msg.sender);
    if (_currentVotingPower < _params.minRequiredVotingPower) revert InsufficientVotingPower();
    _castVote(msg.sender, _points, _currentVotingPower);
  }

  /// @inheritdoc IYieldDistributor
  function queueProjectAddition(address _project) external onlyOwner {
    if (_findProject(_project)) revert AlreadyMemberProject();
    if (_isQueued(_project, queuedProjectsForAddition)) revert ProjectAlreadyQueued();
    queuedProjectsForAddition.push(_project);
  }

  /// @inheritdoc IYieldDistributor
  function queueProjectRemoval(address _project) external onlyOwner {
    if (!_findProject(_project)) revert ProjectNotFound();
    if (_isQueued(_project, queuedProjectsForRemoval)) revert ProjectAlreadyQueued();
    queuedProjectsForRemoval.push(_project);
  }

  /// @inheritdoc IYieldDistributor
  function modifyParam(bytes32 _param, uint256 _value) external onlyOwner {
    _modifyParam(_param, _value);
  }

  /// @inheritdoc IYieldDistributor
  function modifyAddress(bytes32 _param, address _address) external onlyOwner {
    _modifyAddress(_param, _address);
  }

  // --- Public Methods ---

  /// @inheritdoc IYieldDistributor
  function getVotingPowerForPeriod(address _sourceContract, uint256 _start, uint256 _end, address _account)
    public
    view
    returns (uint256)
  {
    return _getVotingPowerForPeriod(ERC20Votes(_sourceContract), _start, _end, _account);
  }

  /// @inheritdoc IYieldDistributor
  function getCurrentVotingPower(address _account) public view returns (uint256) {
    return getVotingPowerForPeriod(address(BASE_TOKEN), prevCycleStartBlock, _params.lastClaimedBlockNumber, _account)
      + _getVotingPowerForPeriod(REWARD_TOKEN, prevCycleStartBlock, _params.lastClaimedBlockNumber, _account);
  }

  /// @inheritdoc IYieldDistributor
  function getCurrentAccumulatedVotingPower(address _account) public view returns (uint256) {
    return _getVotingPowerForPeriod(REWARD_TOKEN, _params.lastClaimedBlockNumber, block.number, _account)
      + getVotingPowerForPeriod(address(BASE_TOKEN), _params.lastClaimedBlockNumber, block.number, _account);
  }

  /// @inheritdoc IYieldDistributor
  function resolveYieldDistribution() public view returns (bool, bytes memory) {
    uint256 _available_yield = BASE_TOKEN.balanceOf(address(this)) + BASE_TOKEN.yieldAccrued();
    if (
      /// No votes were cast
      /// Already claimed this cycle
      currentVotes == 0 || block.number < _params.lastClaimedBlockNumber + _params.cycleLength
        || _available_yield / _params.yieldFixedSplitDivisor < projects.length
    ) {
      /// Yield is insufficient to distribute
      return (false, new bytes(0));
    } else {
      return (true, abi.encodePacked(this.distributeYield.selector));
    }
  }

  /// @inheritdoc IYieldDistributor
  function distributeYield() public {
    (bool _resolved,) = resolveYieldDistribution();
    if (!_resolved) revert YieldNotResolved();

    BASE_TOKEN.claimYield(BASE_TOKEN.yieldAccrued(), address(this));
    prevCycleStartBlock = _params.lastClaimedBlockNumber;
    _params.lastClaimedBlockNumber = block.number;
    uint256 balance = BASE_TOKEN.balanceOf(address(this));
    uint256 _fixedYield = balance / _params.yieldFixedSplitDivisor;
    uint256 _baseSplit = _fixedYield / projects.length;
    uint256 _votedYield = balance - _fixedYield;

    for (uint256 i; i < projects.length; ++i) {
      uint256 _votedSplit =
        ((projectDistributions[i] * _votedYield * _params.precision) / currentVotes) / _params.precision;
      BASE_TOKEN.transfer(projects[i], _votedSplit + _baseSplit);
    }

    _updateBreadchainProjects();
    emit YieldDistributed(balance, currentVotes, projectDistributions);

    delete currentVotes;
    projectDistributions = new uint256[](projects.length);
  }

  // --- Internal Utilities ---

  /**
   * @notice Internal function for casting votes for a specified user
   * @param _account Address of user to cast votes for
   * @param _points Basis points for calculating the amount of votes cast
   * @param _votingPower Amount of voting power being cast
   */
  function _castVote(address _account, uint256[] calldata _points, uint256 _votingPower) internal {
    if (_points.length != projects.length) revert IncorrectProjectCount();

    uint256 _totalPoints;
    for (uint256 i; i < _points.length; ++i) {
      if (_points[i] > _params.maxPoints) revert ExceedsMaxPoints();
      _totalPoints += _points[i];
    }
    if (_totalPoints == 0) revert ZeroVotePoints();

    bool _hasVotedInCycle = accountLastVoted[_account] > _params.lastClaimedBlockNumber;
    uint256[] storage __voterDistributions = _voterDistributions[_account];
    if (!_hasVotedInCycle) {
      delete _voterDistributions[_account];
      currentVotes += _votingPower;
    }

    for (uint256 i; i < _points.length; ++i) {
      if (!_hasVotedInCycle) __voterDistributions.push(0);
      else projectDistributions[i] -= __voterDistributions[i];

      uint256 _currentProjectDistribution =
        ((_points[i] * _votingPower * _params.precision) / _totalPoints) / _params.precision;
      projectDistributions[i] += _currentProjectDistribution;
      __voterDistributions[i] = _currentProjectDistribution;
    }

    accountLastVoted[_account] = block.number;

    emit BreadHolderVoted(_account, _points, projects);
  }

  /// @notice Internal function for updating the project list
  function _updateBreadchainProjects() internal {
    for (uint256 i; i < queuedProjectsForAddition.length; ++i) {
      address _project = queuedProjectsForAddition[i];
      projects.push(_project);
      emit ProjectAdded(_project);
    }

    address[] memory _oldProjects = projects;
    delete projects;

    for (uint256 i; i < _oldProjects.length; ++i) {
      address _project = _oldProjects[i];
      bool _remove;

      for (uint256 j; j < queuedProjectsForRemoval.length; ++j) {
        if (_project == queuedProjectsForRemoval[j]) {
          _remove = true;
          emit ProjectRemoved(_project);
          break;
        }
      }
      if (!_remove) {
        projects.push(_project);
      }
    }
    delete queuedProjectsForAddition;
    delete queuedProjectsForRemoval;
  }

  /// @notice IYieldDistributor
  function _getVotingPowerForPeriod(ERC20Votes _sourceContract, uint256 _start, uint256 _end, address _account)
    internal
    view
    returns (uint256)
  {
    if (_start >= _end) revert StartMustBeBeforeEnd();
    if (_end > block.number) revert EndAfterCurrentBlock();

    /// Initialized as the checkpoint count, but later used to track checkpoint index
    uint32 _numCheckpoints = _sourceContract.numCheckpoints(_account);
    if (_numCheckpoints == 0) return 0;

    /// No voting power if the first checkpoint is after the end of the interval
    Checkpoints.Checkpoint208 memory _currentCheckpoint = _sourceContract.checkpoints(_account, 0);
    if (_currentCheckpoint._key > _end) return 0;

    uint256 _totalVotingPower;

    for (uint32 i = _numCheckpoints; i > 0;) {
      _currentCheckpoint = _sourceContract.checkpoints(_account, --i);

      if (_currentCheckpoint._key <= _end) {
        uint48 _effectiveStart = _currentCheckpoint._key < _start ? uint48(_start) : _currentCheckpoint._key;
        _totalVotingPower += _currentCheckpoint._value * (_end - _effectiveStart);

        if (_effectiveStart == _start) break;
        _end = _currentCheckpoint._key;
      }
    }
    return _totalVotingPower;
  }

  /// @notice see IYieldDistributor
  function _modifyParam(bytes32 _param, uint256 _value) internal {
    if (_value == 0) revert ZeroValue();

    if (_param == 'params.minRequiredVotingPower') {
      _params.minRequiredVotingPower = _value;
    } else if (_param == 'params.maxPoints') {
      _params.maxPoints = _value;
    } else if (_param == 'params.cycleLength') {
      _params.cycleLength = _value;
    } else if (_param == 'params.yieldFixedSplitDivisor') {
      _params.yieldFixedSplitDivisor = _value;
    } else {
      revert InvalidParam();
    }
  }

  /// @notice see IYieldDistributor
  function _modifyAddress(bytes32 _param, address _contract) internal {
    if (_contract == address(0)) revert ZeroValue();

    if (_param == 'baseToken') {
      BASE_TOKEN = Bread(_contract);
    } else if (_param == 'rewardToken') {
      REWARD_TOKEN = ERC20Votes(_contract);
    } else {
      revert InvalidParam();
    }
  }

  /// @notice Internal function for finding a project in the project list
  function _findProject(address _project) internal view returns (bool _b) {
    for (uint256 i; i < projects.length; ++i) {
      if (projects[i] == _project) {
        _b = true;
      }
    }
  }

  /// @notice Internal function for checking if a project is queued
  function _isQueued(address _project, address[] memory _queuedProjects) internal pure returns (bool _b) {
    for (uint256 i; i < _queuedProjects.length; ++i) {
      if (_queuedProjects[i] == _project) {
        _b = true;
      }
    }
  }

  // --- Modifiers ---

  /// @notice Modifier to enforce the parameters for the yield distributor
  modifier enforceParams(YieldDistributorParams memory _ydp) {
    if (
      _ydp.precision == 0 || _ydp.minRequiredVotingPower == 0 || _ydp.maxPoints == 0 || _ydp.cycleLength == 0
        || _ydp.yieldFixedSplitDivisor == 0 || _ydp.lastClaimedBlockNumber == 0
    ) revert ZeroValue();
    _;
  }
}
