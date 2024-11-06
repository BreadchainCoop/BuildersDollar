// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import 'script/Constants.s.sol';
import {Test} from 'forge-std/Test.sol';
import {Common} from 'script/deploy/Common.s.sol';

contract Base is Common, Test {
/**
 * string public deployConfigPath = string(bytes('./test/deployYD.json'));
 *
 *   Bread public bread;
 *   YieldDistributorTestWrapper public yieldDistributor;
 *
 *   IYieldDistributor.YieldDistributorParams public params;
 *
 *   function setUp() public virtual {
 *     vm.createSelectFork(vm.rpcUrl('gnosis'));
 *     _readJson(deployConfigPath);
 *     _deployContracts(address(this));
 *
 *     bread = Bread(address(_baseToken));
 *     yieldDistributor = YieldDistributorTestWrapper(address(yieldDistributorProxy));
 *     params = yieldDistributor.params();
 *
 *     vm.prank(bread.owner());
 *     bread.setYieldClaimer(address(yieldDistributorProxy));
 *   }
 *
 *   // --- Internal Helper Methods ---
 *
 *   function _setUpForCycle(YieldDistributorTestWrapper _yieldDistributor) internal {
 *     vm.roll(START - params.cycleLength);
 *     _yieldDistributor.setLastClaimedBlockNumber(vm.getBlockNumber());
 *     address owner = bread.owner();
 *     vm.prank(owner);
 *     bread.setYieldClaimer(address(_yieldDistributor));
 *     vm.roll(START);
 *   }
 *
 *   function _setUpAccountsForVoting(address[] memory accounts) internal {
 *     vm.roll(START - params.cycleLength + 1);
 *     for (uint256 i = 0; i < accounts.length; i++) {
 *       vm.deal(accounts[i], MINIMUM_VOTE);
 *       vm.prank(accounts[i]);
 *       bread.mint{value: MINIMUM_VOTE}(accounts[i]);
 *     }
 *   }
 */
}
