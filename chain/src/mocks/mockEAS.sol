// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import 'interfaces/IEAS.sol';

contract MockEAS is IEAS {
  mapping(bytes32 => Attestation) private _attestations;

  function setAttestation(bytes32 uid, Attestation calldata attestation) external {
    _attestations[uid] = attestation;
  }

  function getAttestation(bytes32 uid) external view override returns (Attestation memory) {
    return _attestations[uid];
  }
}
