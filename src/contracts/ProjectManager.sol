// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import {Initializable} from '@oz-upgradeable/proxy/utils/Initializable.sol';
import 'interfaces/IEAS.sol';

contract ProjectManager is Initializable {
  IEAS public eas;
  address[] public optimismFoundationAttestors;
  address public constant hardcodedAttesterAddress = 0x8Bc704386DCE0C4f004194684AdC44Edf6e85f07;

  uint256 public SEASON_DURATION;
  uint64 public currentSeasonExpiry;
  uint256 public minRequiredVouches;

  address[] public currentProjects;
  mapping(address => bool) public eligibleVoter; // Tracks both eligibility and if they have vouched
  mapping(address => uint256) public projectToExpiry;
  mapping(bytes32 => address) public eligibleProject;
  mapping(address => uint256) public projectToVouches;
  mapping(address => mapping(bytes32 => bool)) public userToProjectVouch;

  bytes32 private constant GRANTEE_HASH = keccak256(bytes('Season 6 application approval'));
  bytes32 private constant APPLICATION_APPROVED_HASH = keccak256(bytes('Application Approved'));

  // event when using on-chain attestation
  event ProjectValidated(bytes32 indexed approvalAttestation, address indexed recipient);
  event VoterValidated(address indexed claimer, uint256 indexed farcasterID);

  function initialize(
    address _easAddress,
    address[] memory _optimismFoundationAttestors,
    uint256 _SEASON_DURATION,
    uint64 _currentSeasonExpiry
  ) public initializer {
    __ProjectManager_init(_easAddress, _optimismFoundationAttestors, _SEASON_DURATION, _currentSeasonExpiry);
  }

  function vouch(bytes32 projectApprovalAttestation, bytes32 identityAttestation) public virtual {
    require(!userToProjectVouch[msg.sender][projectApprovalAttestation], 'Already vouched');
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
    require(!userToProjectVouch[msg.sender][projectApprovalAttestation], 'Already vouched');
    // Scenario 1 & 3: Voucher has already vouched
    require(eligibleVoter[msg.sender], 'Identity attestation required for first-time vouchers');

    // Check if the project has been vouched for
    if (eligibleProject[projectApprovalAttestation] == address(0)) {
      // Validate the project's validity
      validateProject(projectApprovalAttestation);
    }
  }

  function validateProject(
        bytes32 uid,        // Unique identifier for attestation
        bytes32 schema,
        address recipient,
        uint64 time,
        uint64 expirationTime,
        bool revocable,
        bytes32 refUID,
        bytes calldata data,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool) {
        // Step 1: Verify the signature of the message
        bytes32 messageHash = keccak256(abi.encode(
            schema,
            recipient,
            time,
            expirationTime,
            revocable,
            refUID,
            keccak256(data), // Hash the data field
            nonce
        ));
        
        // Ethereum Signed Message hash for ecrecover
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        require(signer == hardcodedAttesterAddress, "Invalid signature");

        // Step 2: Validate the UID with EAS
        IEAS.Attestation memory attestation = eas.getAttestation(uid);
        require(attestation.uid != bytes32(0), "Attestation not found");
        require(attestation.recipient == recipient, "UID does not resolve to recipient");
        require(attestation.data == data, "UID does not resolve to provided data");

        // Step 3: Ensure attestation timing is within current season
        uint256 seasonStartTime = currentSeasonExpiry - SEASON_DURATION;
        require(time >= seasonStartTime && time <= currentSeasonExpiry, "Attestation not in current season");

        // Step 4: Decode the data and validate specific values
        (string memory param1,,,, string memory param5) = abi.decode(data, (string, string, string, string, string));
        require(keccak256(bytes(param1)) == GRANTEE_HASH, "Invalid param1");
        require(keccak256(bytes(param5)) == APPLICATION_APPROVED_HASH, "Invalid param5");

        // Step 5: Register project address in eligible projects mapping
        eligibleProject[uid] = recipient;
        
        emit ProjectValidated(uid, recipient);

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

  function ejectProject(address project) public {
    projectToExpiry[project] = 0;
    projectToVouches[project] = 0;
    for (uint256 i; i < currentProjects.length; i++) {
      if (currentProjects[i] == project) {
        currentProjects[i] = currentProjects[currentProjects.length - 1];
        currentProjects.pop();
      }
    }
  }

  function getCurrentProjects() external view returns (address[] memory) {
    return currentProjects;
  }

  // --- Internal Utilities ---

  function __ProjectManager_init(
    address _easAddress,
    address[] memory _optimismFoundationAttestors,
    uint256 _SEASON_DURATION,
    uint64 _currentSeasonExpiry
  ) internal onlyInitializing {
    eas = IEAS(_easAddress);
    optimismFoundationAttestors = _optimismFoundationAttestors;
    SEASON_DURATION = _SEASON_DURATION;
    currentSeasonExpiry = _currentSeasonExpiry;
  }
}
