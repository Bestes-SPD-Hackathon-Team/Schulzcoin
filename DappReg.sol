//! DappReg is a Dapp Registry
//! By Parity Team (Ethcore), 2016.
//! Released under the Apache Licence 2.

contract Owned {
  event NewOwner(address indexed old, address indexed current);

  modifier only_owner {
    if (msg.sender != owner) throw;
    _
  }

  address public owner = msg.sender;

  function setOwner(address _new) only_owner {
    NewOwner(owner, _new);
    owner = _new;
  }
}

contract DappReg is Owned {
  struct Dapp {
    bytes32 uniqId; // when we register, grab the manifest Id, if 0 entry invalid/deleted
    bytes32 manifest;
    uint32 priority;
    address owner;
    mapping (bytes32 => bytes32) meta;
  }

  modifier when_fee_paid {
    if (msg.value < fee) throw;
    _
  }

  modifier only_dapp_owner(uint _id) {
    if (dapps[_id].owner != msg.sender) throw;
    _
  }

  modifier both_owner_dapp_owner(uint _id) {
    if (dapps[_id].owner != msg.sender && owner != msg.sender) throw;
    _
  }

  modifier when_uniqid_free(bytes32 _uniqId) {
    if (mapUniqId[_uniqId] != 0) throw;
    _
  }

  modifier when_open {
    if (!open && owner != msg.sender) throw;
    _
  }

  event Registered(bytes32 indexed uniqId, uint indexed id);
  event Unregistered(bytes32 indexed uniqId, uint indexed id);
  event MetaChanged(bytes32 indexed uniqId, uint indexed id, bytes32 indexed key, bytes32 value);
  event Prioritized(bytes32 indexed uniqId, uint indexed id, uint priority);

  Dapp[] dapps;
  mapping (bytes32 => uint) mapUniqId;

  uint public open = 0;
  uint public fee = 1 ether;

  uint constant BASE_PRIORITY = 50;

  function register(bytes32 _manifest) when_public when_fee_paid when_uniqid_free(_manifest) {
    var id = dapps.length;
    dapps.push(Dapp(_manifest, _manifest, BASE_PRIORITY, msg.sender));
    mapUniqId[_manifest] = dapps.length;
    Registered(_manifest, id);
  }

  function unregister(uint _id) both_owner_dapp_owner(_id) {
    Unregistered(dapps[_id].uniqId, _id);
    dapps[_id].uniqId = 0;
  }

  function setFee(uint _fee) only_owner {
    fee = _fee;
  }

  function setOpen(unit _open) only_owner {
    open = _open;
  }

  function dappCount() constant returns (uint) {
    return dapps.length;
  }

  function dapp(uint _id) constant returns (bytes32 uniqId, bytes32 manifest, uint priority, address owner) {
    var d = dapps[_id];
    uniqId = d.uniqId;
    manifest = d.manifest;
    priority = d.priority;
    owner = d.owner;
  }

  function fromUniqId(bytes32 _uniqId) constant returns (bytes32 uniqId, bytes32 manifest, uint priority, address owner) {
    var d = dapps[mapUniqId[_uniqId] - 1];
    uniqId = d.uniqId;
    manifest = d.manifest;
    priority = d.priority;
    owner = d.owner;
  }

  function setPriority(uint _id, uint _priority) only_owner {
    var d = dapps[_id];
    d.priority = _priority;
    Prioritized(d.uniqId, _id, _priority);
  }

  function setManifest(uint _id, bytes32 _manifest) only_dapp_owner(_id) {
    dapps[_id].manifest = _manifest;
  }

  function meta(uint _id, bytes32 _key) constant returns (bytes32) {
    return dapps[_id].meta[_key];
  }

  function setMeta(uint _id, bytes32 _key, bytes32 _value) only_dapp_owner(_id) {
    dapps[_id].meta[_key] = _value;
    MetaChanged(dapps[_id].uniqId, _id, _key, _value);
  }

  function drain() only_owner {
    if (!msg.sender.send(this.balance)) {
      throw;
    }
  }
}
