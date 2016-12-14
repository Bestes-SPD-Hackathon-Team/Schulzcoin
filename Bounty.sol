//! Bounty contract.
//! By Gav Wood (Ethcore), 2016.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.6;

/// Bounty contract to pay out when an address is compromised. Allows for a
/// referee to cancel the claim for arbitrary reasons; we assume that the
/// referee is trustworthy.
contract Bounty
{
    /// Simple constant to denote no active claim.
    address constant NO_CLAIM = 0;

    // State
    /// The owner of this contract - they alone can claim the funds.
    address public owner;
    /// The referee of this contract - they alone can block the claimant.
    address public referee;
    /// The claimant's address - when the owner claims, this is when the funds go.
    /// If no claim is in progress, this is equal to NO_CLAIM.
    address public claimant = NO_CLAIM;
    /// The current claim's payday. Meaningless when claimant == NO_CLAIM.
    uint32 public payday = 0;
    /// The amounts deposited by each creditor.
    mapping ( address => uint ) public balance;

    // Gates
    /// Only to be executed by the owner.
    modifier only_owner { if (msg.sender == owner) _; }
    /// Only to be executed by the referee.
    modifier only_referee { if (msg.sender == referee) _; }
    /// Only to be executed when there is an active claim and by its claimant.
    modifier only_claimant { if (msg.sender == claimant) _; }
    /// Only to be executed by an account with at least `x` in their balance.
    /// Implies: `when_claim`.
    modifier only_with_at_least(uint x) { if (balance[msg.sender] >= x) _; }
    /// Only to be executed when there is an active claim.
    modifier when_claim { if (claimant != NO_CLAIM) _; }
    /// Only to be executed when there is no active claim.
    modifier when_no_claim { if (claimant == NO_CLAIM) _; }
    /// Only to be executed after the payday of the active claim.
    /// Requires: `when_claim`.
    modifier after_payday { if (uint32(now) > payday) _; }

    // Events
    /// Deposit made of `wei(value)` into the bounty pot by `who`.
    event Deposit(address indexed who, uint value);
    /// Withdrawal from the bounty pot by `who` for the amount of `wei(value)`.
    event Withdrawal(address indexed who, uint value);
    /// Claim made to pay `who` the bounty pot.
    event Claim(address indexed who);
    /// Claim of `who` for `wei(amount)` was paid from the bounty pot.
    event Payout(address indexed who, uint amount);
    /// Claim of `who` for `wei(amount)` was cancelled.
    event Cancelation(address indexed who, uint amount);

    /// Construct a new bounty contract with `_referee` acting as the referee.
    function Bounty(address _referee) {
        referee = _referee;
        owner = msg.sender;
    }

    /// Add `wei(msg.value)` into the balance of `msg.sender`'s account.
    function() {
        Deposit(msg.sender, msg.value);
        balance[msg.sender] += msg.value;
    }

    /// Withdraw `wei(_amount)` from the balance of `msg.sender`'s account.
    function withdraw(uint _amount) only_with_at_least(_amount) when_no_claim {
        Withdrawal(msg.sender, _amount);
        balance[msg.sender] -= _amount;
        if (!msg.sender.send(_amount))
            throw;
    }

    /// Begin claim process; register `_claimant` as the beneficiary and the
    /// pay-day as 7 days from `time(now)`.
    function claim(address _claimant) only_owner when_no_claim {
        Claim(claimant);
        payday = uint32(now) + 7 days;
        claimant = _claimant;
    }

    /// Finalise claim process with a payout; pays all funds into to `claimant`
    /// and suicides.
    function payout() only_claimant after_payday {
        Payout(claimant, address(this).balance);
        if (!claimant.send(address(this).balance))
            throw;
        suicide(0);
    }

    /// Cancel the claim by `claimant`.
    function cancel() only_referee when_claim {
        Cancelation(claimant, address(this).balance);
        payday = 0;
        claimant = NO_CLAIM;
    }
}
