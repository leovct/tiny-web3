// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @notice Interface for TinyENS.
interface ITinyENS {
  /// @notice Register a new ENS name and link it to an address.
  /// @param name The ENS name to register.
  function register(string memory name) external;

  /// @notice Update the ENS name linked to an address.
  /// @param newName The new ENS name.
  function update(string memory newName) external;

  /// @notice Resolve the address associated with a given ENS name.
  /// @param name The ENS name to resolve.
  /// @return The address associated with the ENS name.
  function resolve(string memory name) external view returns (address);

  /// @notice Reverse resolve an address to its associated ENS name.
  /// @param targetAddress The target address to reverse resolve.
  /// @return The ENS name associated with the address.
  function reverse(address targetAddress) external view returns (string memory);
}

/// @title Tiny Ethereum Name Service
/// @author leovct
/// @notice Map human-readable names like 'vitalik.eth' to machine-readable identifiers such as
/// Ethereum addresses like '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045' and support the reverse
/// resolution.
contract TinyENS is ITinyENS {
  /// @notice Thrown when trying to register a name already registered.
  error AlreadyRegistered();

  /// @notice Map ENS names to addresses.
  mapping(string => address) private registry;

  /// @notice Map addresses to ENS names.
  mapping(address => string) private reverseRegistry;

  modifier notRegistered(string memory name) {
    if (registry[name] != address(0)) revert AlreadyRegistered();
    _;
  }

  function register(string memory name) public notRegistered(name) {
    registry[name] = msg.sender;
    reverseRegistry[msg.sender] = name;
  }

  function update(string memory newName) external notRegistered(newName) {
    // Unlink the old name and the address.
    string memory oldName = reverseRegistry[msg.sender];
    registry[oldName] = address(0);
    // Register the new name.
    register(newName);
  }

  function resolve(string memory name) external view returns (address) {
    return registry[name];
  }

  function reverse(address targetAddress) external view returns (string memory) {
    return reverseRegistry[targetAddress];
  }
}
