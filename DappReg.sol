//! DappReg is a Dapp Registry
//! By Parity Team (Ethcore), 2016.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.1;

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

contract DappReg is Owned {
  // id       - shared to be the same accross all contracts for a specific dapp (including GithuHint for the repo)
  // priority - Rating will be dealt with in other contracts, however this just gives us a generic way to move
  //            things up or down if need be. Very high values will probably indicate a default feature, i.e. already
  //            visible without user selection, a 0 means it won't show at all (is deleted)
  // owner    - that guy
  // meta     - meta information for the dapp
  struct Dapp {
    bytes32 id;
    uint priority;
    address owner;
    mapping (bytes32 => bytes32) meta;
  }

  modifier when_fee_paid {
    if (msg.value < fee) throw;
    _;
  }

  modifier only_dapp_owner(bytes32 _id) {
    if (dapps[_id].owner != msg.sender) throw;
    _;
  }

  modifier both_owner_dapp_owner(bytes32 _id) {
    if (dapps[_id].owner != msg.sender && owner != msg.sender) throw;
    _;
  }

  modifier when_id_free(bytes32 _id) {
    if (dapps[_id].id != 0) throw;
    _;
  }

  modifier when_open {
    if (open == 0 && owner != msg.sender) throw;
    _;
  }

  event MetaChanged(bytes32 indexed id, bytes32 indexed key, bytes32 value);
  event OwnerChanged(bytes32 indexed id, address indexed owner);
  event PriorityChanged(bytes32 indexed id, uint indexed priority);
  event Registered(bytes32 indexed id, address indexed owner);
  event Unregistered(bytes32 indexed id);

  mapping (bytes32 => Dapp) dapps;
  bytes32[] ids;

  uint public open = 0;
  uint public fee = 1 ether;

  uint constant BASE_PRIORITY = 100;

  // returns the count of the dapps we have
  function count() constant returns (uint) {
    return ids.length;
  }

  // a dapp from the list
  function at(uint _idx) constant returns (bytes32 id, bytes32 repo, uint priority, address owner) {
    Dapp d = dapps[ids[_idx]];
    id = d.id;
    priority = d.priority;
    owner = d.owner;
  }

  // get with the id
  function get(bytes32 _id) constant returns (bytes32 id, bytes32 repo, uint priority, address owner) {
    Dapp d = dapps[_id];
    id = d.id;
    priority = d.priority;
    owner = d.owner;
  }

  // add apps
  function register(bytes32 _id) when_open when_fee_paid when_id_free(_id) {
    ids.push(_id);
    dapps[_id] = Dapp(_id, BASE_PRIORITY, msg.sender);
    Registered(_id, msg.sender);
  }

  // remove apps
  function unregister(bytes32 _id) both_owner_dapp_owner(_id) {
    dapps[_id].priority = 0;
    Unregistered(_id);
  }

  // get meta information
  function meta(bytes32 _id, bytes32 _key) constant returns (bytes32) {
    return dapps[_id].meta[_key];
  }

  // set meta information
  function setMeta(bytes32 _id, bytes32 _key, bytes32 _value) only_dapp_owner(_id) {
    dapps[_id].meta[_key] = _value;
    MetaChanged(_id, _key, _value);
  }

  // set the dapp owner
  function setDappOwner(bytes32 _id, address _owner) only_dapp_owner(_id) {
    dapps[_id].owner = _owner;
    OwnerChanged(_id, _owner);
  }

  // set the app priority
  function setPriority(bytes32 _id, uint _priority) only_owner {
    dapps[_id].priority = _priority;
    PriorityChanged(_id, _priority);
  }

  // set the registration fee
  function setFee(uint _fee) only_owner {
    fee = _fee;
  }

  // set the open status (0 = closed)
  function setOpen(uint _open) only_owner {
    open = _open;
  }

  // retrieve funds paid
  function drain() only_owner {
    if (!msg.sender.send(this.balance)) {
      throw;
    }
  }
}
