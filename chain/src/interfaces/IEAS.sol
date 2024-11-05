// contracts/interfaces/IEAS.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IEAS {
  struct Attestation {
    bytes32 uid;
    bytes32 schema;
    bytes32 refUID;
    uint64 time;
    uint64 expirationTime;
    uint64 revocationTime;
    address recipient;
    address attester;
    bool revocable;
    bytes data;
  }

  function getAttestation(bytes32 uid) external view returns (Attestation memory);
}
