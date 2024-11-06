// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import {OwnableUpgradeable} from '@oz-upgradeable/access/OwnableUpgradeable.sol';
import {BuildersDollar} from '@bdtoken/BuildersDollar.sol';
import {IOBDYieldDistributor} from 'interfaces/IOBDYieldDistributor.sol';
import {ProjectValidator} from 'contracts/ProjectValidator.sol';

/**
 * @title OBD Yield Distributor
 * @notice Distribute $OBD yield to eligible member currentProjects based on a voted distribution
 * @author Breadchain Collective
 */
contract OBDYieldDistributor is OwnableUpgradeable, IOBDYieldDistributor {
  // --- Registry ---

  /// @inheritdoc IOBDYieldDistributor
  BuildersDollar public token;
  /// @inheritdoc IOBDYieldDistributor
  ProjectValidator public projectValidator;

  // --- Data ---

  /// @notice IOBDYieldDistributor
  YieldDistributorParams internal _params;

  /// @notice Array of currentProjects eligible for yield distribution
  address[] public currentProjects;

  // --- Initializer ---

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize(address _baseToken, address _projectValidator, YieldDistributorParams memory __params)
    public
    initializer
    enforceParams(__params)
    noZeroAddr(_baseToken)
  {
    __Ownable_init(msg.sender);

    token = BuildersDollar(_baseToken);
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
  function vouch(bytes32 _projectAttestation) external {
    // TODO function validateExistingOPVoter
    validateProject(_projectAttestation);
    _vouch(_projectAttestation);
  }

  /// @inheritdoc IOBDYieldDistributor
  function vouch(bytes32 _projectAttestation, bytes32 idAttestation) external {
    // TODO function validateNewOPVoter
    validateProject(_projectAttestation);
    _vouch(_projectAttestation);
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
    if (block.number > _params.lastClaimedBlock + _params.cycleLength) {
      uint256 _l = currentProjects.length;
      uint256 _currYield = (token.balanceOf(address(this)) + token.yieldAccrued()) / _l;

      if (_l > 0 && _currYield >= _l) {
        uint256 _yieldPerProject = _currYield / _l;
        _b = true;
        _data = abi.encodeWithSelector(IOBDYieldDistributor.distributeYield.selector, abi.encode(_yieldPerProject));
      }
    }
  }

  /// @inheritdoc IOBDYieldDistributor
  function distributeYield(bytes calldata _payload) public {
    (uint256 _yieldPerProject, uint256 _l) = abi.decode(_payload, (uint256, uint256));
    token.claimYield(token.yieldAccrued());

    _params.prevCycleStartBlock = _params.lastClaimedBlock;
    _params.lastClaimedBlock = block.number;

    for (uint256 i; i < _l; ++i) {
      token.transfer(currentProjects[i], _yieldPerProject);
    }
    emit YieldDistributed(_yieldPerProject, currentProjects);
  }

  // --- Internal Utilities ---

  /// @notice Internal function for vouching for a project
  function _vouch(address _delegate, address _project) internal {
    // TODO: keep track of vouches
  }

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
