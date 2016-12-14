//! Registry contract.
//! By Gav Wood (Ethcore), 2016.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.0;

// From Owned.sol
contract Owned {
	event NewOwner(address indexed old, address indexed current);

	function setOwner(address _new) only_owner { NewOwner(owner, _new); owner = _new; }

	modifier only_owner { if (msg.sender != owner) return; _; }

	address public owner = msg.sender;
}

contract MetadataRegistry {
	event DataChanged(bytes32 indexed name, string indexed key, string plainKey);

	function getData(bytes32 _name, string _key) constant returns (bytes32);
	function getAddress(bytes32 _name, string _key) constant returns (address);
	function getUint(bytes32 _name, string _key) constant returns (uint);
}

contract OwnerRegistry {
	event Reserved(bytes32 indexed name, address indexed owner);
	event Transferred(bytes32 indexed name, address indexed oldOwner, address indexed newOwner);
	event Dropped(bytes32 indexed name, address indexed owner);

	function getOwner(bytes32 _name) constant returns (address);
}

contract ReversibleRegistry {
	event ReverseConfirmed(string indexed name, address indexed reverse);
	event ReverseRemoved(string indexed name, address indexed reverse);

	function hasReverse(bytes32 _name) constant returns (bool);
	function getReverse(bytes32 _name) constant returns (address);
	function canReverse(address _data) constant returns (bool);
	function reverse(address _data) constant returns (string);
}
