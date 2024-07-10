// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.21;

import "../../src/experiments/LastCallJackpot.sol";
import "@forge-std/Test.sol";

contract LastCallJackpotTest is Test {
    LastCallJackpot private lastCallJackpot;

    address private owner = makeAddr("owner");
    address private alice = makeAddr("alice");
    address private bob = makeAddr("bob");

    function setUp() public {
        // Fund accounts.
        vm.deal(owner, 10000 ether);
        vm.deal(alice, 1000 ether);
        vm.deal(bob, 1000 ether);

        // Deploy contract.
        vm.startPrank(owner);
        lastCallJackpot = new LastCallJackpot{value: 1000 ether}();
        console2.log("LastCallJackpot deployed");
        vm.stopPrank();
    }

    // This is just a test to make sure the call method works.
    function test_SingleCall() public {
        vm.startPrank(alice);
        lastCallJackpot.call{value: 1 ether}();
        vm.stopPrank();

        assertEq(lastCallJackpot.lastBlock(), block.number);
        assertEq(lastCallJackpot.lastCaller(), alice);
        assertEq(address(lastCallJackpot).balance, 1001 ether);
        assertEq(alice.balance, 999 ether);
        console2.log("Alice calls the contract");
    }

    // This is another test to make sure that one can win the jackpot according to the rules.
    function test_WinJackpot() public {
        uint256 bn = block.number;

        // Alice calls the contract.
        vm.startPrank(alice);
        lastCallJackpot.call{value: 1 ether}();
        vm.stopPrank();

        assertEq(lastCallJackpot.lastBlock(), block.number);
        assertEq(lastCallJackpot.lastCaller(), alice);
        assertEq(address(lastCallJackpot).balance, 1001 ether);
        assertEq(alice.balance, 999 ether);
        console2.log("Alice calls the contract");

        // 10 blocks have passed without anyone calling the contract.
        vm.roll(bn + 10);
        console2.log("10 blocks have passed");

        // Bob calls the contract and Alice wins the jackpot.
        vm.startPrank(bob);
        lastCallJackpot.call{value: 1 ether}();
        vm.stopPrank();

        assertEq(lastCallJackpot.lastBlock(), block.number);
        assertEq(lastCallJackpot.lastCaller(), bob);
        console2.log("Bob calls the contract");

        assertEq(address(lastCallJackpot).balance, 0 ether);
        assertEq(alice.balance, 999 ether + 1_001 ether + 1 ether);
        console2.log("Alice wins the jackpot");
    }

    // This is another test to make sure that one can only win the jackpot if nobody called the contract for 10 blocks.
    // This scenario
    function test_MultiCall() public {
        uint256 bn = block.number;

        // Alice calls the contract.
        vm.startPrank(alice);
        lastCallJackpot.call{value: 1 ether}();
        vm.stopPrank();

        assertEq(lastCallJackpot.lastBlock(), block.number);
        assertEq(lastCallJackpot.lastCaller(), alice);
        assertEq(address(lastCallJackpot).balance, 1001 ether);
        assertEq(alice.balance, 999 ether);
        console2.log("Alice calls the contract");

        // 9 blocks have passed without anyone calling the contract.
        vm.roll(bn + 9);
        console2.log("9 blocks have passed");

        // Bob calls the contract and nobody wins the jackpot.
        vm.startPrank(bob);
        lastCallJackpot.call{value: 1 ether}();
        vm.stopPrank();

        assertEq(lastCallJackpot.lastBlock(), block.number);
        assertEq(lastCallJackpot.lastCaller(), bob);
        assertEq(address(lastCallJackpot).balance, 1002 ether);
        assertEq(bob.balance, 999 ether);
        console2.log("Bob calls the contract");
        console2.log("Nobody wins the jackpot");
    }
}
