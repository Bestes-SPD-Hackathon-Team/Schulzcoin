//! Oprah Badge contract
//! You get a badge! And you get a badge! You get a badge too!
//! By Jannis R, 2016.

pragma solidity ^0.4.6;

contract Owned {
    modifier only_owner { if (msg.sender != owner) return; _; }

    event NewOwner(address indexed old, address indexed current);

    function setOwner(address _new) only_owner { NewOwner(owner, _new); owner = _new; }

    address public owner = msg.sender;
}

contract Certifier {
    event Confirmed(address indexed who);
    event Revoked(address indexed who);
    function certified(address _who) constant returns (bool);
    function get(address _who, string _field) constant returns (bytes32) {}
    function getAddress(address _who, string _field) constant returns (address) {}
    function getUint(address _who, string _field) constant returns (uint) {}
}

contract OprahBadge is Owned, Certifier {
    struct Certification {
        bool active;
        mapping (string => bytes32) meta;
    }

    function certify() {
        if (certs[msg.sender].active) return;
        certs[msg.sender].active = true;
        Confirmed(msg.sender);
    }
    function revoke() {
        if (!certs[msg.sender].active) throw;
        certs[msg.sender].active = false;
        Revoked(msg.sender);
    }
    function certified(address _who) constant returns (bool) { return certs[_who].active; }
    function get(address _who, string _field) constant returns (bytes32) { return certs[_who].meta[_field]; }
    function getAddress(address _who, string _field) constant returns (address) { return address(certs[_who].meta[_field]); }
    function getUint(address _who, string _field) constant returns (uint) { return uint(certs[_who].meta[_field]); }

    mapping (address => Certification) certs;
}