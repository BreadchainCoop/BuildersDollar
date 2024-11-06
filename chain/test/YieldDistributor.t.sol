// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import 'script/Constants.s.sol';
import {Base} from 'test/Base.t.sol';

contract YieldDistributorTest is Base {
  address public user1 = makeAddr('user1');
  address public user2 = makeAddr('user2');

  uint256[] blockNumbers;
  uint256[] percentages;
  uint256[] votes;

  function setUp() public virtual override {
    super.setUp();
  }

  function test_simple_distribute() public {
    // Getting the balance of the project before the distribution
    uint256 bread_bal_before = bread.balanceOf(address(this));
    assertEq(bread_bal_before, 0);
    // Getting the amount of yield to be distributed
    uint256 yieldAccrued = bread.yieldAccrued();

    // Setting up a voter
    address[] memory accounts = new address[](1);
    accounts[0] = user1;
    _setUpAccountsForVoting(accounts);

    // Setting up for a cycle
    _setUpForCycle(yieldDistributor);

    // Casting vote and distributing yield
    uint256 vote = 100;
    percentages.push(vote);
    vm.prank(user1);
    yieldDistributor.castVote(percentages);
    yieldDistributor.distributeYield();

    // Getting the balance of the project after the distribution and checking if it similiar to the yield accrued (there may be rounding issues)
    uint256 bread_bal_after = bread.balanceOf(address(this));
    assertGt(bread_bal_after, yieldAccrued - MARGIN_ERROR);
  }
}
