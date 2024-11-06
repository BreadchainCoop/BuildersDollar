// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import {Initializable} from '@oz-upgradeable/proxy/utils/Initializable.sol';
import 'interfaces/IEAS.sol';

contract ProjectValidator is Initializable {
  IEAS public eas;
  address[] public optimismFoundationAttestors;

  uint256 public SEASON_DURATION;
  uint256 public currentSeasonExpiry;

  address[] public currentProjects;
  mapping(uint256 => bool) public farcasterIdClaimed;
  mapping(address => bool) public eligibleVoter; // Tracks both eligibility and if they have vouched
  mapping(address => uint256) public projectToExpiry;
  mapping(bytes32 => bool) public eligibleProject;

  bytes32 private constant GRANTEE_HASH = keccak256(bytes('Grantee'));
  bytes32 private constant APPLICATION_APPROVED_HASH = keccak256(bytes('Application Approved'));

  event ProjectValidated(bytes32 indexed approvalAttestation, address indexed recipient);

  function initialize(
    address _easAddress,
    address[] memory _optimismFoundationAttestors,
    uint256 _SEASON_DURATION,
    uint256 _currentSeasonExpiry
  ) public initializer {
    __ProjectValidator_init(_easAddress, _optimismFoundationAttestors, _SEASON_DURATION, _currentSeasonExpiry);
  }

  function vouch(bytes32 projectApprovalAttestation, bytes32 identityAttestation) public virtual {
    // Scenario 2 & 4: Voucher has not vouched yet
    if (!eligibleVoter[msg.sender]) {
      // Validate the voucher's identity
      validateOptimismVoter(identityAttestation);
      eligibleVoter[msg.sender] = true;
    }

    // Check if the project has been vouched for
    if (!eligibleProject[projectApprovalAttestation]) {
      // Validate the project's validity
      validateProject(projectApprovalAttestation);

      // Get the project address from the attestation
      IEAS.Attestation memory attestation = eas.getAttestation(projectApprovalAttestation);
      address projectAddress = attestation.recipient;

      // Add the project to currentProjects if not already included
      currentProjects.push(projectAddress);

      // Mark the project as eligible and set expiry
      eligibleProject[projectApprovalAttestation] = true;
      projectToExpiry[projectAddress] = currentSeasonExpiry;
    }
  }

  // Vouch function with only project attestation
  function vouch(bytes32 projectApprovalAttestation) public virtual {
    // Scenario 1 & 3: Voucher has already vouched
    require(eligibleVoter[msg.sender], 'Identity attestation required for first-time vouchers');

    // Check if the project has been vouched for
    if (!eligibleProject[projectApprovalAttestation]) {
      // Validate the project's validity
      validateProject(projectApprovalAttestation);

      // Get the project address from the attestation
      IEAS.Attestation memory attestation = eas.getAttestation(projectApprovalAttestation);
      address projectAddress = attestation.recipient;

      // Add the project to currentProjects if not already included
      currentProjects.push(projectAddress);

      // Mark the project as eligible and set expiry
      eligibleProject[projectApprovalAttestation] = true;
      projectToExpiry[projectAddress] = currentSeasonExpiry;
    }
  }

  // Function to validate the project's attestation
  function validateProject(bytes32 approvalAttestation) public virtual returns (bool) {
    if (eligibleProject[approvalAttestation]) {
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

    eligibleProject[approvalAttestation] = true;
    emit ProjectValidated(approvalAttestation, attestation.recipient);

    return true;
  }

  function validateOptimismVoter(bytes32 identityAttestation) internal {
    // Empty for now
  }

  // --- Internal Utilities ---

  function __ProjectValidator_init(
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
