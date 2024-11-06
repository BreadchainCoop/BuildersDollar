//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

// based on https://github.com/ethereum-attestation-service/eas-contracts/blob/master/contracts/IEAS.sol
// and this https://github.com/ethereum-attestation-service/eas-contracts/blob/master/contracts/Common.sol

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
