// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import {ERC20VotesUpgradeable} from '@openzeppelin-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol';

/// @title `YieldDistributor` interface
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

  /// @return uint256 The total number of votes cast in the current cycle
  function currentVotes() external view returns (uint256);

  /// @return uint256 The block number before the last yield distribution
  function prevCycleStartBlock() external view returns (uint256);

  /// @return uint256 The last block number in which a specified account cast a vote
  function accountLastVoted(address) external view returns (uint256);

  /// @return YieldDistributorParams The current params of the YieldDistributor
  function getParams() external view returns (YieldDistributorParams memory);

  /**
   * @return address[] The current eligible member projects
   * @return uint256[] The current distribution of voting power for projects
   */
  function getCurrentVotingDistribution() external view returns (address[] memory, uint256[] memory);

  // --- Methods ---

  /**
   * @notice Cast votes for the distribution of $BREAD yield
   * @param _points List of points as integers for each project
   */
  function castVote(uint256[] calldata _points) external;

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

  /**
   * @notice Return the current voting power of a user
   * @param _account Address of the user to return the voting power for
   * @return uint256 The voting power of the user
   */
  function getCurrentVotingPower(address _account) external view returns (uint256);

  /**
   * @notice Get the current accumulated voting power for a user
   * @dev This is the voting power that has been accumulated since the last yield distribution
   * @param _account Address of the user to get the current accumulated voting power for
   * @return uint256 The current accumulated voting power for the user
   */
  function getCurrentAccumulatedVotingPower(address _account) external view returns (uint256);

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
  ) external view returns (uint256);

  /**
   * @notice Determine if the yield distribution is available
   * @dev Resolver function required for Powerpool job registration. For more details, see the Powerpool documentation:
   * @dev https://docs.powerpool.finance/powerpool-and-poweragent-network/power-agent/user-guides-and-instructions/i-want-to-automate-my-tasks/job-registration-guide#resolver-job
   * @return bool Flag indicating if the yield is able to be distributed
   * @return bytes Calldata used by the resolver to distribute the yield
   */
  function resolveYieldDistribution() external view returns (bool, bytes memory);

  /// @notice Distribute $BREAD yield to projects based on cast votes
  function distributeYield() external;
}
