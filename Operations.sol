// Operations contract, by Gavin Wood.
// Copyright Parity Technologies Ltd (UK), 2016.
// This code may be distributed under the terms of the Apache Licence, version 2.

pragma solidity ^0.4.6;

contract Operations {
	uint8 constant Stable = 1;
	uint8 constant Beta = 2;
	uint8 constant Nightly = 3;

<<<<<<< HEAD
	struct Release {
		uint32 forkBlock;
		uint8 track;
		uint24 semver;
		bool critical;
		mapping (bytes32 => bytes32) checksum;      // platform -> checksum
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
		mapping (bytes32 => Build) build;       // checksum -> Build
	}
	
	enum Status {
		Undecided,
		Accepted,
		Rejected
	}
	
	struct Fork {
		bytes32 name;
		bytes32 spec;
		bool hard;
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
	event ForkProposed(bytes32 indexed client, uint32 indexed number, bytes32 indexed name, bytes32 spec, bool hard);
	event ForkAcceptedBy(bytes32 indexed client, uint32 indexed number);
	event ForkRejectedBy(bytes32 indexed client, uint32 indexed number);
	event ForkRejected(uint32 indexed forkNumber);
	event ForkRatified(uint32 indexed forkNumber);
	event ReleaseAdded(bytes32 indexed client, uint32 indexed forkBlock, bytes32 release, uint8 track, uint24 semver, bool indexed critical);
	event ChecksumAdded(bytes32 indexed client, bytes32 indexed release, bytes32 indexed platform, bytes32 checksum);
	event ClientAdded(bytes32 indexed client, address owner);
	event ClientRemoved(bytes32 indexed client);
	event ClientOwnerChanged(bytes32 indexed client, address indexed old, address indexed now);
	event ClientRequiredChanged(bytes32 indexed client, bool now);
	event OwnerChanged(address old, address now);
	
	function Operations() {
		fork[0] = Fork("frontier", sha3("frontier"), true, true, 0);
		fork[1150000] = Fork("homestead", sha3("homestead"), true, true, 0);
		fork[2463000] = Fork("eip150", sha3("eip150"), true, true, 0);
		fork[2675000] = Fork("eip155", sha3("eip155"), true, true, 0);
		latestFork = 2675000;
=======
    struct Release {
        uint32 forkBlock;
        uint8 track;
        uint24 semver;
        bool critical;
        mapping (bytes32 => bytes32) checksum;      // platform -> checksum
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
        mapping (bytes32 => Build) build;       // checksum -> Build
    }

    enum Status {
        Undecided,
        Accepted,
        Rejected
    }

    struct Fork {
        bytes32 name;
        bytes32 spec;
        bool hard;
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
    event ForkProposed(bytes32 indexed client, uint32 indexed number, bytes32 indexed name, bytes32 spec, bool hard);
    event ForkAcceptedBy(bytes32 indexed client, uint32 indexed number);
    event ForkRejectedBy(bytes32 indexed client, uint32 indexed number);
    event ForkRejected(uint32 indexed forkNumber);
    event ForkRatified(uint32 indexed forkNumber);
    event ReleaseAdded(bytes32 indexed client, uint32 indexed forkBlock, bytes32 release, uint8 track, uint24 semver, bool indexed critical);
    event ChecksumAdded(bytes32 indexed client, bytes32 indexed release, bytes32 indexed platform, bytes32 checksum);
    event ClientAdded(bytes32 indexed client, address owner);
    event ClientRemoved(bytes32 indexed client);
    event ClientOwnerChanged(bytes32 indexed client, address indexed old, address indexed now);
    event ClientRequiredChanged(bytes32 indexed client, bool now);
    event OwnerChanged(address old, address now);

    function Operations() {
        fork[0] = Fork("frontier", sha3("frontier"), true, true, 0);
        fork[1150000] = Fork("homestead", sha3("homestead"), true, true, 0);
        fork[2463000] = Fork("eip150", sha3("eip150"), true, true, 0);
        fork[2675000] = Fork("eip155", sha3("eip155"), true, true, 0);
        latestFork = 2675000;
>>>>>>> origin/master

		client["parity"] = Client(msg.sender, true);
		clientOwner[msg.sender] = "parity";
		clientsRequired = 1;

<<<<<<< HEAD
		client["parity"].release[0x080ec8043f41e25ee8aa4ee6112906ac6d82ea74] = Release(2463000, Stable, 0x01030b, false);
		client["parity"].release[0xb14aed734e1f16676b2ec442b1b5a63d86f7bb5d] = Release(2463000, Beta, 0x010402, false);
		
		client["parity"].release[0x080ec8043f41e25ee8aa4ee6112906ac6d82ea74] = Release(2675000, Stable, 0x01030c, false);
		client["parity"].release[0x1cd3e0f1cd91743df7cecb3d2d6d15dd372c6f1a] = Release(2675000, Beta, 0x010403, false);
		
		client["parity"].release[0xb669dbb39025e49e82dc80fff464ba3e24fccf46] = Release(2675000, Stable, 0x01030d, true);
		client["parity"].current[Stable] = 0xb669dbb39025e49e82dc80fff464ba3e24fccf46;
=======
        client["parity"].release[0x080ec8043f41e25ee8aa4ee6112906ac6d82ea74] = Release(2463000, Stable, 0x01030b, false);
        client["parity"].release[0xb14aed734e1f16676b2ec442b1b5a63d86f7bb5d] = Release(2463000, Beta, 0x010402, false);

        client["parity"].release[0x080ec8043f41e25ee8aa4ee6112906ac6d82ea74] = Release(2675000, Stable, 0x01030c, false);
        client["parity"].release[0x1cd3e0f1cd91743df7cecb3d2d6d15dd372c6f1a] = Release(2675000, Beta, 0x010403, false);

        client["parity"].release[0xb669dbb39025e49e82dc80fff464ba3e24fccf46] = Release(2675000, Stable, 0x01030d, true);
        client["parity"].current[Stable] = 0xb669dbb39025e49e82dc80fff464ba3e24fccf46;
>>>>>>> origin/master

		client["parity"].release[0xa68d52ca955421631ebebe96a8d9daa2ea09269d] = Release(2675000, Beta, 0x010404, true);
		client["parity"].current[Beta] = 0xa68d52ca955421631ebebe96a8d9daa2ea09269d;

		client["parity"].release[0xa68d52ca955421631ebebe96a8d9daa2ea09269d].checksum["x86_64-macos"] = 0x6f6ed2a87b85f27bb95764d190eb0a37204fe938caeb9cf50c1848014c567025;
		client["parity"].build[0x6f6ed2a87b85f27bb95764d190eb0a37204fe938caeb9cf50c1848014c567025] = Build(0xa68d52ca955421631ebebe96a8d9daa2ea09269d, "x86_64-macos");

<<<<<<< HEAD
		client["parity"].release[0x601e0fb0fd7e9e1cec18f8872e8713117cab4e84] = Release(2675000, Nightly, 0x010500, false);
		client["parity"].current[Nightly] = 0x601e0fb0fd7e9e1cec18f8872e8713117cab4e84;
	}
	
	function() payable { Received(msg.sender, msg.value, msg.data); }
	
	// Functions for client owners
	
	function proposeTransaction(bytes32 _txid, address _to, bytes _data, uint _value, uint _gas) only_required_client_owner only_when_no_proxy(_txid) returns (uint txSuccess) {
		var client = clientOwner[msg.sender];
		proxy[_txid] = Transaction(1, _to, _data, _value, _gas);
		proxy[_txid].status[client] = Status.Accepted;
		txSuccess = checkProxy(_txid);
		TransactionProposed(client, _txid, _to, _data, _value, _gas);
	}
	
	function confirmTransaction(bytes32 _txid) only_required_client_owner only_when_proxy(_txid) only_when_proxy_undecided(_txid) returns (uint txSuccess) {
		var client = clientOwner[msg.sender];
		proxy[_txid].status[client] = Status.Accepted;
		proxy[_txid].requiredCount += 1;
		txSuccess = checkProxy(_txid);
		TransactionConfirmed(client, _txid);
	}
	
	function rejectTransaction(bytes32 _txid) only_required_client_owner only_when_proxy(_txid) only_when_proxy_undecided(_txid) {
		delete proxy[_txid];
		TransactionRejected(clientOwner[msg.sender], _txid);
	}
	
	function proposeFork(uint32 _number, bytes32 _name, bool _hard, bytes32 _spec) only_client_owner only_when_none_proposed {
		fork[_number] = Fork(_name, _spec, _hard, false, 0);
		proposedFork = _number;
		ForkProposed(clientOwner[msg.sender], _number, _name, _spec, _hard);
	}

	function acceptFork() only_when_proposed only_undecided_client_owner {
		var newClient = clientOwner[msg.sender];
		fork[proposedFork].status[newClient] = Status.Accepted;
		ForkAcceptedBy(newClient, proposedFork);
		noteAccepted(newClient);
	}
	
	function rejectFork() only_when_proposed only_undecided_client_owner only_unratified {
		var newClient = clientOwner[msg.sender];
		fork[proposedFork].status[newClient] = Status.Rejected;
		ForkRejectedBy(newClient, proposedFork);
		noteRejected(newClient);
	}
	
	function setClientOwner(address _newOwner) only_client_owner {
		var newClient = clientOwner[msg.sender];
		clientOwner[msg.sender] = 0;
		clientOwner[_newOwner] = newClient;
		client[newClient].owner = _newOwner;
		ClientOwnerChanged(newClient, msg.sender, _newOwner);
	}
	
	function addRelease(bytes32 _release, uint32 _forkBlock, uint8 _track, uint24 _semver, bool _critical) only_client_owner {
		var newClient = clientOwner[msg.sender];
		client[newClient].release[_release] = Release(_forkBlock, _track, _semver, _critical);
		client[newClient].current[_track] = _release;
		ReleaseAdded(newClient, _forkBlock, _release, _track, _semver, _critical);
	}
	
	function addChecksum(bytes32 _release, bytes32 _platform, bytes32 _checksum) only_client_owner {
		var newClient = clientOwner[msg.sender];
		client[newClient].build[_checksum] = Build(_release, _platform);
		client[newClient].release[_release].checksum[_platform] = _checksum;
		ChecksumAdded(newClient, _release, _platform, _checksum);
	}
	
	// Admin functions
	
	function addClient(bytes32 _client, address _owner) only_owner {
		client[_client].owner = _owner;
		clientOwner[_owner] = _client;
		ClientAdded(_client, _owner);
	}
	
	function removeClient(bytes32 _client) only_owner {
		setClientRequired(_client, false);
		resetClientOwner(_client, 0);
		delete client[_client];
		ClientRemoved(_client);
	}
	
	function resetClientOwner(bytes32 _client, address _newOwner) only_owner {
		var old = client[_client].owner;
		ClientOwnerChanged(_client, old, _newOwner);
		clientOwner[old] = 0;
		clientOwner[_newOwner] = _client;
		client[_client].owner = _newOwner;
	}
	
	function setClientRequired(bytes32 _client, bool _r) only_owner when_changing_required(_client, _r) {
		ClientRequiredChanged(_client, _r);
		client[_client].required = _r;
		clientsRequired = _r ? clientsRequired + 1 : (clientsRequired - 1);
		checkFork();
	}
	
	function setOwner(address _newOwner) only_owner {
		OwnerChanged(grandOwner, _newOwner);
		grandOwner = _newOwner;
	}
	
	// Getters
	
	function isLatest(bytes32 _client, bytes32 _release) constant returns (bool) {
		return latestInTrack(_client, track(_client, _release)) == _release;
	} 

	function track(bytes32 _client, bytes32 _release) constant returns (uint8) {
		return client[_client].release[_release].track;
	} 

	function latestInTrack(bytes32 _client, uint8 _track) constant returns (bytes32) {
		return client[_client].current[_track];
	}
	
	function build(bytes32 _client, bytes32 _checksum) constant returns (bytes32 o_release, bytes32 o_platform) {
		var b = client[_client].build[_checksum];
		o_release = b.release;
		o_platform = b.platform;
	}
=======
        client["parity"].release[0x601e0fb0fd7e9e1cec18f8872e8713117cab4e84] = Release(2675000, Nightly, 0x010500, false);
        client["parity"].current[Nightly] = 0x601e0fb0fd7e9e1cec18f8872e8713117cab4e84;
    }

    function() payable { Received(msg.sender, msg.value, msg.data); }

    // Functions for client owners

    function proposeTransaction(bytes32 _txid, address _to, bytes _data, uint _value, uint _gas) only_required_client_owner only_when_no_proxy(_txid) returns (uint txSuccess) {
        var client = clientOwner[msg.sender];
        proxy[_txid] = Transaction(1, _to, _data, _value, _gas);
        proxy[_txid].status[client] = Status.Accepted;
        txSuccess = checkProxy(_txid);
        TransactionProposed(client, _txid, _to, _data, _value, _gas);
    }

    function confirmTransaction(bytes32 _txid) only_required_client_owner only_when_proxy(_txid) only_when_proxy_undecided(_txid) returns (uint txSuccess) {
        var client = clientOwner[msg.sender];
        proxy[_txid].status[client] = Status.Accepted;
        proxy[_txid].requiredCount += 1;
        txSuccess = checkProxy(_txid);
        TransactionConfirmed(client, _txid);
    }

    function rejectTransaction(bytes32 _txid) only_required_client_owner only_when_proxy(_txid) only_when_proxy_undecided(_txid) {
        delete proxy[_txid];
        TransactionRejected(clientOwner[msg.sender], _txid);
    }

    function proposeFork(uint32 _number, bytes32 _name, bool _hard, bytes32 _spec) only_client_owner only_when_none_proposed {
        fork[_number] = Fork(_name, _spec, _hard, false, 0);
        proposedFork = _number;
        ForkProposed(clientOwner[msg.sender], _number, _name, _spec, _hard);
    }

    function acceptFork() only_when_proposed only_undecided_client_owner {
        var newClient = clientOwner[msg.sender];
        fork[proposedFork].status[newClient] = Status.Accepted;
        ForkAcceptedBy(newClient, proposedFork);
        noteAccepted(newClient);
    }

    function rejectFork() only_when_proposed only_undecided_client_owner only_unratified {
        var newClient = clientOwner[msg.sender];
        fork[proposedFork].status[newClient] = Status.Rejected;
        ForkRejectedBy(newClient, proposedFork);
        noteRejected(newClient);
    }

    function setClientOwner(address _newOwner) only_client_owner {
        var newClient = clientOwner[msg.sender];
        clientOwner[msg.sender] = 0;
        clientOwner[_newOwner] = newClient;
        client[newClient].owner = _newOwner;
        ClientOwnerChanged(newClient, msg.sender, _newOwner);
    }

    function addRelease(bytes32 _release, uint32 _forkBlock, uint8 _track, uint24 _semver, bool _critical) only_client_owner {
        var newClient = clientOwner[msg.sender];
        client[newClient].release[_release] = Release(_forkBlock, _track, _semver, _critical);
        client[newClient].current[_track] = _release;
        ReleaseAdded(newClient, _forkBlock, _release, _track, _semver, _critical);
    }

    function addChecksum(bytes32 _release, bytes32 _platform, bytes32 _checksum) only_client_owner {
        var newClient = clientOwner[msg.sender];
        client[newClient].build[_checksum] = Build(_release, _platform);
        client[newClient].release[_release].checksum[_platform] = _checksum;
        ChecksumAdded(newClient, _release, _platform, _checksum);
    }

    // Admin functions

    function addClient(bytes32 _client, address _owner) only_owner {
        client[_client].owner = _owner;
        clientOwner[_owner] = _client;
        ClientAdded(_client, _owner);
    }

    function removeClient(bytes32 _client) only_owner {
        setClientRequired(_client, false);
        resetClientOwner(_client, 0);
        delete client[_client];
        ClientRemoved(_client);
    }

    function resetClientOwner(bytes32 _client, address _newOwner) only_owner {
        var old = client[_client].owner;
        ClientOwnerChanged(_client, old, _newOwner);
        clientOwner[old] = 0;
        clientOwner[_newOwner] = _client;
        client[_client].owner = _newOwner;
    }

    function setClientRequired(bytes32 _client, bool _r) only_owner when_changing_required(_client, _r) {
        ClientRequiredChanged(_client, _r);
        client[_client].required = _r;
        clientsRequired = _r ? clientsRequired + 1 : (clientsRequired - 1);
        checkFork();
    }

    function setOwner(address _newOwner) only_owner {
        OwnerChanged(grandOwner, _newOwner);
        grandOwner = _newOwner;
    }

    // Getters

    function isLatest(bytes32 _client, bytes32 _release) constant returns (bool) {
        return latestInTrack(_client, track(_client, _release)) == _release;
    }

    function track(bytes32 _client, bytes32 _release) constant returns (uint8) {
        return client[_client].release[_release].track;
    }

    function latestInTrack(bytes32 _client, uint8 _track) constant returns (bytes32) {
        return client[_client].current[_track];
    }

    function build(bytes32 _client, bytes32 _checksum) constant returns (bytes32 o_release, bytes32 o_platform) {
        var b = client[_client].build[_checksum];
        o_release = b.release;
        o_platform = b.platform;
    }
>>>>>>> origin/master

	function release(bytes32 _client, bytes32 _release) constant returns (uint32 o_forkBlock, uint8 o_track, uint24 o_semver, bool o_critical) {
		var b = client[_client].release[_release];
		o_forkBlock = b.forkBlock;
		o_track = b.track;
		o_semver = b.semver;
		o_critical = b.critical;
	}

	function checksum(bytes32 _client, bytes32 _release, bytes32 _platform) constant returns (bytes32) {
		return client[_client].release[_release].checksum[_platform];
	}

<<<<<<< HEAD
	// Internals
	
	function noteAccepted(bytes32 _client) internal when_required(_client) {
		fork[proposedFork].requiredCount += 1;
		checkFork();
	}
	
	function noteRejected(bytes32 _client) internal when_required(_client) {
		ForkRejected(proposedFork);
		delete fork[proposedFork];
		proposedFork = 0;
	}
	
	function checkFork() internal when_have_all_required {
		ForkRatified(proposedFork);
		fork[proposedFork].ratified = true;
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
	
	modifier only_owner { if (grandOwner != msg.sender) throw; _; }
	modifier only_client_owner { var newClient = clientOwner[msg.sender]; if (newClient == 0) throw; _; }
	modifier only_required_client_owner { var newClient = clientOwner[msg.sender]; if (!client[newClient].required) throw; _; }
	modifier only_ratified{ if (!fork[proposedFork].ratified) throw; _; }
	modifier only_unratified { if (!fork[proposedFork].ratified) throw; _; }
	modifier only_undecided_client_owner {
		var newClient = clientOwner[msg.sender];
		if (newClient == 0)
			throw;
		if (fork[proposedFork].status[newClient] != Status.Undecided)
			throw;
		_;
	}
	modifier only_when_none_proposed { if (proposedFork != 0) throw; _; }
	modifier only_when_proposed { if (fork[proposedFork].name == 0) throw; _; }
	modifier only_when_proxy(bytes32 _txid) { if (proxy[_txid].requiredCount == 0) throw; _; }
	modifier only_when_no_proxy(bytes32 _txid) { if (proxy[_txid].requiredCount > 0) throw; _; }
	modifier only_when_proxy_undecided(bytes32 _txid) { if (proxy[_txid].status[clientOwner[msg.sender]] != Status.Undecided) throw; _; }
	
	modifier when_required(bytes32 _client) { if (client[_client].required) _; }
	modifier when_have_all_required { if (fork[proposedFork].requiredCount >= clientsRequired) _; }
	modifier when_changing_required(bytes32 _client, bool _r) { if (client[_client].required != _r) _; }
	modifier when_proxy_confirmed(bytes32 _txid) { if (proxy[_txid].requiredCount >= clientsRequired) _; }

	mapping (uint32 => Fork) public fork;
	mapping (bytes32 => Client) public client;
	mapping (address => bytes32) public clientOwner;
	mapping (bytes32 => Transaction) public proxy;
	
	uint32 public clientsRequired;
	uint32 public latestFork;
	uint32 public proposedFork;
	address public grandOwner = msg.sender;
=======
    // Internals

    function noteAccepted(bytes32 _client) internal when_required(_client) {
        fork[proposedFork].requiredCount += 1;
        checkFork();
    }

    function noteRejected(bytes32 _client) internal when_required(_client) {
        ForkRejected(proposedFork);
        delete fork[proposedFork];
        proposedFork = 0;
    }

    function checkFork() internal when_have_all_required {
        ForkRatified(proposedFork);
        fork[proposedFork].ratified = true;
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

    modifier only_owner { if (grandOwner != msg.sender) throw; _; }
    modifier only_client_owner { var newClient = clientOwner[msg.sender]; if (newClient == 0) throw; _; }
    modifier only_required_client_owner { var newClient = clientOwner[msg.sender]; if (!client[newClient].required) throw; _; }
    modifier only_ratified{ if (!fork[proposedFork].ratified) throw; _; }
    modifier only_unratified { if (!fork[proposedFork].ratified) throw; _; }
    modifier only_undecided_client_owner {
        var newClient = clientOwner[msg.sender];
        if (newClient == 0)
            throw;
        if (fork[proposedFork].status[newClient] != Status.Undecided)
            throw;
        _;
    }
    modifier only_when_none_proposed { if (proposedFork != 0) throw; _; }
    modifier only_when_proposed { if (fork[proposedFork].name == 0) throw; _; }
    modifier only_when_proxy(bytes32 _txid) { if (proxy[_txid].requiredCount == 0) throw; _; }
    modifier only_when_no_proxy(bytes32 _txid) { if (proxy[_txid].requiredCount > 0) throw; _; }
    modifier only_when_proxy_undecided(bytes32 _txid) { if (proxy[_txid].status[clientOwner[msg.sender]] != Status.Undecided) throw; _; }

    modifier when_required(bytes32 _client) { if (client[_client].required) _; }
    modifier when_have_all_required { if (fork[proposedFork].requiredCount >= clientsRequired) _; }
    modifier when_changing_required(bytes32 _client, bool _r) { if (client[_client].required != _r) _; }
    modifier when_proxy_confirmed(bytes32 _txid) { if (proxy[_txid].requiredCount >= clientsRequired) _; }

    mapping (uint32 => Fork) public fork;
    mapping (bytes32 => Client) public client;
    mapping (address => bytes32) public clientOwner;
    mapping (bytes32 => Transaction) public proxy;

    uint32 public clientsRequired;
    uint32 public latestFork;
    uint32 public proposedFork;
    address public grandOwner = msg.sender;
>>>>>>> origin/master
}
