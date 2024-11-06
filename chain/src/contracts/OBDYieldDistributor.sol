// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import {OwnableUpgradeable} from '@oz-upgradeable/access/OwnableUpgradeable.sol';
import {BuildersDollar} from '@bdtoken/BuildersDollar.sol';
import {IOBDYieldDistributor} from 'interfaces/IOBDYieldDistributor.sol';
/**
 * @title OBD Yield Distributor
 * @notice Distribute $OBD yield to eligible member projects based on a voted distribution
 * @author Breadchain Collective
 */

contract OBDYieldDistributor is OwnableUpgradeable, IOBDYieldDistributor {
  // --- Registry ---

  /// @inheritdoc IOBDYieldDistributor
  BuildersDollar public BASE_TOKEN;

  // --- Data ---

  /// @notice IOBDYieldDistributor
  YieldDistributorParams internal _params;

  /// @notice Array of projects eligible for yield distribution
  address[] public projects;
  /// @notice Array of projects queued for addition to the next cycle
  address[] public queuedProjectsForAddition;
  /// @notice Array of projects queued for removal from the next cycle
  address[] public queuedProjectsForRemoval;
  /// @notice The voting power allocated to projects by voters in the current cycle
  uint256[] public projectDistributions;

  /// @inheritdoc IOBDYieldDistributor
  mapping(address => uint256) public accountLastVoted;
  /// @notice The voting power allocated to projects by voters in the current cycle
  mapping(address => uint256[]) internal _voterDistributions;

  // --- Initializer ---

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize(address _baseToken, YieldDistributorParams memory __params, address[] memory _initialProjects)
    public
    initializer
    enforceParams(__params)
    noZeroAddr(_baseToken)
  {
    __Ownable_init(msg.sender);

    BASE_TOKEN = BuildersDollar(_baseToken);
    _params = __params;

    uint256 _l = _initialProjects.length;
    projectDistributions = new uint256[](_l);
    projects = new address[](_l);
    for (uint256 i; i < _l; ++i) {
      projects[i] = _initialProjects[i];
    }
  }

  // --- View Methods ---

  /// @inheritdoc IOBDYieldDistributor
  function params() external view returns (YieldDistributorParams memory) {
    return _params;
  }

  /// @inheritdoc IOBDYieldDistributor
  function getCurrentVotingDistribution() external view returns (address[] memory, uint256[] memory) {
    return (projects, projectDistributions);
  }

  // --- External Methods ---

  /// @inheritdoc IOBDYieldDistributor
  function vouch() external {
    _vouch(msg.sender);
  }

  /// @inheritdoc IOBDYieldDistributor
  function queueProjectAddition(address _project) external onlyOwner {
    if (_isListed(_project, projects)) revert AlreadyMemberProject();
    if (_isListed(_project, queuedProjectsForAddition)) revert ProjectAlreadyQueued();
    queuedProjectsForAddition.push(_project);
  }

  /// @inheritdoc IOBDYieldDistributor
  function queueProjectRemoval(address _project) external onlyOwner {
    if (!_isListed(_project, projects)) revert ProjectNotFound();
    if (_isListed(_project, queuedProjectsForRemoval)) revert ProjectAlreadyQueued();
    queuedProjectsForRemoval.push(_project);
  }

  /// @inheritdoc IOBDYieldDistributor
  function modifyParam(bytes32 _param, uint256 _value) external onlyOwner {
    if (_value == 0) revert ZeroValue();
    _modifyParam(_param, _value);
  }

  /// @inheritdoc IOBDYieldDistributor
  function modifyAddress(bytes32 _param, address _contract) external onlyOwner noZeroAddr(_contract) {
    _modifyAddress(_param, _contract);
  }

  // --- Public Methods ---

  /// @inheritdoc IOBDYieldDistributor
  function resolveYieldDistribution() public view returns (bool _b, bytes memory _data) {
    if (_params.currentVouches > 0 && block.number > _params.lastClaimedBlock + _params.cycleLength) {
      uint256 _currentYield =
        (BASE_TOKEN.balanceOf(address(this)) + BASE_TOKEN.yieldAccrued()) / _params.yieldFixedSplitDivisor;

      if (_currentYield >= projects.length) {
        _b = true;
        _data = abi.encodePacked(IOBDYieldDistributor.distributeYield.selector);
      }
    }
  }

  /// @inheritdoc IOBDYieldDistributor
  function distributeYield() public {
    (bool _resolved,) = resolveYieldDistribution();
    if (!_resolved) revert YieldNotResolved();

    BASE_TOKEN.claimYield(BASE_TOKEN.yieldAccrued());
    _params.prevCycleStartBlock = _params.lastClaimedBlock;
    _params.lastClaimedBlock = block.number;
    uint256 balance = BASE_TOKEN.balanceOf(address(this));
    uint256 _fixedYield = balance / _params.yieldFixedSplitDivisor;
    uint256 _baseSplit = _fixedYield / projects.length;
    uint256 _votedYield = balance - _fixedYield;

    for (uint256 i; i < projects.length; ++i) {
      uint256 _votedSplit =
        ((projectDistributions[i] * _votedYield * _params.precision) / _params.currentVouches) / _params.precision;
      BASE_TOKEN.transfer(projects[i], _votedSplit + _baseSplit);
    }

    _updateBreadchainProjects();
    emit YieldDistributed(balance, _params.currentVouches, projectDistributions);

    delete _params.currentVouches;
    projectDistributions = new uint256[](projects.length);
  }

  // --- Internal Utilities ---

  function _vouch(address _delegate) internal {}

  /// @notice Internal function for updating the project list
  function _updateBreadchainProjects() internal {
    for (uint256 i; i < queuedProjectsForAddition.length; ++i) {
      address _project = queuedProjectsForAddition[i];
      projects.push(_project);
      emit ProjectAdded(_project);
    }
    address[] memory _prevProjects = projects;
    delete projects;

    uint256 _l = _prevProjects.length;
    for (uint256 i; i < _l; ++i) {
      address _project = _prevProjects[i];
      if (_isListed(_project, queuedProjectsForRemoval)) emit ProjectRemoved(_project);
      else projects.push(_project);
    }
    delete queuedProjectsForAddition;
    delete queuedProjectsForRemoval;
  }

  /// @notice see IOBDYieldDistributor
  function _modifyParam(bytes32 _param, uint256 _value) internal {
    if (_param == 'cycleLength') _params.cycleLength = _value;
    else if (_param == 'maxVouches') _params.maxVouches = _value;
    else if (_param == 'yieldFixedSplitDivisor') _params.yieldFixedSplitDivisor = _value;
    else revert InvalidParam();
  }

  /// @notice see IOBDYieldDistributor
  function _modifyAddress(bytes32 _param, address _contract) internal {
    if (_param == 'baseToken') BASE_TOKEN = BuildersDollar(_contract);
    else revert InvalidParam();
  }

  /// @notice Internal function for checking if a project is in an array
  function _isListed(address _project, address[] memory _projects) internal pure returns (bool _b) {
    uint256 _l = _projects.length;
    for (uint256 i; i < _l; ++i) {
      if (_projects[i] == _project) {
        _b = true;
      }
    }
  }

  // --- Modifiers ---

  /// @notice Modifier to enforce that address is not zero
  modifier noZeroAddr(address _addr) {
    if (_addr == address(0)) revert ZeroValue();
    _;
  }

  /// @notice Modifier to enforce the parameters for the yield distributor
  modifier enforceParams(YieldDistributorParams memory _ydp) {
    if (
      _ydp.precision == 0 || _ydp.maxVouches == 0 || _ydp.cycleLength == 0 || _ydp.yieldFixedSplitDivisor == 0
        || _ydp.lastClaimedBlock == 0
    ) revert ZeroValue();
    if (_ydp.currentVouches != 0 || _ydp.prevCycleStartBlock != 0) revert InvalidParam();
    _;
  }
}
