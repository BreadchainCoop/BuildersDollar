// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import 'forge-std/Test.sol';
import {TransparentUpgradeableProxy} from '@oz/proxy/transparent/TransparentUpgradeableProxy.sol';
import {IEAS} from 'interfaces/IEAS.sol';
import {MockEAS} from 'mocks/MockEAS.sol';
import {ProjectManager} from 'contracts/ProjectManager.sol';

contract ProjectManagerTest is Test {
  ProjectManager private projectManager;
  MockEAS private mockEAS;
  address private optimismFoundation1 = address(0x123);
  address private optimismFoundation2 = address(0x456);

  uint64 private SEASON_DURATION = 1000;
  uint64 private currentSeasonExpiry = 2000;
  uint64 private CYCLE_LENGTH = 100;
  address[] private optimismFoundationAttestors;

  function setUp() public {
    mockEAS = new MockEAS();

    optimismFoundationAttestors = new address[](2);
    optimismFoundationAttestors[0] = optimismFoundation1;
    optimismFoundationAttestors[1] = optimismFoundation2;

    bytes memory _initData = abi.encodeWithSelector(
      ProjectManager.initialize.selector,
      address(mockEAS),
      optimismFoundationAttestors,
      SEASON_DURATION,
      currentSeasonExpiry,
      CYCLE_LENGTH
    );

    address projectManagerImp = address(new ProjectManager());
    address _projectManagerProxy = address(new TransparentUpgradeableProxy(projectManagerImp, address(this), _initData));

    projectManager = ProjectManager(_projectManagerProxy);
  }

  function testValidateProjectSuccess() public {
    bytes32 uid = keccak256(abi.encodePacked('test-attestation'));
    IEAS.Attestation memory attestation = IEAS.Attestation({
      uid: uid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500, // Within the season
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0x789),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode('Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });
    mockEAS.setAttestation(uid, attestation);

    bool result = projectManager.validateProject(uid);
    assertTrue(result, 'Validation should return true');

    address isEligible = projectManager.eligibleProject(uid);
    assertNotEq(isEligible, address(0), 'Project should be marked as eligible');
  }

  function testValidateProjectAlreadyIncluded() public {
    bytes32 uid = keccak256(abi.encodePacked('test-attestation'));
    IEAS.Attestation memory attestation = IEAS.Attestation({
      uid: uid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500, // Within the season
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0x789),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode('Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });
    mockEAS.setAttestation(uid, attestation);

    bool firstResult = projectManager.validateProject(uid);
    assertTrue(firstResult, 'First validation should return true');

    bool secondResult = projectManager.validateProject(uid);
    assertTrue(secondResult, 'Second validation should return true even if already included');
  }

  function testValidateProjectInvalidAttester() public {
    bytes32 uid = keccak256(abi.encodePacked('test-attestation'));
    // Attester not in the list
    address invalidAttester = address(0x999);

    IEAS.Attestation memory attestation = IEAS.Attestation({
      uid: uid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500, // Within the season
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0x789),
      attester: invalidAttester,
      revocable: true,
      data: abi.encode('Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });
    mockEAS.setAttestation(uid, attestation);

    vm.expectRevert('Invalid attester');
    projectManager.validateProject(uid);
  }

  function testValidateProjectNotInCurrentSeason() public {
    uint64 beforeSeasonStart = currentSeasonExpiry - (SEASON_DURATION + 100);

    // Attestation before the season start
    bytes32 uidEarly = keccak256(abi.encodePacked('test-attestation-early'));
    IEAS.Attestation memory attestationEarly = IEAS.Attestation({
      uid: uidEarly,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: beforeSeasonStart,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0x789),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode('Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });
    mockEAS.setAttestation(uidEarly, attestationEarly);

    vm.expectRevert('Attestation not in current season');
    projectManager.validateProject(uidEarly);

    // Attestation after the season end
    bytes32 uidLate = keccak256(abi.encodePacked('test-attestation-late'));
    IEAS.Attestation memory attestationLate = IEAS.Attestation({
      uid: uidLate,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: beforeSeasonStart,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0x789),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode('Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });
    mockEAS.setAttestation(uidLate, attestationLate);

    vm.expectRevert('Attestation not in current season');
    projectManager.validateProject(uidLate);
  }

  function testValidateProjectInvalidParam1() public {
    bytes32 uid = keccak256(abi.encodePacked('test-attestation'));
    IEAS.Attestation memory attestation = IEAS.Attestation({
      uid: uid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500, // Within the season
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0x789),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode('Not Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });
    mockEAS.setAttestation(uid, attestation);

    vm.expectRevert('Invalid param1');
    projectManager.validateProject(uid);
  }

  function testValidateProjectInvalidParam5() public {
    bytes32 uid = keccak256(abi.encodePacked('test-attestation'));
    IEAS.Attestation memory attestation = IEAS.Attestation({
      uid: uid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500, // Within the season
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0x789),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode('Grantee', 'param2', 'param3', 'param4', 'Not Application Approved')
    });
    mockEAS.setAttestation(uid, attestation);

    vm.expectRevert('Invalid param5');
    projectManager.validateProject(uid);
  }

  function testValidateOptimismVoterSuccess() public {
    // Prepare the attestation
    bytes32 uid = keccak256(abi.encodePacked('identity-attestation'));
    uint256 farcasterID = 12_345;

    IEAS.Attestation memory attestation = IEAS.Attestation({
      uid: uid,
      schema: bytes32(0), // Schema can be bytes32(0) for testing
      refUID: bytes32(0),
      time: 1500,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(this),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode(farcasterID, 'round', 'voterType', 'votingGroup', 'selectionMethod')
    });

    mockEAS.setAttestation(uid, attestation);

    // Call validateOptimismVoter
    projectManager.validateOptimismVoter(uid, address(this));
  }

  function testValidateOptimismVoterInvalidAttester() public {
    bytes32 uid = keccak256(abi.encodePacked('identity-attestation'));
    uint256 farcasterID = 12_345;

    address invalidAttester = address(0x999);

    IEAS.Attestation memory attestation = IEAS.Attestation({
      uid: uid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(this),
      attester: invalidAttester,
      revocable: true,
      data: abi.encode(farcasterID, 'round', 'voterType', 'votingGroup', 'selectionMethod')
    });

    mockEAS.setAttestation(uid, attestation);

    vm.expectRevert('Invalid attester');
    projectManager.validateOptimismVoter(uid, address(this));
  }

  function testValidateOptimismVoterInvalidRecipient() public {
    bytes32 uid = keccak256(abi.encodePacked('identity-attestation'));
    uint256 farcasterID = 12_345;

    IEAS.Attestation memory attestation = IEAS.Attestation({
      uid: uid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0xabc),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode(farcasterID, 'round', 'voterType', 'votingGroup', 'selectionMethod')
    });

    mockEAS.setAttestation(uid, attestation);

    vm.expectRevert('Claimer is not the recipient of the attestation');
    projectManager.validateOptimismVoter(uid, address(this));
  }

  function testValidateOptimismVoterAttestationNotFound() public {
    bytes32 uid = keccak256(abi.encodePacked('non-existent-attestation'));

    vm.expectRevert('Attestation not found');
    projectManager.validateOptimismVoter(uid, address(this));
  }

  // Now, tests for vouch functions covering the four scenarios

  // Scenario 4: Voucher has not vouched and the project has not been vouched for
  function testVouchFirstTimeVoucherAndFirstTimeProject() public {
    // Prepare identity attestation
    bytes32 identityUid = keccak256(abi.encodePacked('identity-attestation'));
    uint256 farcasterID = 12_345;

    IEAS.Attestation memory identityAttestation = IEAS.Attestation({
      uid: identityUid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(this),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode(farcasterID, 'round', 'voterType', 'votingGroup', 'selectionMethod')
    });

    mockEAS.setAttestation(identityUid, identityAttestation);

    // Prepare project attestation
    bytes32 projectUid = keccak256(abi.encodePacked('project-attestation'));

    IEAS.Attestation memory projectAttestation = IEAS.Attestation({
      uid: projectUid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0x789),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode('Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });

    mockEAS.setAttestation(projectUid, projectAttestation);

    // Call vouch with both attestations
    projectManager.vouch(projectUid, identityUid);

    // Check that eligibleVoter is updated
    bool isEligible = projectManager.eligibleVoter(address(this));
    assertTrue(isEligible, 'Voter should be marked as eligible');

    // Check that the project is now eligible
    address isProjectEligible = projectManager.eligibleProject(projectUid);
    assertNotEq(isProjectEligible, address(0), 'Project should be marked as eligible');

    // Check that the project is added to currentProjects
    address[] memory projects = projectManager.getCurrentProjects();
    assertEq(projects[0], address(0x789), 'The project address should be correct');
  }

  // Scenario 2: Voucher has not already vouched, and the project has already been vouched for
  function testVouchFirstTimeVoucherProjectAlreadyVouched() public {
    // First, another user vouches for the project
    address otherUser = address(0xabc);

    // Prepare identity attestation for otherUser
    bytes32 identityUidOther = keccak256(abi.encodePacked('identity-attestation-other'));
    uint256 farcasterIDOther = 54_321;

    IEAS.Attestation memory identityAttestationOther = IEAS.Attestation({
      uid: identityUidOther,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500,
      expirationTime: 0,
      revocationTime: 0,
      recipient: otherUser,
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode(farcasterIDOther, 'round', 'voterType', 'votingGroup', 'selectionMethod')
    });

    mockEAS.setAttestation(identityUidOther, identityAttestationOther);

    // Prepare project attestation
    bytes32 projectUid = keccak256(abi.encodePacked('project-attestation'));

    IEAS.Attestation memory projectAttestation = IEAS.Attestation({
      uid: projectUid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0x789),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode('Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });

    mockEAS.setAttestation(projectUid, projectAttestation);

    // otherUser vouches for the project
    vm.prank(otherUser);
    projectManager.vouch(projectUid, identityUidOther);

    // Now, address(this) wants to vouch
    // Prepare identity attestation for address(this)
    bytes32 identityUid = keccak256(abi.encodePacked('identity-attestation'));
    uint256 farcasterID = 12_345;

    IEAS.Attestation memory identityAttestation = IEAS.Attestation({
      uid: identityUid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1500,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(this),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode(farcasterID, 'round', 'voterType', 'votingGroup', 'selectionMethod')
    });

    mockEAS.setAttestation(identityUid, identityAttestation);

    // Call vouch with identity attestation
    projectManager.vouch(projectUid, identityUid);

    // Check that eligibleVoter is updated
    bool isEligible = projectManager.eligibleVoter(address(this));
    assertTrue(isEligible, 'Voter should be marked as eligible');

    // Check that the project is still eligible
    address isProjectEligible = projectManager.eligibleProject(projectUid);
    assertNotEq(isProjectEligible, address(0), 'Project should be marked as eligible');

    // Check that the project is in currentProjects only once
    address[] memory projects = projectManager.getCurrentProjects();
    assertEq(projects.length, 1, 'There should be one project in currentProjects');
  }

  // Scenario 3: Voucher has already vouched, and the project has not been vouched for
  function testVouchAlreadyVouchedNewProject() public {
    // First, address(this) vouches for a project
    testVouchFirstTimeVoucherAndFirstTimeProject();

    // Prepare project attestation for a new project
    bytes32 projectUidNew = keccak256(abi.encodePacked('project-attestation-new'));

    IEAS.Attestation memory projectAttestationNew = IEAS.Attestation({
      uid: projectUidNew,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1600,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0xdef),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode('Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });

    mockEAS.setAttestation(projectUidNew, projectAttestationNew);

    // Call vouch with only project attestation
    projectManager.vouch(projectUidNew);

    // Check that the new project is now eligible
    address isProjectEligible = projectManager.eligibleProject(projectUidNew);
    assertNotEq(isProjectEligible, address(0), 'New project should be marked as eligible');

    // Check that both projects are in currentProjects
    address[] memory projects = projectManager.getCurrentProjects();
    assertEq(projects.length, 2, 'There should be two projects in currentProjects');
  }

  // Scenario 1: Voucher has already vouched, and the project has already been vouched by someone else
  function testVouchAlreadyVouchedProjectAlreadyVouched() public {
    // First, another user vouches for the project
    testVouchFirstTimeVoucherProjectAlreadyVouched();

    // Now, address(this) wants to vouch for the same project
    // Since they've already vouched, they only need to call vouch with project attestation
    bytes32 projectUid = keccak256(abi.encodePacked('project-attestation'));
    projectManager.vouch(projectUid);

    // No changes should occur, but function should not revert
    // Check that eligibleVoter is still true
    bool isEligible = projectManager.eligibleVoter(address(this));
    assertTrue(isEligible, 'Voter should be marked as eligible');

    // Check that the project is still eligible
    address isProjectEligible = projectManager.eligibleProject(projectUid);
    // check that the address is not the zero address
    assertNotEq(isProjectEligible, address(0), 'Project should be marked as eligible');

    // Check that project is not duplicated in currentProjects
    address[] memory projects = projectManager.getCurrentProjects();
    assertEq(projects.length, 1, 'There should be one project in currentProjects');
  }

  // Additional tests for edge cases

  function testVouchFirstTimeVoucherWithoutIdentityAttestation() public {
    // Attempt to vouch without identity attestation
    bytes32 projectUid = keccak256(abi.encodePacked('project-attestation'));

    // Prepare project attestation
    IEAS.Attestation memory projectAttestation = IEAS.Attestation({
      uid: projectUid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1600,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0xdef),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode('Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });

    mockEAS.setAttestation(projectUid, projectAttestation);

    // Call vouch without identity attestation
    vm.expectRevert('Identity attestation required for first-time vouchers');
    projectManager.vouch(projectUid);
  }

  function testVouchAlreadyVouchedInvalidProjectAttestation() public {
    // First, address(this) vouches for a valid project
    testVouchFirstTimeVoucherAndFirstTimeProject();

    // Now attempt to vouch for an invalid project
    bytes32 projectUidInvalid = keccak256(abi.encodePacked('project-attestation-invalid'));

    // Prepare invalid project attestation (invalid param1)
    IEAS.Attestation memory projectAttestationInvalid = IEAS.Attestation({
      uid: projectUidInvalid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: 1600,
      expirationTime: 0,
      revocationTime: 0,
      recipient: address(0xabc),
      attester: optimismFoundation1,
      revocable: true,
      data: abi.encode('Not Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });

    mockEAS.setAttestation(projectUidInvalid, projectAttestationInvalid);

    // Call vouch with invalid project attestation
    vm.expectRevert('Invalid param1');
    projectManager.vouch(projectUidInvalid);
  }
}
