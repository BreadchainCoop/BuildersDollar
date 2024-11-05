// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/mocks/MockEAS.sol";
import "contracts/ValidateProject.sol";

contract ProjectValidatorTest is Test {
    ProjectValidator private validator;
    MockEAS private mockEAS;
    address private optimismFoundation1 = address(0x123);
    address private optimismFoundation2 = address(0x456);
    uint256 private roundStartTime = 1000;
    uint256 private roundEndTime = 2000;

    function setUp() public {
        mockEAS = new MockEAS();

        address[] memory optimismFoundationAttestors = new address[](2);
        optimismFoundationAttestors[0] = optimismFoundation1;
        optimismFoundationAttestors[1] = optimismFoundation2;

        validator = new ProjectValidator(
            address(mockEAS),
            optimismFoundationAttestors,
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
            recipient: address(0x789),
            attester: optimismFoundation1,
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

        bool result = validator.validateProject(uid);
        assertTrue(result, "Validation should return true");

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
            recipient: address(0x789),
            attester: optimismFoundation1,
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

        bool firstResult = validator.validateProject(uid);
        assertTrue(firstResult, "First validation should return true");

        bool secondResult = validator.validateProject(uid);
        assertTrue(secondResult, "Second validation should return true even if already included");

        bool isEligible = validator.eligibleProjects(uid);
        assertTrue(isEligible, "Project should still be eligible");
    }

    function testValidateProjectInvalidAttester() public {
        bytes32 uid = keccak256(abi.encodePacked("test-attestation"));
        // Attester not in the list
        address invalidAttester = address(0x999);

        IEAS.Attestation memory attestation = IEAS.Attestation({
            uid: uid,
            schema: bytes32(0),
            refUID: bytes32(0),
            time: 1500,
            expirationTime: 0,
            revocationTime: 0,
            recipient: address(0x789),
            attester: invalidAttester,
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
        bytes32 uidEarly = keccak256(abi.encodePacked("test-attestation-early"));
        IEAS.Attestation memory attestationEarly = IEAS.Attestation({
            uid: uidEarly,
            schema: bytes32(0),
            refUID: bytes32(0),
            time: 500, // Before round start time
            expirationTime: 0,
            revocationTime: 0,
            recipient: address(0x789),
            attester: optimismFoundation1,
            revocable: true,
            data: abi.encode(
                "Grantee",
                "param2",
                "param3",
                "param4",
                "Application Approved"
            )
        });
        mockEAS.setAttestation(uidEarly, attestationEarly);

        vm.expectRevert("Attestation not in current round");
        validator.validateProject(uidEarly);

        bytes32 uidLate = keccak256(abi.encodePacked("test-attestation-late"));
        IEAS.Attestation memory attestationLate = IEAS.Attestation({
            uid: uidLate,
            schema: bytes32(0),
            refUID: bytes32(0),
            time: 2500, // After round end time
            expirationTime: 0,
            revocationTime: 0,
            recipient: address(0x789),
            attester: optimismFoundation1,
            revocable: true,
            data: abi.encode(
                "Grantee",
                "param2",
                "param3",
                "param4",
                "Application Approved"
            )
        });
        mockEAS.setAttestation(uidLate, attestationLate);

        vm.expectRevert("Attestation not in current round");
        validator.validateProject(uidLate);
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
            recipient: address(0x789),
            attester: optimismFoundation1,
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
            recipient: address(0x789),
            attester: optimismFoundation1,
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
