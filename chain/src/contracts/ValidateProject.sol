// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "interfaces/IEAS.sol";

contract ProjectValidator {
    IEAS public eas;
    address public optimismFoundation;
    uint256 public roundStartTime;
    uint256 public roundEndTime;
    mapping(bytes32 => bool) public eligibleProjects;

    event ProjectValidated(bytes32 indexed approvalAttestation, address indexed recipient);

    constructor(
        address _easAddress,
        address _optimismFoundation,
        uint256 _roundStartTime,
        uint256 _roundEndTime
    ) {
        eas = IEAS(_easAddress);
        optimismFoundation = _optimismFoundation;
        roundStartTime = _roundStartTime;
        roundEndTime = _roundEndTime;
    }

    function validateProject(bytes32 approvalAttestation) external {
        // Check that it hasn't already been included in the eligible projects
        require(!eligibleProjects[approvalAttestation], "Project already included");

        // Get the attestation from the EAS contract
        IEAS.Attestation memory attestation = eas.getAttestation(approvalAttestation);
        require(attestation.uid != bytes32(0), "Attestation not found");

        // Check that the attester is the Optimism Foundation
        require(attestation.attester == optimismFoundation, "Invalid attester");

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
            keccak256(abi.encodePacked(param1)) == keccak256(abi.encodePacked("Grantee")),
            "Invalid param1"
        );

        // Check that param5 == "Application Approved"
        require(
            keccak256(abi.encodePacked(param5)) ==
                keccak256(abi.encodePacked("Application Approved")),
            "Invalid param5"
        );

        // Mark the project as eligible
        eligibleProjects[approvalAttestation] = true;

        // Emit event
        emit ProjectValidated(approvalAttestation, attestation.recipient);
    }
}
