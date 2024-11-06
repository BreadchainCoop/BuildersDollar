// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import {ERC20} from '@openzeppelin/token/ERC20/ERC20.sol';

/// @title `OBDYieldDistributor` interface
interface IOBDYieldDistributor {
  /// @notice The error emitted when attempting to add a project that is already in the `projects` array
  error AlreadyMemberProject();
  /// @notice The error emitted when attempting to instantiate a variable with a zero value
  error ZeroValue();
  /// @notice The error emitted when attempting to add or remove a project that is already queued for addition or removal
  error ProjectAlreadyQueued();
  /// @notice The error emitted when attempting to remove a project that is not in the `projects` array
  error ProjectNotFound();
  /// @notice The error emitted when attempting to distribute yield when access conditions are not met
  error YieldNotResolved();
  /// @notice The error emitted when a modifier param is invalid
  error InvalidParam();

  /// @notice The event emitted when an account casts a vote
  event MemberVouched(address indexed account, address[] projects);
  /// @notice The event emitted when a project is added as eligibile for yield distribution
  event ProjectAdded(address project);
  /// @notice The event emitted when a project is removed as eligibile for yield distribution
  event ProjectRemoved(address project);
  /// @notice The event emitted when yield is distributed
  event YieldDistributed(uint256 yield, uint256 totalVotes, uint256[] projectDistributions);

  /// @notice The parameters for the yield distributor
  struct YieldDistributorParams {
    /// @notice The total number of votes cast in the current cycle
    uint256 currentVouches;
    /// @notice The minimum number of blocks between yield distributions
    uint256 cycleLength;
    /// @notice The block number of the last yield distribution
    uint256 lastClaimedBlock;
    /// @notice The maximum number of points a voter can allocate to a project
    uint256 maxVouches;
    /// @notice The precision to use for calculations
    uint256 precision;
    /// @notice The block number before the last yield distribution
    uint256 prevCycleStartBlock;
    /// @notice Amount of the yield is divided equally among projects
    uint256 yieldFixedSplitDivisor;
  }

  // --- View Methods ---

  /**
   * @dev BASE_TOKEN is an implementation of BREAD
   * @return ERC20 The address of the $BASE_TOKEN token contract
   */
  function BASE_TOKEN() external view returns (ERC20);

  /// @return uint256 The last block number in which a specified account cast a vote
  function accountLastVoted(address) external view returns (uint256);

  /// @return YieldDistributorParams The current params of the YieldDistributor
  function params() external view returns (YieldDistributorParams memory);

  /**
   * @return address[] The current eligible member projects
   * @return uint256[] The current distribution of voting power for projects
   */
  function getCurrentVotingDistribution() external view returns (address[] memory, uint256[] memory);

  // --- Methods ---

  /// @notice Cast vouch for the distribution of $BREAD yield
  function vouch() external;

  /**
   * @notice Queue a new project to be added to the project list
   * @param _project Project to be added to the project list
   */
  function queueProjectAddition(address _project) external;

  /**
   * @notice Queue an existing project to be removed from the project list
   * @param _project Project to be removed from the project list
   */
  function queueProjectRemoval(address _project) external;

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

  /// @notice Distribute $OBD yield to projects based on vouches
  function distributeYield() external;
}