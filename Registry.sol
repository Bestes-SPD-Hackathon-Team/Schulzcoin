contract Owned {
    modifier only_owner { if (msg.sender != owner) return; _ }
    
    event NewOwner(address indexed old, address indexed current);
    
    function setOwner(address _new) only_owner { NewOwner(owner, _new); owner = _new; }
    
    address public owner = msg.sender;
}

contract Registry is Owned {
    struct Entry {
        address owner;
        address reverse;
        mapping (string => bytes32) data;
    }
    
    event Drained(uint amount);
    event FeeChanged(uint amount);
    event Reserved(string indexed name, address indexed owner);
    event Transferred(string indexed name, address indexed oldOwner, address indexed newOwner);
    event Dropped(string indexed name, address indexed owner);
    event DataChanged(string indexed name, address indexed owner, string indexed key);
    event ReverseProposed(string indexed name, address indexed reverse);
    event ReverseConfirmed(string indexed name, address indexed reverse);
    event ReverseRemoved(string indexed name, address indexed reverse);

    modifier when_unreserved(string _name) { if (entries[_name].owner != 0) return; _ }
    modifier only_owner_of(string _name) { if (entries[_name].owner != msg.sender) return; _ }
    modifier when_proposed(string _name) { if (entries[_name].reverse != msg.sender) return; _ }


    function reserve(string _name) when_unreserved(_name) {
        entries[_name].owner = msg.sender;
        Reserved(_name, msg.sender);
    }
    function transfer(string _name, address _to) only_owner_of(_name) {
        entries[_name].owner = _to;
        Transferred(_name, msg.sender, _to);
    }
    function drop(string _name) only_owner_of(_name) {
        delete entries[_name];
        Dropped(_name, msg.sender);
    }
    
    function set(string _name, string _key, bytes32 _value) only_owner_of(_name) {
        entries[_name].data[_key] = _value;
        DataChanged(_name, msg.sender, _key);
    }
    function setAddress(string _name, string _key, address _value) only_owner_of(_name) {
        entries[_name].data[_key] = bytes32(_value);
        DataChanged(_name, msg.sender, _key);
    }
    function setUint(string _name, string _key, uint _value) only_owner_of(_name) {
        entries[_name].data[_key] = bytes32(_value);
        DataChanged(_name, msg.sender, _key);
    }
    
    function get(string _name, string _key) constant returns (bytes32) {
        return entries[_name].data[_key];
    }
    function getAddress(string _name, string _key) constant returns (address) {
        return address(entries[_name].data[_key]);
    }
    function getUint(string _name, string _key) constant returns (uint) {
        return uint(entries[_name].data[_key]);
    }
    
    function proposeReverse(string _name, address _who) only_owner_of(_name) {
        if (entries[_name].reverse != 0 && sha3(reverse[entries[_name].reverse]) == sha3(_name)) {
            delete reverse[entries[_name].reverse];
            ReverseRemoved(_name, entries[_name].reverse);
        }
        entries[_name].reverse = _who;
        ReverseProposed(_name, _who);
    }
    
    function confirmReverse(string _name) when_proposed(_name) {
        reverse[msg.sender] = _name;
        ReverseConfirmed(_name, msg.sender);
    }
    
    function removeReverse() {
        ReverseRemoved(reverse[msg.sender], msg.sender);
        delete entries[reverse[msg.sender]].reverse;
        delete reverse[msg.sender];
    }
    
    function setFee(uint _amount) only_owner {
        fee = _amount;
        FeeChanged(_amount);
    }
    
    function drain() only_owner {
        Drained(this.balance);
        if (!msg.sender.send(this.balance)) throw;
    }
    
    mapping (string => Entry) entries;
    mapping (address => string) reverse;
    
    uint public fee = 1 ether;
}

