// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IEAS.sol";

contract ProjectValidator {
    IEAS public eas;
    address[] public optimismFoundationAttestors;
    uint256 public roundStartTime;
    uint256 public roundEndTime;
    mapping(bytes32 => bool) public eligibleProjects;

    // Constants for hashed values
    bytes32 private constant GRANTEE_HASH = keccak256(bytes("Grantee"));
    bytes32 private constant APPLICATION_APPROVED_HASH = keccak256(bytes("Application Approved"));

    event ProjectValidated(bytes32 indexed approvalAttestation, address indexed recipient);

    constructor(
        address _easAddress,
        address[] memory _optimismFoundationAttestors,
        uint256 _roundStartTime,
        uint256 _roundEndTime
    ) {
        eas = IEAS(_easAddress);
        optimismFoundationAttestors = _optimismFoundationAttestors;
        roundStartTime = _roundStartTime;
        roundEndTime = _roundEndTime;
    }

    function validateProject(bytes32 approvalAttestation) external returns (bool) {
        // If the project is already included, return true
        if (eligibleProjects[approvalAttestation]) {
            return true;
        }

        // Get the attestation from the EAS contract
        IEAS.Attestation memory attestation = eas.getAttestation(approvalAttestation);
        require(attestation.uid != bytes32(0), "Attestation not found");

        // Check that the attester is one of the Optimism Foundation attestors
        bool isValidAttester = false;
        for (uint256 i = 0; i < optimismFoundationAttestors.length; i++) {
            if (attestation.attester == optimismFoundationAttestors[i]) {
                isValidAttester = true;
                break;
            }
        }
        require(isValidAttester, "Invalid attester");

        // Check that the attestation time is within the current round
        require(
            attestation.time >= roundStartTime && attestation.time <= roundEndTime,
            "Attestation not in current round"
        );

        // Decode the data
        (string memory param1, , , , string memory param5) = abi.decode(
            attestation.data,
            (string, string, string, string, string)
        );

        // Check that param1 == "Grantee"
        require(
            keccak256(bytes(param1)) == GRANTEE_HASH,
            "Invalid param1"
        );

        // Check that param5 == "Application Approved"
        require(
            keccak256(bytes(param5)) == APPLICATION_APPROVED_HASH,
            "Invalid param5"
        );

        // Mark the project as eligible
        eligibleProjects[approvalAttestation] = true;

        // Emit event
        emit ProjectValidated(approvalAttestation, attestation.recipient);

        return true;
    }
}
