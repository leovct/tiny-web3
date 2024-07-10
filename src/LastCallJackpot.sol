// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.21;

/// @notice Interface for TinyENS.
interface ILastCallJackpot {
    /// @notice Call the contract and attempt to win the jackpot.
    function call() external payable;
}

/// @title A game where the last caller, before a 10-block inactivity period, wins the entire contract's ETH balance.
/// @author leovct
/// @notice https://www.paradigm.xyz/2024/06/paradigm-fellowship-2024
/// An Ethereum contract is funded with 1,000 ETH. It costs 1 ETH to call, which is added to the balance.
/// If the contract isn't called for 10 blocks, the last caller gets the entire ETH balance.
/// How might this game unfold and end? Describe your thinking.
contract LastCallJackpot is ILastCallJackpot {
    /// @notice Track the block number when the last call occurred.
    uint256 public lastBlock;
    /// @notice Store the address of the last caller.
    address public lastCaller;

    /// @notice Log each call made to the contract.
    event Called(address indexed caller, uint256 blockNumber);
    /// @notice Log the transfer of the jackpot amount to the winner.
    event WinnerPaid(address indexed winner, uint256 amount);

    constructor() payable {
        require(msg.value == 50 ether, "Fund the contract with 1000 ETH");
        lastBlock = block.number;
    }

    function call() external payable {
        require(msg.value == 1 ether, "Call the contract with 1 ETH");

        if (block.number >= lastBlock + 10) {
            // Pay the winner.
            uint256 balance = address(this).balance;
            address winner = lastCaller;

            // Update state before external call
            lastBlock = block.number;
            lastCaller = msg.sender;

            payable(winner).transfer(balance);
            emit WinnerPaid(winner, balance);
        } else {
            // Update the last block and caller.
            lastBlock = block.number;
            lastCaller = msg.sender;
            emit Called(msg.sender, block.number);
        }
    }
}
