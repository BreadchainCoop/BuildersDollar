// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import {OwnableUpgradeable} from '@oz-upgradeable/access/OwnableUpgradeable.sol';
import {BuildersDollar} from '@bdtoken/BuildersDollar.sol';
import {IOBDYieldDistributor} from 'interfaces/IOBDYieldDistributor.sol';
import {ProjectManager} from 'contracts/ProjectManager.sol';

/**
 * @title OBD Yield Distributor
 * @notice Distribute $OBD yield to eligible member currentProjects based on a voted distribution
 * @author Breadchain Collective
 */
contract OBDYieldDistributor is ProjectManager, OwnableUpgradeable, IOBDYieldDistributor {
  // --- Registry ---

  /// @inheritdoc IOBDYieldDistributor
  BuildersDollar public token;
  /// @notice The precision to use for calculations
  uint256 constant PRECISION = 1e18;

  // --- Data ---

  /// @notice IOBDYieldDistributor
  YieldDistributorParams internal _params;

  // --- Initializer ---

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize(
    address _token,
    address _eas,
    uint256 _seasonDuration,
    uint64 _currentSeasonExpiry,
    YieldDistributorParams memory __params,
    address[] memory _OPattestors
  ) public initializer enforceParams(__params) noZeroAddr(_token) {
    __Ownable_init(msg.sender);
    __ProjectManager_init(_eas, _OPattestors, _seasonDuration, _currentSeasonExpiry);

    token = BuildersDollar(_token);
    _params = __params;
    _params.prevCycleStartBlock = 0;
  }

  // --- View Methods ---

  /// @inheritdoc IOBDYieldDistributor
  function params() external view returns (YieldDistributorParams memory) {
    return _params;
  }

  // --- External Methods ---

  /// @inheritdoc IOBDYieldDistributor
  function vouch(bytes32 projectApprovalAttestation, bytes32 identityAttestation)
    public
    override(ProjectManager, IOBDYieldDistributor)
  {
    super.vouch(projectApprovalAttestation, identityAttestation);
  }

  /// @inheritdoc IOBDYieldDistributor
  function vouch(bytes32 projectApprovalAttestation) public override(ProjectManager, IOBDYieldDistributor) {
    super.vouch(projectApprovalAttestation);
  }

  /// @inheritdoc IOBDYieldDistributor
  function validateProject(bytes32 approvalAttestation)
    public
    override(ProjectManager, IOBDYieldDistributor)
    returns (bool)
  {
    return super.validateProject(approvalAttestation);
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
  function distributeYield() public {
    uint256 _yield = token.yieldAccrued();
    token.claimYield(_yield);

    uint256 _l = currentProjects.length;
    uint256 _yieldPerProject;
    for (uint256 i; i < _l; ++i) {
      address _project = currentProjects[i];
      if (projectToVouches[_project] > 3) {
        if (projectToExpiry[_project] > block.timestamp) {
          token.transfer(_project, _yieldPerProject);
        } else {
          super.ejectProject(_project);
        }
      }
      emit YieldDistributed(_yieldPerProject, currentProjects);
    }
  }

  // --- Internal Utilities ---

  /// @notice see IOBDYieldDistributor
  function _modifyParam(bytes32 _param, uint256 _value) internal {
    if (_param == 'cycleLength') _params.cycleLength = _value;
    else if (_param == 'minVouches') _params.minVouches = _value;
    else revert InvalidParam();
  }

  /// @notice see IOBDYieldDistributor
  function _modifyAddress(bytes32 _param, address _contract) internal {
    if (_param == 'baseToken') token = BuildersDollar(_contract);
    else revert InvalidParam();
  }

  // --- Modifiers ---

  /// @notice Modifier to enforce that address is not zero
  modifier noZeroAddr(address _addr) {
    if (_addr == address(0)) revert ZeroValue();
    _;
  }

  /// @notice Modifier to enforce the parameters for the yield distributor
  modifier enforceParams(YieldDistributorParams memory _ydp) {
    if (_ydp.precision == 0 || _ydp.minVouches == 0 || _ydp.cycleLength == 0 || _ydp.lastClaimedBlock == 0) {
      revert ZeroValue();
    }
    _;
  }
}
