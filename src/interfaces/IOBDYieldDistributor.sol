// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import {BuildersDollar} from '@bdtoken/BuildersDollar.sol';

/// @title `OBDYieldDistributor` interface
interface IOBDYieldDistributor {
  /// @notice The error emitted when attempting to instantiate a variable with a zero value
  error ZeroValue();
  /// @notice The error emitted when a modifier param is invalid
  error InvalidParam();

  /// @notice The event emitted when an account casts a vote
  event MemberVouched(address indexed account, address[] projects);
  /// @notice The event emitted when yield is distributed
  event YieldDistributed(uint256 yield, address[] projects);

  /// @notice The parameters for the yield distributor
  struct YieldDistributorParams {
    /// @notice The minimum number of blocks between yield distributions
    uint256 cycleLength;
    /// @notice The block number of the last yield distribution
    uint256 lastClaimedBlock;
    /// @notice The minimum number of vouches needed for a project to recieve yield
    uint256 minVouches;
    /// @notice The precision to use for calculations
    uint256 precision;
    /// @notice The block number before the last yield distribution
    uint256 prevCycleStartBlock;
  }

  // --- View Methods ---

  /**
   * @dev token is an implementation of BuildersDollar
   * @return BuildersDollar The address of the $BASE_TOKEN token contract
   */
  function token() external view returns (BuildersDollar);

  /// @return YieldDistributorParams The current params of the YieldDistributor
  function params() external view returns (YieldDistributorParams memory);

  // --- Methods ---

  function vouch(bytes32 projectApprovalAttestation, bytes32 identityAttestation) external;

  function vouch(bytes32 projectApprovalAttestation) external;

  function validateProject(bytes32 approvalAttestation) external returns (bool);

  /**
   * @notice Set param to updated value
   * @param _param name of param to update
   * @param _value new value for param
   */
  function modifyParam(bytes32 _param, uint256 _value) external;

  /**
   * @notice Set param to updated value
   * @param _param name of param to update
   * @param _contract new address for param
   */
  function modifyAddress(bytes32 _param, address _contract) external;

  /**
   * @notice Determine if the yield distribution is available
   * @dev Resolver function required for Powerpool job registration. For more details, see the Powerpool documentation:
   * @dev https://docs.powerpool.finance/powerpool-and-poweragent-network/power-agent/user-guides-and-instructions/i-want-to-automate-my-tasks/job-registration-guide#resolver-job
   * @return bool Flag indicating if the yield is able to be distributed
   * @return bytes Calldata used by the resolver to distribute the yield
   */
  function resolveYieldDistribution() external view returns (bool, bytes memory);

  /**
   * @notice Distribute $OBD yield to projects based on vouches
   * @param _payload Calldata used by the resolver to distribute the yield
   */
  function distributeYield(bytes calldata _payload) external;
}