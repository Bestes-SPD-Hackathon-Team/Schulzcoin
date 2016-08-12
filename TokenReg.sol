contract Token {
    /// Get the total amount of tokens in the system.
    function totalSupply() constant returns (uint256 total);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Owned {
    modifier only_owner { if (msg.sender != owner) return; _ }
    
    function setOwner(address _new) only_owner { owner = _new; }
    
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

