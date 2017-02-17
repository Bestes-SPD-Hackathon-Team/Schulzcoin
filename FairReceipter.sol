//! Receipting contract. Just records who sent what.
//! By Parity Technologies, 2017.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.7;

contract Certifier {
	event Confirmed(address indexed who);
	event Revoked(address indexed who);
	function certified(address _who) constant returns (bool);
	function getData(address _who, string _field) constant returns (bytes32) {}
	function getAddress(address _who, string _field) constant returns (address) {}
	function getUint(address _who, string _field) constant returns (uint) {}
}

contract Recorder {
	function received(address _who, uint _value);
}

// ECR20 standard token interface
contract Token {
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);

	function balanceOf(address _owner) constant returns (uint256 balance);
	function transfer(address _to, uint256 _value) returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
	function approve(address _spender, uint256 _value) returns (bool success);
	function allowance(address _owner, address _spender) constant returns (uint256 remaining);
}

// Owner-specific contract interface
contract Owned {
	event NewOwner(address indexed old, address indexed current);

	modifier only_owner {
		if (msg.sender != owner) throw;
		_;
	}

	address public owner = msg.sender;

	function setOwner(address _new) only_owner {
		NewOwner(owner, _new);
		owner = _new;
	}
}

// BasicCoin, ECR20 tokens that all belong to the owner for sending around
contract BasicToken is Token {
	// this is as basic as can be, only the associated balance & allowances
	struct Account {
		uint balance;
		mapping (address => uint) allowanceOf;
	}

	// constructor sets the parameters of execution, _totalSupply is all units
	function BasicToken(uint _totalSupply) when_no_eth when_non_zero(_totalSupply) {
		totalSupply = _totalSupply;
		accounts[msg.sender].balance = totalSupply;
	}

	// balance of a specific address
	function balanceOf(address _who) constant returns (uint256) {
		return accounts[_who].balance;
	}

	// transfer
	function transfer(address _to, uint256 _value) when_no_eth when_owns(msg.sender, _value) returns (bool) {
		Transfer(msg.sender, _to, _value);
		accounts[msg.sender].balance -= _value;
		accounts[_to].balance += _value;

		return true;
	}

	// transfer via allowance
	function transferFrom(address _from, address _to, uint256 _value) when_no_eth when_owns(_from, _value) when_has_allowance(_from, msg.sender, _value) returns (bool) {
		Transfer(_from, _to, _value);
		accounts[_from].allowanceOf[msg.sender] -= _value;
		accounts[_from].balance -= _value;
		accounts[_to].balance += _value;

		return true;
	}

	// approve allowances
	function approve(address _spender, uint256 _value) when_no_eth returns (bool) {
		Approval(msg.sender, _spender, _value);
		accounts[msg.sender].allowanceOf[_spender] += _value;

		return true;
	}

	// available allowance
	function allowance(address _owner, address _spender) constant returns (uint256) {
		return accounts[_owner].allowanceOf[_spender];
	}

	// no default function, simple contract only, entry-level users
	function() {
		throw;
	}

	// the balance should be available
	modifier when_owns(address _owner, uint _amount) {
		if (accounts[_owner].balance < _amount) throw;
		_;
	}

	// an allowance should be available
	modifier when_has_allowance(address _owner, address _spender, uint _amount) {
		if (accounts[_owner].allowanceOf[_spender] < _amount) throw;
		_;
	}

	// no ETH should be sent with the transaction
	modifier when_no_eth {
		if (msg.value > 0) throw;
		_;
	}

	// a value should be > 0
	modifier when_non_zero(uint _value) {
		if (_value == 0) throw;
		_;
	}

	// the base, tokens denoted in micros
	uint constant public base = 1000000;

	// available token supply
	uint public totalSupply;

	// storage and mapping of all balances & allowances
	mapping (address => Account) accounts;
}

contract BasicMintableToken is Owned, BasicToken, Recorder {
	event Minted(address indexed who, uint value);

	function BasicMintableToken(address _owner) {
		owner = _owner;
	}

	function received(address _who, uint _value) { mint(_who, _value); }
	function mint(address _who, uint _value) {
		accounts[_who].balance += _value;
		totalSupply += _value;
		Minted(_who, _value);
	}
}

/// Will accept Ether "contributions" and record each both as a log and in a
/// queryable record.
contract Receipter {
	/// Constructor. `_admin` has the ability to pause the
	/// contribution period and, eventually, kill this contract. `_treasury`
	/// receives all funds. `_beginTime` and `_endTime` define the begin and
	/// end of the period.
    function Receipter(address _recorder, address _admin, address _treasury, uint _beginTime, uint _endTime) {
		recorder = Recorder(_recorder);
        admin = _admin;
        treasury = _treasury;
        beginTime = _beginTime;
        endTime = _endTime;
    }

	// Can only be called by _admin.
    modifier only_admin { if (msg.sender != admin) throw; _; }
	// Can only be called by prior to the period.
    modifier only_before_period { if (now >= beginTime) throw; _; }
	// Only does something if during the period.
    modifier when_during_period { if (now >= beginTime && now < endTime && !isHalted) _; }
	// Can only be called during the period when not halted.
    modifier only_during_period { if (now < beginTime || now >= endTime || isHalted) throw; _; }
	// Can only be called during the period when halted.
    modifier only_during_halted_period { if (now < beginTime || now >= endTime || !isHalted) throw; _; }
	// Can only be called after the period.
    modifier only_after_period { if (now < endTime || isHalted) throw; _; }
	// The value of the message must be sufficiently large to not be considered dust.
    modifier is_not_dust { if (msg.value < dust) throw; _; }

	/// Some contribution `amount` received from `recipient`.
    event Received(address indexed recipient, uint amount);
	/// Period halted abnormally.
    event Halted();
	/// Period restarted after abnormal halt.
    event Unhalted();

	/// Fallback function: receive a contribution from sender.
    function() payable {
        processReceipt(msg.sender);
    }

	/// Receive a contribution from sender.
	function receive() payable returns (bool) {
        return processReceipt(msg.sender);
    }

	/// Receive a contribution from `_recipient`.
    function receiveFrom(address _recipient) payable returns (bool) {
		return processReceipt(_recipient);
    }

	/// Receive a contribution from `_recipient`.
    function processReceipt(address _recipient)
		only_during_period
		is_not_dust
		internal
		returns (bool)
	{
        if (!treasury.call.value(msg.value)()) throw;
        recorder.received(_recipient, msg.value);
        total += msg.value;
        Received(_recipient, msg.value);
		return true;
    }

	/// Halt the contribution period. Any attempt at contributing will fail.
    function halt() only_admin only_during_period {
        isHalted = true;
        Halted();
    }

	/// Unhalt the contribution period.
    function unhalt() only_admin only_during_halted_period {
        isHalted = false;
        Unhalted();
    }

	/// Kill this contract.
    function kill() only_admin only_after_period {
        suicide(treasury);
    }

	// How much is enough?
    uint public constant dust = 100 finney;

	// The contract which gets called whenever anything is received.
	Recorder public recorder;
	// Who can halt/unhalt/kill?
    address public admin;
	// Who gets the stash?
    address public treasury;
	// When does the contribution period begin?
    uint public beginTime;
	// When does the period end?
    uint public endTime;

	// Are contributions abnormally halted?
    bool public isHalted = false;

    mapping (address => uint) public record;
    uint public total = 0;
}

contract SignedReceipter is Receipter {
    function SignedReceipter(address _recorder, address _admin, address _treasury, uint _beginTime, uint _endTime, bytes32 _sigHash) {
		recorder = Recorder(_recorder);
        admin = _admin;
        treasury = _treasury;
        beginTime = _beginTime;
        endTime = _endTime;
        sigHash = _sigHash;
    }

    modifier only_signed(address who, uint8 v, bytes32 r, bytes32 s) { if (ecrecover(sigHash, v, r, s) != who) throw; _; }

    function() payable { throw; }
	function receive() payable returns (bool) { throw; }
	function receiveFrom(address) payable returns (bool) { throw; }

    /// Fallback function: receive a contribution from sender.
    function receiveSigned(uint8 v, bytes32 r, bytes32 s) payable returns (bool) {
        return processSignedReceipt(msg.sender, v, r, s);
    }

	/// Receive a contribution from `_recipient`.
    function receiveSignedFrom(address _sender, uint8 v, bytes32 r, bytes32 s) payable returns (bool) {
		return processSignedReceipt(_sender, v, r, s);
    }

	/// Receive a contribution from `_recipient`.
    function processSignedReceipt(address _sender, uint8 v, bytes32 r, bytes32 s)
		only_signed(_sender, v, r, s)
		internal
		returns (bool)
	{
		return processReceipt(_sender);
    }

    bytes32 sigHash;
}

contract CertifyingReceipter is SignedReceipter {
    function CertifyingReceipter(address _recorder, address _admin, address _treasury, uint _beginTime, uint _endTime, bytes32 _sigHash, address _certifier) {
		recorder = Recorder(_recorder);
		admin = _admin;
        treasury = _treasury;
        beginTime = _beginTime;
        endTime = _endTime;
        sigHash = _sigHash;
        certifier = Certifier(_certifier);
    }

	/// Fallback function: receive a contribution from sender.
    function receiveSigned(uint8 v, bytes32 r, bytes32 s) payable returns (bool) {
        return processCertifiedReceipt(msg.sender, v, r, s);
    }

	function receiveSignedFrom() payable returns (bool) { throw; }

	function processCertifiedReceipt(address _sender, uint8 v, bytes32 r, bytes32 s)
        internal
        only_certified(msg.sender)
		returns (bool)
    {
		return processSignedReceipt(_sender, v, r, s);
    }

    modifier only_certified(address who) { if (!certifier.certified(who)) throw; _; }

    Certifier certifier;
}

contract FairReceipter is CertifyingReceipter{
    function FairReceipter(
		address _recorder,
		address _admin,
		address _treasury,
		uint _beginTime,
		uint _endTime,
		bytes32 _sigHash,
		address _certifier,
		uint _cap,
		uint _segmentDuration
	) {
		recorder = Recorder(_recorder);
		admin = _admin;
        treasury = _treasury;
		beginTime = _beginTime;
        endTime = _endTime;
		sigHash = _sigHash;
        certifier = Certifier(_certifier);
		cap = _cap;
		segmentDuration = _segmentDuration;
    }

    function receive(uint8 v, bytes32 r, bytes32 s)
		only_under_max(msg.sender)
        payable
		returns (bool)
    {
		return processCertifiedReceipt(msg.sender, v, r, s);
    }

	function maxBuy() when_during_period public returns (uint) {
        uint segment = (now - beginTime) / segmentDuration;
		// actually just: segment = min(segment, endSegment);
        if (segment > endSegment)
            segment = endSegment;
        return firstMaxBuy << segment;
    }

	function maxBuyFor(address _who) when_during_period public returns (uint) {
        var segmentMaxBuy = maxBuy();
		// Should never happen, but just in case...
        if (record[_who] >= segmentMaxBuy)
            return 0;
        return segmentMaxBuy - record[_who];
    }

    modifier only_under_max(address who) { if (msg.value > maxBuyFor(who)) throw; _; }

    uint constant firstMaxBuy = 1 ether;
    uint constant endSegment = 16;

    uint segmentDuration;
    uint cap;
}
