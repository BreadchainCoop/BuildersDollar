//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

// based on https://github.com/ethereum-attestation-service/eas-contracts/blob/master/contracts/IEAS.sol
// and this https://github.com/ethereum-attestation-service/eas-contracts/blob/master/contracts/Common.sol

interface IEAS {
/// @notice A struct representing a single attestation.
struct Attestation {
    bytes32 uid; // A unique identifier of the attestation.
    bytes32 schema; // The unique identifier of the schema.
    uint64 time; // The time when the attestation was created (Unix timestamp).
    uint64 expirationTime; // The time when the attestation expires (Unix timestamp).
    uint64 revocationTime; // The time when the attestation was revoked (Unix timestamp).
    bytes32 refUID; // The UID of the related attestation.
    address recipient; // The recipient of the attestation.
    address attester; // The attester/sender of the attestation.
    bool revocable; // Whether the attestation is revocable.
    bytes data; // Custom attestation data.
}

  function getAttestation(bytes32 uid) external view returns (Attestation memory);
}
