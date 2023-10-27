// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import '../src/TinyENS.sol';
import '@forge-std/Test.sol';

contract TinyENSTest is Test {
  TinyENS private tinyENS;

  address private owner = makeAddr('owner');
  address private alice = makeAddr('alice');
  address private bob = makeAddr('bob');

  function setUp() public {
    vm.startPrank(owner);
    tinyENS = new TinyENS();
    console2.log('TinyENS deployed');
    vm.stopPrank();
  }

  function testRegister() public {
    vm.startPrank(alice);
    tinyENS.register('alice.eth');
    vm.stopPrank();

    assertEq(tinyENS.resolve('alice.eth'), alice);
    assertEq(tinyENS.reverse(alice), 'alice.eth');
    console2.log('Alice registed alice.eth');
  }

  function testFailRegister() public {
    vm.startPrank(alice);
    tinyENS.register('alice.eth');
    assertEq(tinyENS.resolve('alice.eth'), alice);
    assertEq(tinyENS.reverse(alice), 'alice.eth');
    console2.log('Alice registed alice.eth');

    console2.log('Bob tries to register alice.eth');
    vm.startPrank(bob);
    tinyENS.register('alice.eth');
    vm.expectRevert(TinyENS.AlreadyRegistered.selector);

    assertEq(tinyENS.resolve('alice.eth'), alice);
    assertEq(tinyENS.reverse(alice), 'alice.eth');
    assertEq(tinyENS.reverse(bob), 'axxxx');
    vm.stopPrank();
  }

  function testUpdate() public {
    vm.startPrank(alice);
    tinyENS.register('alice.eth');
    assertEq(tinyENS.resolve('alice.eth'), alice);
    assertEq(tinyENS.reverse(alice), 'alice.eth');
    console2.log('Alice registed alice.eth');

    tinyENS.register('alice22.eth');
    assertEq(tinyENS.resolve('alice22.eth'), alice);
    assertEq(tinyENS.reverse(alice), 'alice22.eth');
    console2.log('Alice updated its name to alice22.eth');
    vm.stopPrank();
  }

  function testFailUpdate() public {
    vm.startPrank(alice);
    tinyENS.register('alice.eth');
    console2.log('Alice registed alice.eth');

    vm.startPrank(bob);
    tinyENS.register('bob.eth');
    console2.log('Bob registed bob.eth');

    console2.log('Bob tries to update its name to alice.eth');
    tinyENS.update('alice.eth');
    vm.expectRevert(TinyENS.AlreadyRegistered.selector);
    vm.stopPrank();
  }
}
