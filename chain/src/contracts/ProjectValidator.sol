// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {IEAS} from 'interfaces/IEAS.sol';

contract ProjectValidator {
  IEAS public eas;
  address[] public optimismFoundationAttestors;

  // Replaced with variables from the spec. Shouldn't need others if im understanding correctly
  uint256 public SEASON_DURATION;
  uint256 public currentSeasonExpiry;

  mapping(bytes32 => bool) public eligibleProjects;

  // Constants for hashed values
  bytes32 private constant GRANTEE_HASH = keccak256(bytes('Grantee'));
  bytes32 private constant APPLICATION_APPROVED_HASH = keccak256(bytes('Application Approved'));

  event ProjectValidated(bytes32 indexed approvalAttestation, address indexed recipient);

  constructor(
    address _easAddress,
    address[] memory _optimismFoundationAttestors,
    uint256 _SEASON_DURATION,
    uint256 _currentSeasonExpiry
  ) {
    eas = IEAS(_easAddress);
    optimismFoundationAttestors = _optimismFoundationAttestors;
    SEASON_DURATION = _SEASON_DURATION;
    currentSeasonExpiry = _currentSeasonExpiry;
  }

  function validateProject(bytes32 approvalAttestation) external returns (bool) {
    // If the project is already included, return true
    if (eligibleProjects[approvalAttestation]) {
      return true;
    }

    // Get the attestation from the EAS contract
    IEAS.Attestation memory attestation = eas.getAttestation(approvalAttestation);
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

    // Calculate the season start time
    uint256 seasonStartTime = currentSeasonExpiry - SEASON_DURATION;

    // Check that the attestation time is within the current season
    require(
      attestation.time >= seasonStartTime && attestation.time <= currentSeasonExpiry,
      'Attestation not in current season'
    );

    // Decode the data
    (string memory param1,,,, string memory param5) =
      abi.decode(attestation.data, (string, string, string, string, string));

    // Check that param1 == "Grantee"
    require(keccak256(bytes(param1)) == GRANTEE_HASH, 'Invalid param1');

    // Check that param5 == "Application Approved"
    require(keccak256(bytes(param5)) == APPLICATION_APPROVED_HASH, 'Invalid param5');

    // Mark the project as eligible
    eligibleProjects[approvalAttestation] = true;

    // OBDYieldDistributor
    // TODO: Add project to list of eligible projects

    // Emit event
    emit ProjectValidated(approvalAttestation, attestation.recipient);

    return true;
  }
}
