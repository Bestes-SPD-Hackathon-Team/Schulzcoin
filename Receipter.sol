//! Receipting contract. Just records who sent what.
//! By Parity Technologies, 2017.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.7;

contract Receipter {
    function Receipter(address _admin, address _treasury, uint _beginBlock, uint _endBlock) {
        admin = _admin;
        treasury = _treasury;
        beginBlock = _beginBlock;
        endBlock = _endBlock;
    }

    modifier only_admin { if (msg.sender != admin) throw; _; }
    modifier only_before_period { if (block.number >= beginBlock) throw; _; }
    modifier only_during_period { if (block.number < beginBlock || block.number >= endBlock || isHalted) throw; _; }
    modifier only_during_halted_period { if (block.number < beginBlock || block.number >= endBlock || !isHalted) throw; _; }
    modifier only_after_period { if (block.number < endBlock || isHalted) throw; _; }
    modifier is_not_dust { if (msg.value < dust) throw; _; }

    event Purchased(address indexed recipient, uint amount);
    event Halted();
    event Unhalted();

    function() payable {
        receiveFrom(msg.sender);
    }

    function receiveFrom(address _recipient) payable only_during_period is_not_dust {
        if (!treasury.call.value(msg.value)()) throw;
        record[_recipient] += msg.value;
        total += msg.value;
        Purchased(_recipient, msg.value);
    }

    function halt() only_admin only_during_period {
        isHalted = true;
        Halted();
    }

    function unhalt() only_admin only_during_halted_period {
        isHalted = false;
        Unhalted();
    }

    function kill() only_admin only_after_period {
        suicide(treasury);
    }

    uint public constant dust = 100 finney;

    address public admin;
    address public treasury;
    uint public beginBlock;
    uint public endBlock;

    bool public isHalted = false;

    mapping (address => uint) public record;
    uint public total = 0;
}
