// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import 'forge-std/Test.sol';
import {TransparentUpgradeableProxy} from '@oz/proxy/transparent/TransparentUpgradeableProxy.sol';
import {IEAS} from 'interfaces/IEAS.sol';
import {ProjectManager} from 'contracts/ProjectManager.sol';
import {console} from 'forge-std/console.sol';

contract ProjectManagerOnChainTest is Test {
  ProjectManager private projectManager;
  IEAS private eas;

  // EAS contract address
  address private constant EAS_CONTRACT_ADDRESS = 0x4200000000000000000000000000000000000021;

  // Attestation UIDs
  bytes32 private constant VOUCHER_UID = 0x2fbd12ff8d3a1724f5b915e632ef7f08ad827d2eb775faa79a2962c5c0ebf05d;
  bytes32 private constant PROJECT_UID = 0x276568175f97956d012bca4c8a2459bd9318a8233c5391fa7b546e70bef80db8;

  // Season parameters
  uint256 private constant SEASON_DURATION = 365 days;
  uint64 private constant SEASON_START_TIMESTAMP = 1_723_148_017;
  uint64 private currentSeasonExpiry;

  address[] private optimismFoundationAttestors;

  function setUp() public {
    // Check if ONCHAIN_TEST environment variable is set
    bool isOnChainTest = vm.envOr('ONCHAIN_TEST', false);
    if (!isOnChainTest) {
      return; // Skip setup if not running on-chain tests
    }

    // Initialize EAS contract
    eas = IEAS(EAS_CONTRACT_ADDRESS);

    // Set current season expiry
    currentSeasonExpiry = SEASON_START_TIMESTAMP + uint64(SEASON_DURATION);

    // Set up the Optimism Foundation attestors
    optimismFoundationAttestors = new address[](2);
    optimismFoundationAttestors[0] = 0xE4553b743E74dA3424Ac51f8C1E586fd43aE226F;
    optimismFoundationAttestors[1] = 0xA1c40eA4a5ac3bCB2878386AF5377B7c96d42462; // found this and added it not sure who it is

    // Initialize the ProjectManager contract
    bytes memory initData = abi.encodeWithSelector(
      ProjectManager.initialize.selector,
      address(eas),
      optimismFoundationAttestors,
      SEASON_DURATION,
      currentSeasonExpiry
    );

    address projectManagerImp = address(new ProjectManager());
    address projectManagerProxy = address(new TransparentUpgradeableProxy(projectManagerImp, address(this), initData));

    projectManager = ProjectManager(projectManagerProxy);
  }

  function testValidateWithRealAttestations() public {
    console.log('Running testValidateWithRealAttestations');
    // Check if ONCHAIN_TEST environment variable is set
    bool isOnChainTest = vm.envOr('ONCHAIN_TEST', false);
    if (!isOnChainTest) {
      return; // Skip test if not running on-chain tests
    }

    // Set block timestamp to season start
    vm.warp(SEASON_START_TIMESTAMP);

    // Fetch voucher attestation from EAS
    IEAS.Attestation memory voucherAttestation = eas.getAttestation(VOUCHER_UID);
    require(voucherAttestation.uid != bytes32(0), 'Voucher attestation not found');

    // Fetch project attestation from EAS
    IEAS.Attestation memory projectAttestation = eas.getAttestation(PROJECT_UID);
    require(projectAttestation.uid != bytes32(0), 'Project attestation not found');

    // Validate voucher
    vm.prank(voucherAttestation.recipient);
    projectManager.vouch(PROJECT_UID, VOUCHER_UID);

    // Check that the voter is marked as eligible
    bool isVoterEligible = projectManager.eligibleVoter(voucherAttestation.recipient);
    assertTrue(isVoterEligible, 'Voter should be eligible');

    // Check that the project is marked as eligible
    address eligibleProjectAddress = projectManager.eligibleProject(PROJECT_UID);
    assertEq(eligibleProjectAddress, projectAttestation.recipient, 'Project should be eligible');

    // Check that the project is added to current projects
    address[] memory currentProjects = projectManager.getCurrentProjects();
    bool projectFound = false;
    for (uint256 i = 0; i < currentProjects.length; i++) {
      if (currentProjects[i] == projectAttestation.recipient) {
        projectFound = true;
        break;
      }
    }
    assertTrue(projectFound, 'Project should be in current projects');
  }
}
