pragma solidity ^0.4.7;

contract OperationsFace {
	function proposeTransaction(bytes32 _txid, address _to, bytes _data, uint _value, uint _gas) returns (uint txSuccess);
	function confirmTransaction(bytes32 _txid) returns (uint txSuccess);
	function rejectTransaction(bytes32 _txid);
	function proposeFork(uint32 _number, bytes32 _name, bool _hard, bytes32 _spec);
	function acceptFork();
	function rejectFork();
	function setClientOwner(address _newOwner);
	function addRelease(bytes32 _release, uint32 _forkBlock, uint8 _track, uint24 _semver, bool _critical);
	function addChecksum(bytes32 _release, bytes32 _platform, bytes32 _checksum);

	function isLatest(bytes32 _client, bytes32 _release) constant returns (bool);
	function track(bytes32 _client, bytes32 _release) constant returns (uint8);
	function latestInTrack(bytes32 _client, uint8 _track) constant returns (bytes32);
	function build(bytes32 _client, bytes32 _checksum) constant returns (bytes32 o_release, bytes32 o_platform);
	function release(bytes32 _client, bytes32 _release) constant returns (uint32 o_forkBlock, uint8 o_track, uint24 o_semver, bool o_critical);
	function checksum(bytes32 _client, bytes32 _release, bytes32 _platform) constant returns (bytes32);
	
	function clientOwner(address _owner) constant returns (bytes32);
}

/// Specialise proxy wallet. Owner can send transactions unhindered. Delegates
/// can send only particular transactions to a named Operations contract.
contract OperationsProxy {
    function OperationsProxy(address _owner, address _stable, address _beta, address _nightly, address _operations) {
        owner = _owner;
        delegate[1] = _stable;
        delegate[2] = _beta;
        delegate[3] = _nightly;
        operations = OperationsFace(_operations);
    }  

	event Sent(address indexed to, uint value, bytes data);
	event OwnerChanged(address indexed was, address indexed who);
	event DelegateChanged(address indexed was, address indexed who, uint8 indexed track);
	event ConfirmerChanged(address indexed was, address indexed who, uint8 indexed track);
	event AddReleaseRelayed(uint8 indexed track, bytes32 indexed release);
	event AddChecksumRelayed(bytes32 indexed release, bytes32 indexed _platform);
	event NewRequestWaiting(uint8 indexed track, bytes32 hash);
	event RequestConfirmed(uint8 indexed track, bytes32 hash);
	event RequestRejected(uint8 indexed track, bytes32 hash);

	function() only_owner {
	    relay();
	}

	function send(address _to, uint _value, bytes _data) only_owner payable {
		if (!_to.call.value(_value)(_data)) throw;
		Sent(_to, _value, _data);
	}
	
	function setOwner(address _owner) only_owner {
	    OwnerChanged(owner, _owner);
	    owner = _owner;
	}
	
	function setDelegate(address _delegate, uint8 _track) only_owner {
	    DelegateChanged(delegate[_track], _delegate, _track);
	    delegate[_track] = _delegate;
	}

	function setConfirmer(address _confirmer, uint8 _track) only_owner {
	    ConfirmerChanged(confirmer[_track], _confirmer, _track);
	    confirmer[_track] = _confirmer;
	}

	function addRelease(bytes32 _release, uint32 _forkBlock, uint8 _track, uint24 _semver, bool _critical) {
	    if (relayOrConfirm(_track))
	        AddReleaseRelayed(_track, _release);
	    else 
	        trackOfPendingRelease[_release] = _track;
	}
	
	function addChecksum(bytes32 _release, bytes32 _platform, bytes32 _checksum) {
	    var track = trackOfPendingRelease[_release];
	    if (track == 0)
	        track = operations.track(operations.clientOwner(this), _release);
	    if (relayOrConfirm(track))
	        AddChecksumRelayed(_release, _platform);
	}	    
	
	function relayOrConfirm(uint8 _track) internal only_delegate_of_track(_track) returns (bool) {
	    if (confirmer[_track] != 0) {
	        var h = sha3(msg.data);
	        waiting[_track][h] = msg.data;
	        NewRequestWaiting(_track, h);
	        return false;
	    }
	    else {
	        relay();
	        return true;
	    }
	}
	
	function confirm(uint8 _track, bytes32 _hash) only_confirmer_of_track(_track) payable {
	    if (!address(operations).call.value(msg.value)(waiting[_track][_hash])) throw;
	    delete waiting[_track][_hash];
	    RequestConfirmed(_track, _hash);
	}
	
	function reject(uint8 _track, bytes32 _hash) only_confirmer_of_track(_track) {
	    delete waiting[_track][_hash];
	    RequestRejected(_track, _hash);
	}
	
	function relay() internal {
	    if (!address(operations).call.value(msg.value)(msg.data)) throw;
	}
	
	function cleanupRelease(bytes32 _release) only_confirmer_of_track(trackOfPendingRelease[_release]) {
	    delete trackOfPendingRelease[_release];
	}
	
	function kill() only_owner {
	    suicide(msg.sender);
	}

	modifier only_owner { if (msg.sender != owner) throw; _; }
	modifier only_delegate_of_track(uint8 track) { if (delegate[track] != msg.sender) throw; _; }
	modifier only_confirmer_of_track(uint8 track) { if (confirmer[track] != msg.sender) throw; _; }
	
    address public owner;
    mapping(uint8 => address) public delegate;
    mapping(uint8 => address) public confirmer;
    mapping(uint8 => mapping(bytes32 => bytes)) public waiting;
    mapping(bytes32 => uint8) public trackOfPendingRelease;
    OperationsFace public operations;
}
