// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/mocks/MockEAS.sol";
import "contracts/ValidateProject.sol";



contract ProjectValidatorTest is Test {
    ProjectValidator private validator;
    MockEAS private mockEAS;
    address private optimismFoundation = address(0x123);
    uint256 private roundStartTime = 1000;
    uint256 private roundEndTime = 2000;

    function setUp() public {
        mockEAS = new MockEAS();
        validator = new ProjectValidator(
            address(mockEAS),
            optimismFoundation,
            roundStartTime,
            roundEndTime
        );
    }

    function testValidateProjectSuccess() public {
        bytes32 uid = keccak256(abi.encodePacked("test-attestation"));
        IEAS.Attestation memory attestation = IEAS.Attestation({
            uid: uid,
            schema: bytes32(0),
            refUID: bytes32(0),
            time: 1500,
            expirationTime: 0,
            revocationTime: 0,
            recipient: address(0x456),
            attester: optimismFoundation,
            revocable: true,
            data: abi.encode(
                "Grantee",
                "param2",
                "param3",
                "param4",
                "Application Approved"
            )
        });
        mockEAS.setAttestation(uid, attestation);

        validator.validateProject(uid);

        bool isEligible = validator.eligibleProjects(uid);
        assertTrue(isEligible, "Project should be eligible");
    }

    function testValidateProjectAlreadyIncluded() public {
        bytes32 uid = keccak256(abi.encodePacked("test-attestation"));
        IEAS.Attestation memory attestation = IEAS.Attestation({
            uid: uid,
            schema: bytes32(0),
            refUID: bytes32(0),
            time: 1500,
            expirationTime: 0,
            revocationTime: 0,
            recipient: address(0x456),
            attester: optimismFoundation,
            revocable: true,
            data: abi.encode(
                "Grantee",
                "param2",
                "param3",
                "param4",
                "Application Approved"
            )
        });
        mockEAS.setAttestation(uid, attestation);

        validator.validateProject(uid);

        vm.expectRevert("Project already included");
        validator.validateProject(uid);
    }

    function testValidateProjectInvalidAttester() public {
        bytes32 uid = keccak256(abi.encodePacked("test-attestation"));
        IEAS.Attestation memory attestation = IEAS.Attestation({
            uid: uid,
            schema: bytes32(0),
            refUID: bytes32(0),
            time: 1500,
            expirationTime: 0,
            revocationTime: 0,
            recipient: address(0x456),
            attester: address(0x789), // Invalid attester
            revocable: true,
            data: abi.encode(
                "Grantee",
                "param2",
                "param3",
                "param4",
                "Application Approved"
            )
        });
        mockEAS.setAttestation(uid, attestation);

        vm.expectRevert("Invalid attester");
        validator.validateProject(uid);
    }

    function testValidateProjectNotInCurrentRound() public {
        bytes32 uid = keccak256(abi.encodePacked("test-attestation"));
        IEAS.Attestation memory attestationEarly = IEAS.Attestation({
            uid: uid,
            schema: bytes32(0),
            refUID: bytes32(0),
            time: 500, // Before round start time
            expirationTime: 0,
            revocationTime: 0,
            recipient: address(0x456),
            attester: optimismFoundation,
            revocable: true,
            data: abi.encode(
                "Grantee",
                "param2",
                "param3",
                "param4",
                "Application Approved"
            )
        });
        mockEAS.setAttestation(uid, attestationEarly);

        vm.expectRevert("Attestation not in current round");
        validator.validateProject(uid);

        IEAS.Attestation memory attestationLate = attestationEarly;
        attestationLate.time = 2500; // After round end time
        mockEAS.setAttestation(uid, attestationLate);

        vm.expectRevert("Attestation not in current round");
        validator.validateProject(uid);
    }

    function testValidateProjectInvalidParam1() public {
        bytes32 uid = keccak256(abi.encodePacked("test-attestation"));
        IEAS.Attestation memory attestation = IEAS.Attestation({
            uid: uid,
            schema: bytes32(0),
            refUID: bytes32(0),
            time: 1500,
            expirationTime: 0,
            revocationTime: 0,
            recipient: address(0x456),
            attester: optimismFoundation,
            revocable: true,
            data: abi.encode(
                "Not Grantee",
                "param2",
                "param3",
                "param4",
                "Application Approved"
            )
        });
        mockEAS.setAttestation(uid, attestation);

        vm.expectRevert("Invalid param1");
        validator.validateProject(uid);
    }

    function testValidateProjectInvalidParam5() public {
        bytes32 uid = keccak256(abi.encodePacked("test-attestation"));
        IEAS.Attestation memory attestation = IEAS.Attestation({
            uid: uid,
            schema: bytes32(0),
            refUID: bytes32(0),
            time: 1500,
            expirationTime: 0,
            revocationTime: 0,
            recipient: address(0x456),
            attester: optimismFoundation,
            revocable: true,
            data: abi.encode(
                "Grantee",
                "param2",
                "param3",
                "param4",
                "Not Application Approved"
            )
        });
        mockEAS.setAttestation(uid, attestation);

        vm.expectRevert("Invalid param5");
        validator.validateProject(uid);
    }
}
