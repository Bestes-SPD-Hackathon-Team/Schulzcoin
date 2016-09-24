//! A decentralised registry of 4-bytes signatures => method mappings
//! By Parity Team (Ethcore), 2016.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.1;

contract Owned {
  modifier only_owner {
    if (msg.sender != owner) return;
    _;
  }

  event NewOwner(address indexed old, address indexed current);

  function setOwner(address _new) only_owner { NewOwner(owner, _new); owner = _new; }

  address public owner = msg.sender;
}

contract SignatureReg is Owned {
  // a signature structure, storing the method name & owner
  //    method - a human-readable method in the form of "getMethod(bytes32)"
  //    owner  - the person registering the type
  struct Entry {
    string method;
    address owner;
  }

  // mapping of signatures to entries
  mapping (bytes4 => Entry) public entries;

  // a list of all available signatures
  bytes4[] public signatures;

  // the total count of registered signatures
  uint public totalSignatures = 0;

  // allow only new calls to go in
  modifier when_unregistered(bytes4 _signature) {
    if (entries[_signature].owner != 0) return;
    _;
  }

  // dispatched when a new signature is registered
  event Registered(address indexed owner, bytes4 signature, string method);

  // constructor with self-registration
  function SignatureReg() {
    register('register(string)');
    register('setOwner(address)');
    register('drain()');
  }

  // registers a method mapping
  function register(string _method) returns (bool) {
    return _register(bytes4(sha3(_method)), _method);
  }

  // internal register function, signature => method
  function _register(bytes4 _signature, string _method) internal when_unregistered(_signature) returns (bool) {
    entries[_signature] = Entry(_method, msg.sender);
    totalSignatures = totalSignatures + 1;
    Registered(msg.sender, _signature, _method);
    return true;
  }

  // returns a specific method
  function get(bytes4 _signature) constant returns (string method, address owner) {
    Entry entry = entries[_signature];
    method = entry.method;
    owner = entry.owner;
  }

  // in the case of any extra funds
  function drain() only_owner {
    if (!msg.sender.send(this.balance)) {
      throw;
    }
  }
}
