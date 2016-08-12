//! Token Registry contract.
//! By Gav Wood (Ethcore), 2016.
//! Released under the Apache Licence 2.

// From Owned.sol
contract Owned {
    modifier only_owner { if (msg.sender != owner) return; _ }
    
    event NewOwner(address indexed old, address indexed current);
    
    function setOwner(address _new) only_owner { NewOwner(owner, _new); owner = _new; }
    
    address public owner = msg.sender;
}

contract TokenReg is Owned {
    struct Token {
        address addr;
        string tla;
        uint base;
        string name;
        mapping (bytes32 => bytes32) meta;
    }
    
    modifier when_fee_paid { if (msg.value < fee) return; _ }
    modifier when_address_free(address _addr) { if (mapFromAddress[_addr] != 0) return; _ }
    modifier when_tla_free(string _tla) { if (mapFromTLA[_tla] != 0) return; _ }
    modifier when_is_tla(string _tla) { if (bytes(_tla).length != 3) return; _ }
    
    function register(address _addr, string _tla, uint _base, string _name) when_fee_paid when_address_free(_addr) when_is_tla(_tla) when_tla_free(_tla) {
        tokens.push(Token(_addr, _tla, _base, _name));
        mapFromAddress[_addr] = tokens.length;
        mapFromTLA[_tla] = tokens.length;
    }
    
    function unregister(uint _id) only_owner {
        delete mapFromAddress[tokens[_id].addr];
        delete mapFromTLA[tokens[_id].tla];
        delete tokens[_id];
    }
    
    function setFee(uint _fee) only_owner {
        fee = _fee;
    }
    
    function tokenCount() constant returns (uint) { return tokens.length; }
    function token(uint _id) constant returns (address o_addr, string o_tla, uint o_base, string o_name) {
        var t = tokens[_id];
        o_addr = t.addr;
        o_tla = t.tla;
        o_base = t.base;
        o_name = t.name;
    }        
    
    function fromAddress(address _addr) constant returns (uint o_id, string o_tla, uint o_base, string o_name) {
        o_id = mapFromAddress[_addr] - 1;
        var t = tokens[o_id];
        o_tla = t.tla;
        o_base = t.base;
        o_name = t.name;
    }
    
    function fromTLA(string _tla) constant returns (uint o_id, address o_addr, uint o_base, string o_name) {
        o_id = mapFromTLA[_tla] - 1;
        var t = tokens[o_id];
        o_addr = t.addr;
        o_base = t.base;
        o_name = t.name;
    }
    
    function meta(uint _id, bytes32 _key) constant returns (bytes32) {
        return tokens[_id].meta[_key];
    }
    
    function drain() only_owner {
        if (!msg.sender.send(this.balance))
            throw;
    }
    
    mapping (address => uint) mapFromAddress;
    mapping (string => uint) mapFromTLA;
    Token[] tokens;
    uint public fee = 1 ether;
}

