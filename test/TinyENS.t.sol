// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.21;

import "../src/TinyENS.sol";
import "@forge-std/Test.sol";

contract TinyENSTest is Test {
    TinyENS private tinyENS;

    address private owner = makeAddr("owner");
    address private alice = makeAddr("alice");
    address private bob = makeAddr("bob");

    function setUp() public {
        vm.startPrank(owner);
        tinyENS = new TinyENS();
        console.log("TinyENS deployed");
        vm.stopPrank();
    }

    function test_RegisterNewName() public {
        vm.startPrank(alice);
        tinyENS.register("alice.eth");
        vm.stopPrank();

        assertEq(tinyENS.resolve("alice.eth"), alice);
        assertEq(tinyENS.reverse(alice), "alice.eth");
        console.log("Alice registed alice.eth");
    }

    function test_RegisterAlreadyRegisteredName() public {
        vm.startPrank(alice);
        tinyENS.register("alice.eth");
        assertEq(tinyENS.resolve("alice.eth"), alice);
        assertEq(tinyENS.reverse(alice), "alice.eth");
        console.log("Alice registed alice.eth");

        console.log("Bob tries to register alice.eth");
        vm.startPrank(bob);
        vm.expectRevert(TinyENS.AlreadyRegistered.selector);
        tinyENS.register("alice.eth");
        assertEq(tinyENS.resolve("alice.eth"), alice);
        assertEq(tinyENS.reverse(alice), "alice.eth");
        assertEq(tinyENS.reverse(bob), "");
        vm.stopPrank();
    }

    function test_UpdateWithNewName() public {
        vm.startPrank(alice);
        tinyENS.register("alice.eth");
        assertEq(tinyENS.resolve("alice.eth"), alice);
        assertEq(tinyENS.reverse(alice), "alice.eth");
        console.log("Alice registed alice.eth");

        tinyENS.register("alice22.eth");
        assertEq(tinyENS.resolve("alice22.eth"), alice);
        assertEq(tinyENS.reverse(alice), "alice22.eth");
        console.log("Alice updated its name to alice22.eth");
        vm.stopPrank();
    }

    function test_UpdateWithAlreadyRegisteredName() public {
        vm.startPrank(alice);
        tinyENS.register("alice.eth");
        console.log("Alice registed alice.eth");

        vm.startPrank(bob);
        tinyENS.register("bob.eth");
        console.log("Bob registed bob.eth");

        console.log("Bob tries to update its name to alice.eth");
        vm.expectRevert(TinyENS.AlreadyRegistered.selector);
        tinyENS.update("alice.eth");
        assertEq(tinyENS.resolve("alice.eth"), alice);
        assertEq(tinyENS.reverse(alice), "alice.eth");
        assertEq(tinyENS.resolve("bob.eth"), bob);
        assertEq(tinyENS.reverse(bob), "bob.eth");
        vm.stopPrank();
    }
}
