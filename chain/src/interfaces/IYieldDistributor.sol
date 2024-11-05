// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

/**
 * @title `YieldDistributor` interface
 */
interface IYieldDistributor {
  /// @notice The error emitted when attempting to add a project that is already in the `projects` array
  error AlreadyMemberProject();
  /// @notice The error emitted when a user attempts to vote without the minimum required voting power
  error InsufficientVotingPower();
  /// @notice The error emitted when attempting to calculate voting power for a period that has not yet ended
  error EndAfterCurrentBlock();
  /// @notice The error emitted when attempting to vote with a point value greater than `pointsMax`
  error ExceedsMaxPoints();
  /// @notice The error emitted when attempting to vote with an incorrect number of projects
  error IncorrectProjectCount();
  /// @notice The error emitted when attempting to instantiate a variable with a zero value
  error ZeroValue();
  /// @notice The error emitted when attempting to add or remove a project that is already queued for addition or removal
  error ProjectAlreadyQueued();
  /// @notice The error emitted when attempting to remove a project that is not in the `projects` array
  error ProjectNotFound();
  /// @notice The error emitted when attempting to calculate voting power for a period with a start block greater than the end block
  error StartMustBeBeforeEnd();
  /// @notice The error emitted when attempting to distribute yield when access conditions are not met
  error YieldNotResolved();
  /// @notice The error emitted if a user with zero points attempts to cast votes
  error ZeroVotePoints();
  /// @notice The error emitted when a modifier param is invalid
  error InvalidParam();

  /// @notice The event emitted when an account casts a vote
  event BreadHolderVoted(address indexed account, uint256[] points, address[] projects);
  /// @notice The event emitted when a project is added as eligibile for yield distribution
  event ProjectAdded(address project);
  /// @notice The event emitted when a project is removed as eligibile for yield distribution
  event ProjectRemoved(address project);
  /// @notice The event emitted when yield is distributed
  event YieldDistributed(uint256 yield, uint256 totalVotes, uint256[] projectDistributions);

  struct YieldDistributorParams {
    /// @notice The precision to use for calculations
    uint256 precision;
    /// @notice The minimum required voting power participants must have to cast a vote
    uint256 minRequiredVotingPower;
    /// @notice The maximum number of points a voter can allocate to a project
    uint256 maxPoints;
    /// @notice The minimum number of blocks between yield distributions
    uint256 cycleLength;
    /// @notice Amount of the yield is divided equally among projects
    uint256 yieldFixedSplitDivisor;
    /// @notice The block number of the last yield distribution
    uint256 lastClaimedBlockNumber;
  }

  // --- View Methods ---

  /// @notice The total number of votes cast in the current cycle
  function currentVotes() external view returns (uint256);

  /// @notice The block number before the last yield distribution
  function prevCycleStartBlock() external view returns (uint256);

  /// @notice The last block number in which a specified account cast a vote
  function accountLastVoted(address) external view returns (uint256);

  /// @notice Returns the current params of the YieldDistributor
  function getParams() external view returns (YieldDistributorParams memory);

  // --- Methods ---

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
   * @param _address new address for param
   */
  function modifyAddress(bytes32 _param, address _address) external;
}
