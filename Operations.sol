// Operations contract, by Gavin Wood.
// Copyright Parity Technologies Ltd (UK), 2016.
// This code may be distributed under the terms of the Apache Licence, version 2.

//pragma solidity ^0.4;

contract Operations {
    uint8 constant Stable = 0;
    uint8 constant Beta = 1;
    uint8 constant Nightly = 2;

    struct Release {
        uint32 forkBlock;
        uint8 track;
        uint24 semver;
    }

    struct Build {
        bytes32 release;
        bytes32 platform;
    }

    struct Client {
        address owner;
        bool required;
        mapping (bytes32 => Release) release;
        mapping (uint8 => bytes32) current;
        mapping (bytes32 => Build) build;
    }

    enum Status {
        Undecided,
        Accepted,
        Rejected
    }

    struct Fork {
        bytes32 name;
        bytes32 spec;
        bool ratified;
        uint requiredCount;
        mapping (bytes32 => Status) status;
    }

    struct Transaction {
        uint requiredCount;
        mapping (bytes32 => Status) status;
        address to;
        bytes data;
        uint value;
        uint gas;
    }

    event Received(address indexed from, uint value, bytes data);
    event TransactionProposed(bytes32 indexed client, bytes32 indexed txid, address indexed to, bytes data, uint value, uint gas);
    event TransactionConfirmed(bytes32 indexed client, bytes32 indexed txid);
    event TransactionRejected(bytes32 indexed client, bytes32 indexed txid);
    event TransactionRelayed(bytes32 indexed txid, bool success);
    event ForkProposed(bytes32 indexed client, uint32 indexed number, bytes32 indexed name, bytes32 spec);
    event ForkAcceptedBy(bytes32 indexed client, uint32 indexed number);
    event ForkRejectedBy(bytes32 indexed client, uint32 indexed number);
    event ForkRejected(uint32 indexed forkNumber);
    event ForkRatified(uint32 indexed forkNumber);
    event ReleaseAdded(bytes32 indexed client, uint32 indexed forkBlock, bytes32 indexed release, uint8 track, uint24 semver);
    event ChecksumAdded(bytes32 indexed client, bytes32 indexed release, bytes32 indexed platform, bytes32 checksum);
    event ClientAdded(bytes32 indexed client, address owner);
    event ClientRemoved(bytes32 indexed client);
    event ClientOwnerChanged(bytes32 indexed client, address indexed old, address indexed now);
    event ClientRequiredChanged(bytes32 indexed client, bool now);
    event OwnerChanged(address old, address now);

    function Operations() {
        forks[0] = Fork("frontier", sha3("frontier"), true, 0);
        forks[1150000] = Fork("homestead", sha3("homestead"), true, 0);
        forks[2463000] = Fork("eip150", sha3("eip150"), true, 0);
        latestFork = 2463000;

        clients["parity"] = Client(msg.sender, true);
        owners[msg.sender] = "parity";
        clientsRequired = 1;

        clients["parity"].release[0xb14aed734e1f16676b2ec442b1b5a63d86f7bb5d] = Release(2463000, Beta, 0x010402);
        clients["parity"].current[Beta] = 0xb14aed734e1f16676b2ec442b1b5a63d86f7bb5d;
        clients["parity"].release[0x080ec8043f41e25ee8aa4ee6112906ac6d82ea74] = Release(2463000, Stable, 0x01030b);
        clients["parity"].current[Stable] = 0x080ec8043f41e25ee8aa4ee6112906ac6d82ea74;
    }

    function() /*payable*/ { Received(msg.sender, msg.value, msg.data); }

    // Functions for client owners

    function proposeTransaction(bytes32 _txid, address _to, bytes _data, uint _value, uint _gas) only_required_client_owner only_when_no_proxy(_txid) returns (uint txSuccess) {
        var client = owners[msg.sender];
        proxy[_txid] = Transaction(1, _to, _data, _value, _gas);
        proxy[_txid].status[client] = Status.Accepted;
        txSuccess = checkProxy(_txid);
        TransactionProposed(client, _txid, _to, _data, _value, _gas);
    }

    function confirmTransaction(bytes32 _txid) only_required_client_owner only_when_proxy(_txid) only_when_proxy_undecided(_txid) returns (uint txSuccess) {
        var client = owners[msg.sender];
        proxy[_txid].status[client] = Status.Accepted;
        proxy[_txid].requiredCount += 1;
        txSuccess = checkProxy(_txid);
        TransactionConfirmed(client, _txid);
    }

    function rejectTransaction(bytes32 _txid) only_required_client_owner only_when_proxy(_txid) only_when_proxy_undecided(_txid) {
        delete proxy[_txid];
        TransactionRejected(owners[msg.sender], _txid);
    }

    function proposeFork(uint32 _number, bytes32 _name, bytes32 _spec) only_client_owner only_when_none_proposed {
        forks[_number].name = _name;
        forks[_number].spec = _spec;
        ForkProposed(owners[msg.sender], _number, _name, _spec);
    }

    function acceptFork() when_fork only_undecided_client_owner{
        var client = owners[msg.sender];
        forks[proposedFork].status[client] = Status.Accepted;
        ForkAcceptedBy(client, proposedFork);
        noteAccepted(client);
    }

    function rejectFork() only_undecided_client_owner only_unratified {
        var client = owners[msg.sender];
        forks[proposedFork].status[client] = Status.Rejected;
        ForkRejectedBy(client, proposedFork);
        noteRejected(client);
    }

    function setClientOwner(address _newOwner) only_client_owner {
        var client = owners[msg.sender];
        owners[msg.sender] = 0;
        owners[_newOwner] = client;
        clients[client].owner = _newOwner;
        ClientOwnerChanged(client, msg.sender, _newOwner);
    }

    function addRelease(bytes32 _release, uint32 _forkBlock, uint8 _track, uint24 _semver) only_client_owner {
        var client = owners[msg.sender];
        clients[client].release[_release] = Release(_forkBlock, _track, _semver);
        ReleaseAdded(client, _forkBlock, _release, _track, _semver);
    }

    function addChecksum(bytes32 _release, bytes32 _platform, bytes32 _checksum) only_client_owner {
        var client = owners[msg.sender];
        clients[client].build[_checksum] = Build(_release, _platform);
        ChecksumAdded(client, _release, _platform, _checksum);
    }

    // Admin functions

    function addClient(bytes32 _client, address _owner) only_owner {
        clients[_client].owner = _owner;
        owners[_owner] = _client;
        ClientAdded(_client, _owner);
    }

    function removeClient(bytes32 _client) only_owner {
        setClientRequired(_client, false);
        resetClientOwner(_client, 0);
        delete clients[_client];
        ClientRemoved(_client);
    }

    function resetClientOwner(bytes32 _client, address _newOwner) only_owner {
        var old = clients[_client].owner;
        ClientOwnerChanged(_client, old, _newOwner);
        owners[old] = 0;
        owners[_newOwner] = _client;
        clients[_client].owner = _newOwner;
    }

    function setClientRequired(bytes32 _client, bool _r) only_owner when_changing_required(_client, _r) {
        ClientRequiredChanged(_client, _r);
        clients[_client].required = _r;
        clientsRequired = _r ? clientsRequired + 1 : (clientsRequired - 1);
        checkFork();
    }

    function setOwner(address _newOwner) only_owner {
        OwnerChanged(owner, _newOwner);
        owner = _newOwner;
    }

    // Getters

    function isLatest(bytes32 _client, bytes32 _release) constant returns (bool) {
        return latestInTrack(_client, track(_client, _release)) == _release;
    }

    function track(bytes32 _client, bytes32 _release) constant returns (uint8) {
        return clients[_client].release[_release].track;
    }

    function latestInTrack(bytes32 _client, uint8 _track) constant returns (bytes32) {
        return clients[_client].current[_track];
    }

    function findChecksum(bytes32 _client, bytes32 _checksum) constant returns (bytes32 o_release, bytes32 o_platform) {
        var b = clients[_client].build[_checksum];
        o_release = b.release;
        o_platform = b.platform;
    }

    // Internals

    function noteAccepted(bytes32 _client) internal when_required(_client) {
        forks[proposedFork].requiredCount += 1;
        checkFork();
    }

    function noteRejected(bytes32 _client) internal when_required(_client) {
        ForkRejected(proposedFork);
        delete forks[proposedFork];
        proposedFork = 0;
    }

    function checkFork() internal when_have_all_required {
        ForkRatified(proposedFork);
        forks[proposedFork].ratified = true;
        latestFork = proposedFork;
        proposedFork = 0;
    }

    function checkProxy(bytes32 _txid) internal when_proxy_confirmed(_txid) returns (uint txSuccess) {
        var tx = proxy[_txid];
        var success = tx.to.call.value(tx.value).gas(tx.gas)(tx.data);
        TransactionRelayed(_txid, success);
        txSuccess = success ? 2 : 1;
        delete proxy[_txid];
    }

    // Modifiers

    modifier only_owner { if (owner != msg.sender) throw; _; }
    modifier only_client_owner { var client = owners[msg.sender]; if (client == 0) throw; _; }
    modifier only_required_client_owner { var client = owners[msg.sender]; if (!clients[client].required) throw; _; }
    modifier only_ratified{ if (!forks[proposedFork].ratified) throw; _; }
    modifier only_unratified { if (!forks[proposedFork].ratified) throw; _; }
    modifier only_undecided_client_owner {
        var client = owners[msg.sender];
        if (client == 0)
            throw;
        if (forks[proposedFork].status[client] != Status.Undecided)
            throw;
        _;
    }
    modifier only_when_none_proposed { if (proposedFork != 0) throw; _; }
    modifier only_when_proxy(bytes32 _txid) { if (proxy[_txid].requiredCount == 0) throw; _; }
    modifier only_when_no_proxy(bytes32 _txid) { if (proxy[_txid].requiredCount > 0) throw; _; }
    modifier only_when_proxy_undecided(bytes32 _txid) { if (proxy[_txid].status[owners[msg.sender]] != Status.Undecided) throw; _; }

    modifier when_fork { if (forks[proposedFork].name == 0) throw; _; }
    modifier when_required(bytes32 _client) { if (clients[_client].required) _; }
    modifier when_have_all_required { if (forks[proposedFork].requiredCount >= clientsRequired) _; }
    modifier when_changing_required(bytes32 _client, bool _r) { if (clients[_client].required != _r) _; }
    modifier when_proxy_confirmed(bytes32 _txid) { if (proxy[_txid].requiredCount >= clientsRequired) _; }

    mapping (uint32 => Fork) public forks;
    mapping (bytes32 => Client) public clients;
    mapping (address => bytes32) public owners;
    mapping (bytes32 => Transaction) public proxy;

    uint32 public clientsRequired;
    uint32 public latestFork;
    uint32 public proposedFork;
    address public owner = msg.sender;
}
