// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import 'script/Constants.s.sol';
import {Base} from 'test/Base.t.sol';
import {IOBDYieldDistributor} from 'interfaces/IOBDYieldDistributor.sol';
import {IEAS} from 'interfaces/IEAS.sol';
import {MockEAS} from 'mocks/MockEAS.sol';

contract OBDYieldDistributorTest is Base {
  address internal _initialVoucher = makeAddr('initialVoucher');
  address internal _validOpAttestor = address(0x420);
  address internal _invalidOpAttestor = makeAddr('invalidOpAttestor');

  address internal _validRecipient = makeAddr('validRecipient');
  address internal _invalidRecipient = makeAddr('invalidRecipient');

  bytes32[6] internal _attestationUids;

  MockEAS internal _mockEAS;

  function setUp() public override {
    super.setUp();
    _mockEAS = MockEAS(_eas);
    _addProjectAttestations();
  }

  function testDeploy() public {
    assertEq(address(obdYieldDistributor.token()), _token);
    assertEq(address(obdYieldDistributor.eas()), _eas);
    assertEq(obdYieldDistributor.SEASON_DURATION(), _seasonDuration);
    assertEq(obdYieldDistributor.currentSeasonExpiry(), _currentSeasonExpiry);

    IOBDYieldDistributor.YieldDistributorParams memory _params = obdYieldDistributor.params();
    assertEq(_params.cycleLength, CYCLE_LENGTH);
    assertEq(_params.lastClaimedTimestamp, LAST_CLAIMED_TIMESTAMP);
    assertEq(_params.minVouches, MIN_VOUCHES);
    assertEq(_params.precision, PRECISION);
  }

  function testValidateProject() public {
    bool _ok = obdYieldDistributor.validateProject(_attestationUids[0]);
    assertTrue(_ok);
  }

  function testVouchRevertID() public {
    vm.expectRevert('Identity attestation required for first-time vouchers');
    obdYieldDistributor.vouch(_attestationUids[0]);
  }

  // function testVouchWithExistingId() public {
  // vm.prank(_validOpAttestor);
  // obdYieldDistributor.vouch(_attestationUids[0]);
  // }

  // function testVouchWithNewId() public {}

  // function testDistributeYield() public {}

  // --- Internal Utils ---
  function _addProjectAttestations() internal {
    bytes32 _uid_valid = keccak256(abi.encodePacked('valid-attestation'));
    bytes32 _uid_invalid_attestor = keccak256(abi.encodePacked('invalid-attestor'));
    bytes32 _uid_invalid_early = keccak256(abi.encodePacked('invalid-early'));
    bytes32 _uid_invalid_late = keccak256(abi.encodePacked('invalid-late'));
    bytes32 _uid_invalid_param1 = keccak256(abi.encodePacked('invalid-param1'));
    bytes32 _uid_invalid_param5 = keccak256(abi.encodePacked('invalid-param5'));

    _attestationUids[0] = _uid_valid;
    _attestationUids[1] = _uid_invalid_attestor;
    _attestationUids[2] = _uid_invalid_early;
    _attestationUids[3] = _uid_invalid_late;
    _attestationUids[4] = _uid_invalid_param1;
    _attestationUids[5] = _uid_invalid_param5;

    IEAS.Attestation memory _baseAttestation = IEAS.Attestation({
      uid: _uid_valid,
      schema: bytes32(0),
      refUID: bytes32(0),
      time: SEASON_START_TIMESTAMP + (uint64(SEASON_DURATION) / 2),
      expirationTime: 0,
      revocationTime: 0,
      recipient: _validRecipient,
      attester: _validOpAttestor,
      revocable: true,
      data: abi.encode('Grantee', 'param2', 'param3', 'param4', 'Application Approved')
    });
    _mockEAS.setAttestation(_uid_valid, _baseAttestation);

    IEAS.Attestation memory _invalid_attestor_Attestation = _baseAttestation;
    _invalid_attestor_Attestation.attester = _invalidOpAttestor;
    _mockEAS.setAttestation(_uid_invalid_attestor, _invalid_attestor_Attestation);

    IEAS.Attestation memory _invalid_early_Attestation = _baseAttestation;
    _invalid_early_Attestation.time = SEASON_START_TIMESTAMP - 1;
    _mockEAS.setAttestation(_uid_invalid_early, _invalid_early_Attestation);

    IEAS.Attestation memory _invalid_late_Attestation = _baseAttestation;
    _invalid_late_Attestation.time = SEASON_START_TIMESTAMP + uint64(SEASON_DURATION) + 1;
    _mockEAS.setAttestation(_uid_invalid_late, _invalid_late_Attestation);

    IEAS.Attestation memory _invalid_param1_Attestation = _baseAttestation;
    _invalid_param1_Attestation.data = abi.encode('Not Grantee', 'param2', 'param3', 'param4', 'Application Approved');
    _mockEAS.setAttestation(_uid_invalid_param1, _invalid_param1_Attestation);

    IEAS.Attestation memory _invalid_param5_Attestation = _baseAttestation;
    _invalid_param5_Attestation.data = abi.encode('Grantee', 'param2', 'param3', 'param4', 'Application Denied');
    _mockEAS.setAttestation(_uid_invalid_param5, _invalid_param5_Attestation);

    // TODO: Add attestation ID
    // bytes32 _op_delegate = keccak256(abi.encodePacked('op-delegate'));
    // IEAS.Attestation memory _identity_Attestation = _baseAttestation;
    // _identity_Attestation.uid = _op_delegate;
    // _identity_Attestation.recipient = _initialVoucher;
    // _mockEAS.setAttestation(_op_delegate, _identity_Attestation);

    // vm.prank(_initialVoucher);
    // obdYieldDistributor.vouch(_uid_valid, _op_delegate);
  }
}
