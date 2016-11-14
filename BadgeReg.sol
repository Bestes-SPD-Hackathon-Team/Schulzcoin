//! Badge Registry contract.
//! By Gav Wood (Ethcore), 2016.
//! Released under the Apache Licence 2.

// From Owned.sol
contract Owned {
    modifier only_owner { if (msg.sender != owner) return; _ }

    event NewOwner(address indexed old, address indexed current);

    function setOwner(address _new) only_owner { NewOwner(owner, _new); owner = _new; }

    address public owner = msg.sender;
}

contract BadgeReg is Owned {
    struct Badge {
        address addr;
        string name;
        address owner;
        mapping (bytes32 => bytes32) meta;
    }

    modifier when_fee_paid { if (msg.value < fee) return; _ }
    modifier when_address_free(address _addr) { if (mapFromAddress[_addr] != 0) return; _ }
    modifier when_name_free(string _name) { if (mapFromName[_name] != 0) return; _ }
    modifier when_is_name(string _name) { if (bytes(_name).length != 3) return; _ }
    modifier when_has_name(string _name) { if (mapFromName[_name] == 0) return; _ }
    modifier only_badge_owner(uint _id) { if (badges[_id].owner != msg.sender) return; _ }

    event Registered(string indexed name, uint indexed id, address addr);
    event Unregistered(string indexed name, uint indexed id);
    event MetaChanged(uint indexed id, bytes32 indexed key, bytes32 value);

    function register(address _addr, string _name) returns (bool) {
        return registerAs(_addr, _name, msg.sender);
    }

    function registerAs(address _addr, string _name, uint _base, string _name, address _owner) when_fee_paid when_address_free(_addr) when_is_name(_name) when_name_free(_name) returns (bool) {
        badges.push(Badge(_addr, _name, _base, _name, _owner));
        mapFromAddress[_addr] = badges.length;
        mapFromName[_name] = badges.length;
        Registered(_name, badges.length - 1, _addr, _name);
        return true;
    }

    function unregister(uint _id) only_owner {
        Unregistered(badges[_id].name, _id);
        delete mapFromAddress[badges[_id].addr];
        delete mapFromName[badges[_id].name];
        delete badges[_id];
    }

    function setFee(uint _fee) only_owner {
        fee = _fee;
    }

    function badgeCount() constant returns (uint) { return badges.length; }

    function badge(uint _id) constant returns (address addr, string name, address owner) {
        var t = badges[_id];
        addr = t.addr;
        name = t.name;
        owner = t.owner;
    }

    function fromAddress(address _addr) constant returns (uint id, string name, address owner) {
        id = mapFromAddress[_addr] - 1;
        var t = badges[id];
        name = t.name;
        owner = t.owner;
    }

    function fromName(string _name) constant returns (uint id, address addr, address owner) {
        id = mapFromName[_name] - 1;
        var t = badges[id];
        addr = t.addr;
        owner = t.owner;
    }

    function meta(uint _id, bytes32 _key) constant returns (bytes32) {
        return badges[_id].meta[_key];
    }

    function setMeta(uint _id, bytes32 _key, bytes32 _value) only_badge_owner(_id) {
        badges[_id].meta[_key] = _value;
        MetaChanged(_id, _key, _value);
    }

    function drain() only_owner {
        if (!msg.sender.send(this.balance))
            throw;
    }

    mapping (address => uint) mapFromAddress;
    mapping (string => uint) mapFromName;
    Badge[] badges;
    uint public fee = 1 ether;
}
