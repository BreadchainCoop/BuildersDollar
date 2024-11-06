// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import {Initializable} from '@oz-upgradeable/proxy/utils/Initializable.sol';
import 'interfaces/IEAS.sol';

contract ProjectManager is Initializable {
  IEAS public eas;
  address[] public optimismFoundationAttestors;

  uint256 public SEASON_DURATION;
  uint256 public currentSeasonExpiry;
  uint256 public minRequiredVouches;

  address[] public currentProjects;
  mapping(address => bool) public eligibleVoter; // Tracks both eligibility and if they have vouched
  mapping(address => uint256) public projectToExpiry;
  mapping(bytes32 => address) public eligibleProject;

  bytes32 private constant GRANTEE_HASH = keccak256(bytes('Grantee'));
  bytes32 private constant APPLICATION_APPROVED_HASH = keccak256(bytes('Application Approved'));

  event ProjectValidated(bytes32 indexed approvalAttestation, address indexed recipient);
  event VoterValidated(address indexed claimer, uint256 indexed farcasterID);

  function initialize(
    address _easAddress,
    address[] memory _optimismFoundationAttestors,
    uint256 _SEASON_DURATION,
    uint256 _currentSeasonExpiry
  ) public initializer {
    __ProjectManager_init(_easAddress, _optimismFoundationAttestors, _SEASON_DURATION, _currentSeasonExpiry);
  }

  function vouch(bytes32 projectApprovalAttestation, bytes32 identityAttestation) public virtual {
    // Scenario 2 & 4: Voucher has not vouched yet
    if (!eligibleVoter[msg.sender]) {
      // Validate the voucher's identity
      require(validateOptimismVoter(identityAttestation, msg.sender), 'Invalid identity attestation');
    }
    // Check if the project has been vouched for
    if (eligibleProject[projectApprovalAttestation] == address(0)) {
      validateProject(projectApprovalAttestation);
    }
  }

  // Vouch function with only project attestation
  function vouch(bytes32 projectApprovalAttestation) public virtual {
    // Scenario 1 & 3: Voucher has already vouched
    require(eligibleVoter[msg.sender], 'Identity attestation required for first-time vouchers');

    // Check if the project has been vouched for
    if (eligibleProject[projectApprovalAttestation] == address(0)) {
      // Validate the project's validity
      validateProject(projectApprovalAttestation);
    }
  }

  // Function to validate the project's attestation
  function validateProject(bytes32 approvalAttestation) public virtual returns (bool) {
    if (eligibleProject[approvalAttestation] != address(0)) {
      return true;
    }

    IEAS.Attestation memory attestation = eas.getAttestation(approvalAttestation);
    require(attestation.uid != bytes32(0), 'Attestation not found');

    bool isValidAttester = false;
    for (uint256 i = 0; i < optimismFoundationAttestors.length; i++) {
      if (attestation.attester == optimismFoundationAttestors[i]) {
        isValidAttester = true;
        break;
      }
    }
    require(isValidAttester, 'Invalid attester');

    uint256 seasonStartTime = currentSeasonExpiry - SEASON_DURATION;
    require(
      attestation.time >= seasonStartTime && attestation.time <= currentSeasonExpiry,
      'Attestation not in current season'
    );

    (string memory param1,,,, string memory param5) =
      abi.decode(attestation.data, (string, string, string, string, string));

    require(keccak256(bytes(param1)) == GRANTEE_HASH, 'Invalid param1');
    require(keccak256(bytes(param5)) == APPLICATION_APPROVED_HASH, 'Invalid param5');
    address projectAddress = attestation.recipient;
    eligibleProject[approvalAttestation] = projectAddress;
    // Add the project to currentProjects if not already included
    currentProjects.push(projectAddress);
    // Mark the project as eligible and set expiry
    eligibleProject[approvalAttestation] = projectAddress;
    projectToExpiry[projectAddress] = currentSeasonExpiry;
    emit ProjectValidated(approvalAttestation, projectAddress);

    return true;
  }

  // Function to validate the voucher's identity
  // function temporarily public for testing
  function validateOptimismVoter(bytes32 identityAttestation, address claimer) public returns (bool) {
    // Get the attestation from the EAS contract
    IEAS.Attestation memory attestation = eas.getAttestation(identityAttestation);
    require(attestation.uid != bytes32(0), 'Attestation not found');

    // Check that the attester is one of the Optimism Foundation attestors
    bool isValidAttester = false;
    for (uint256 i = 0; i < optimismFoundationAttestors.length; i++) {
      if (attestation.attester == optimismFoundationAttestors[i]) {
        isValidAttester = true;
        break;
      }
    }
    require(isValidAttester, 'Invalid attester');

    // Verify that the claimer is the recipient of the attestation
    require(attestation.recipient == claimer, 'Claimer is not the recipient of the attestation');

    // Decode the data to extract the farcasterID and other fields
    (
      bytes32 schema,
      address attester,
      bool revocable,
      uint256 time,
      uint256 expirationTime,
      address recipient,
      bytes memory data,
      uint256 revocationTime
    ) = (
      attestation.schema,
      attestation.attester,
      attestation.revocable,
      attestation.time,
      attestation.expirationTime,
      attestation.recipient,
      attestation.data,
      attestation.revocationTime
    );

    // Decode the data according to the schema
    (
      uint256 farcasterID,
      string memory round,
      string memory voterType,
      string memory votingGroup,
      string memory selectionMethod
    ) = abi.decode(data, (uint256, string, string, string, string));

    eligibleVoter[claimer] = true;

    // Emit an event (optional)
    emit VoterValidated(claimer, farcasterID);

    return true;
  }

  function getCurrentProjects() external view returns (address[] memory) {
    return currentProjects;
  }

  // --- Internal Utilities ---

  function __ProjectManager_init(
    address _easAddress,
    address[] memory _optimismFoundationAttestors,
    uint256 _SEASON_DURATION,
    uint256 _currentSeasonExpiry
  ) internal onlyInitializing {
    eas = IEAS(_easAddress);
    optimismFoundationAttestors = _optimismFoundationAttestors;
    SEASON_DURATION = _SEASON_DURATION;
    currentSeasonExpiry = _currentSeasonExpiry;
  }
}
