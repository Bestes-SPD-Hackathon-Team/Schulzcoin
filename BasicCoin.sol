//! BasicCoin ECR20-compliant token contract
//! By Parity Team (Ethcore), 2016.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.1;

// ECR20 standard token interface
contract Token {
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  function totalSupply() constant returns (uint256 total);
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

// Network Registry interface
contract Registry {
  function reserve(bytes32 _name) returns (bool success);
  function transfer(bytes32 _name, address _to) returns (bool success);
  function drop(bytes32 _name) only_owner_of(_name) returns (bool success);
  function set(bytes32 _name, string _key, bytes32 _value) returns (bool success);
  function setAddress(bytes32 _name, string _key, address _value) returns (bool success);
  function setUint(bytes32 _name, string _key, uint _value) returns (bool success);
  function reserved(bytes32 _name) constant returns (bool reserved);
  function get(bytes32 _name, string _key) constant returns (bytes32);
  function getAddress(bytes32 _name, string _key) constant returns (address);
  function getUint(bytes32 _name, string _key) constant returns (uint);
  function proposeReverse(string _name, address _who) returns (bool success);
  function confirmReverse(string _name) returns (bool success);
  function removeReverse();
  function setFee(uint _amount);
  function drain();
}

// TokenReg interface
contract TokenReg {
  function isAddressFree(address _address) constant returns (bool);
  function isTLAFree(string _tla) constant returns (bool);
  function register(address _addr, string _tla, uint _base, string _name);
  function unregister(uint _id);
  function setFee(uint _fee);
  function tokenCount() constant returns (uint);
  function token(uint _id) constant returns (address addr, string tla, uint base, string name, address owner);
  function fromAddress(address _addr) constant returns (uint id, string tla, uint base, string name, address owner);
  function fromTLA(string _tla) constant returns (uint id, address addr, uint base, string name, address owner);
  function meta(uint _id, bytes32 _key) constant returns (bytes32);
  function setMeta(uint _id, bytes32 _key, bytes32 _value);
  function drain();
}

// BasicCoin, ECR20 tokens that all belong to the owner for sending around
contract BasicCoin is Owned, Token {
  // this is as basic as can be, only the associated balance & allowances
  struct Account {
    uint balance;
    mapping (address => uint) allowanceOf;
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

  // constructor sets the parameters of execution, totalSupply is in full units
  function BasicCoin(uint128 _totalSupply) when_no_eth when_non_zero(_totalSupply) {
    totalSupply = _totalSupply;
    accounts[msg.sender].balance = _totalSupply * base;
    Transfer(this, msg.sender, _totalSupply * base);
  }

  // balance of a specific address
  function balanceOf(address _who) constant returns (uint) {
    return accounts[_who].balance;
  }

  // transfer
  function transfer(address _to, uint _value) when_no_eth when_owns(msg.sender, _value) returns (bool success) {
    Transfer(msg.sender, _to, _value);
    accounts[msg.sender].balance -= _value;
    accounts[_to].balance += _value;

    return true;
  }

  // transfer via allowance
  function transferFrom(address _from, address _to, uint256 _value) when_no_eth when_owns(_from, _value) when_has_allowance(_from, msg.sender, _value) returns (bool success) {
    Transfer(_from, _to, _value);
    accounts[_from].allowanceOf[msg.sender] -= _value;
    accounts[_from].balance -= _value;
    accounts[_to].balance += _value;

    return true;
  }

  // approve allowances
  function approve(address _spender, uint256 _value) when_no_eth returns (bool success) {
    Approval(msg.sender, _spender, _value);
    accounts[msg.sender].allowanceOf[_spender] += _value;

    return true;
  }

  // available allowance
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return accounts[_owner].allowanceOf[_spender];
  }

  // no default function, simple contract only, entry-level users
  function() {
    throw;
  }
}

// Manages the creation of a BasicCoin, including registration
contract BasicCoinCreator is Owned {
  // a structure wrapping a deployed BasicCoin
  struct Deployed {
    address coinAddress;
    address owner;
  }

  // a list of all the deployments
  Deployed[] deployments;

  // the network registry contract
  Registry registry;

  // the name of TokenReg
  bytes32 constant tokenregName = sha3('tokenreg');

  // create the coin creator, storing the network registry
  function BasicCoinCreator(address _registryAddress) {
    registry = Registry(_registryAddress);
  }

  // return the number of deployments
  function countDeployments() constant returns (uint) {
    return deployments.length;
  }

  // get a specific deployment
  function getDeployment(uint _idx) constant returns (address coinAddress, address owner) {
    var deployment = deployments[_idx];

    coinAddress = deployment.coinAddress;
    owner = deployment.owner;
  }

  // deploy a new BasicCoin on the blockchain, optionally registering it with TokenReg
  function deployCoin(uint128 _totalSupply, bool _doTokenreg, string _tla, string _name) {
    var coin = new BasicCoin(_totalSupply);

    coin.setOwner(msg.sender);
    coin.transfer(_totalSupply * coin.base);

    if (_doTokenreg) {
      var tokenreg = registry.get(tokenregName, 'A');
      var coinAddress = address(coin);

      tokenreg.register(coinAddress, _tla, _base, coin.base);
      tokenreg.transferTLA(_tla, msg.sender);
    }
  }

  // owner can remove all collected funds
  function drain() only_owner {
    if (!msg.sender.send(this.balance)) {
      throw;
    }
  }
}
