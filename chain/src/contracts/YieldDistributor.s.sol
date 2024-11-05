// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {OwnableUpgradeable} from '@openzeppelin-upgradeable/access/OwnableUpgradeable.sol';
import {ERC20VotesUpgradeable} from '@openzeppelin-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol';
import {Checkpoints} from '@openzeppelin/utils/structs/Checkpoints.sol';
import {Bread} from '@bread-token/src/Bread.sol';
import {IYieldDistributor} from 'interfaces/IYieldDistributor.sol';

/**
 * @title Breadchain Yield Distributor
 * @notice Distribute $OBD yield to eligible member projects based on a voted distribution
 * @author Breadchain Collective
 */
contract YieldDistributor is IYieldDistributor, OwnableUpgradeable {
  // --- Registry ---

  /// @notice The address of the $BREAD token contract
  Bread public BREAD;
  /// @notice The address of the `ButteredBread` token contract
  ERC20VotesUpgradeable public BUTTERED_BREAD;

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

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize(
    address _bread,
    address _butteredBread,
    YieldDistributorParams memory __params,
    address[] memory _projects
  ) public initializer enforceParams(__params) {
    if (_bread == address(0) || _butteredBread == address(0)) revert ZeroValue();
    __Ownable_init(msg.sender);

    BREAD = Bread(_bread);
    BUTTERED_BREAD = ERC20VotesUpgradeable(_butteredBread);
    _params = __params;

    uint256 _l = _projects.length;
    projectDistributions = new uint256[](_l);
    projects = new address[](_l);
    for (uint256 i; i < _l; ++i) {
      projects[i] = _projects[i];
    }
  }

  /// @inheritdoc IYieldDistributor
  function getParams() external view returns (YieldDistributorParams memory) {
    return _params;
  }

  /// @inheritdoc IYieldDistributor
  function queueProjectAddition(address _project) external onlyOwner {
    if (_findProject(_project)) revert AlreadyMemberProject();

    for (uint256 i; i < queuedProjectsForAddition.length; ++i) {
      if (queuedProjectsForAddition[i] == _project) {
        revert ProjectAlreadyQueued();
      }
    }
    queuedProjectsForAddition.push(_project);
  }

  /// @inheritdoc IYieldDistributor
  function queueProjectRemoval(address _project) external onlyOwner {
    if (!_findProject(_project)) revert ProjectNotFound();

    for (uint256 i; i < queuedProjectsForRemoval.length; ++i) {
      if (queuedProjectsForRemoval[i] == _project) {
        revert ProjectAlreadyQueued();
      }
    }
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

  /**
   * @notice Returns the current distribution of voting power for projects
   * @return address[] The current eligible member projects
   * @return uint256[] The current distribution of voting power for projects
   */
  function getCurrentVotingDistribution() public view returns (address[] memory, uint256[] memory) {
    return (projects, projectDistributions);
  }

  /**
   * @notice Return the current voting power of a user
   * @param _account Address of the user to return the voting power for
   * @return uint256 The voting power of the user
   */
  function getCurrentVotingPower(address _account) public view returns (uint256) {
    return this.getVotingPowerForPeriod(BREAD, prevCycleStartBlock, _params.lastClaimedBlockNumber, _account)
      + this.getVotingPowerForPeriod(BUTTERED_BREAD, prevCycleStartBlock, _params.lastClaimedBlockNumber, _account);
  }

  /**
   * @notice Get the current accumulated voting power for a user
   * @dev This is the voting power that has been accumulated since the last yield distribution
   * @param _account Address of the user to get the current accumulated voting power for
   * @return uint256 The current accumulated voting power for the user
   */
  function getCurrentAccumulatedVotingPower(address _account) public view returns (uint256) {
    return this.getVotingPowerForPeriod(BUTTERED_BREAD, _params.lastClaimedBlockNumber, block.number, _account)
      + this.getVotingPowerForPeriod(BREAD, _params.lastClaimedBlockNumber, block.number, _account);
  }

  /**
   * @notice Return the voting power for a specified user during a specified period of time
   * @param _start Start time of the period to return the voting power for
   * @param _end End time of the period to return the voting power for
   * @param _account Address of user to return the voting power for
   * @return uint256 Voting power of the specified user at the specified period of time
   */
  function getVotingPowerForPeriod(
    ERC20VotesUpgradeable _sourceContract,
    uint256 _start,
    uint256 _end,
    address _account
  ) external view returns (uint256) {
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

  /**
   * @notice Determine if the yield distribution is available
   * @dev Resolver function required for Powerpool job registration. For more details, see the Powerpool documentation:
   * @dev https://docs.powerpool.finance/powerpool-and-poweragent-network/power-agent/user-guides-and-instructions/i-want-to-automate-my-tasks/job-registration-guide#resolver-job
   * @return bool Flag indicating if the yield is able to be distributed
   * @return bytes Calldata used by the resolver to distribute the yield
   */
  function resolveYieldDistribution() public view returns (bool, bytes memory) {
    uint256 _available_yield = BREAD.balanceOf(address(this)) + BREAD.yieldAccrued();
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

  /**
   * @notice Distribute $BREAD yield to projects based on cast votes
   */
  function distributeYield() public {
    (bool _resolved,) = resolveYieldDistribution();
    if (!_resolved) revert YieldNotResolved();

    BREAD.claimYield(BREAD.yieldAccrued(), address(this));
    prevCycleStartBlock = _params.lastClaimedBlockNumber;
    _params.lastClaimedBlockNumber = block.number;
    uint256 balance = BREAD.balanceOf(address(this));
    uint256 _fixedYield = balance / _params.yieldFixedSplitDivisor;
    uint256 _baseSplit = _fixedYield / projects.length;
    uint256 _votedYield = balance - _fixedYield;

    for (uint256 i; i < projects.length; ++i) {
      uint256 _votedSplit =
        ((projectDistributions[i] * _votedYield * _params.precision) / currentVotes) / _params.precision;
      BREAD.transfer(projects[i], _votedSplit + _baseSplit);
    }

    _updateBreadchainProjects();
    emit YieldDistributed(balance, currentVotes, projectDistributions);

    delete currentVotes;
    projectDistributions = new uint256[](projects.length);
  }

  /**
   * @notice Cast votes for the distribution of $BREAD yield
   * @param _points List of points as integers for each project
   */
  function castVote(uint256[] calldata _points) public {
    uint256 _currentVotingPower = getCurrentVotingPower(msg.sender);
    if (_currentVotingPower < _params.minRequiredVotingPower) revert InsufficientVotingPower();
    _castVote(msg.sender, _points, _currentVotingPower);
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
  function _modifyAddress(bytes32 _param, address _address) internal {
    if (_address == address(0)) revert ZeroValue();

    if (_param == 'bread') {
      BREAD = Bread(_address);
    } else if (_param == 'butteredBread') {
      BUTTERED_BREAD = ERC20VotesUpgradeable(_address);
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

  // --- Modifiers ---

  modifier enforceParams(YieldDistributorParams memory _ydp) {
    if (
      _ydp.precision == 0 || _ydp.minRequiredVotingPower == 0 || _ydp.maxPoints == 0 || _ydp.cycleLength == 0
        || _ydp.yieldFixedSplitDivisor == 0 || _ydp.lastClaimedBlockNumber == 0
    ) revert ZeroValue();
    _;
  }
}
