// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import 'script/Constants.s.sol';
import {Test} from 'forge-std/Test.sol';
import {Common} from 'script/deploy/Common.s.sol';

contract Base is Common, Test {
  function setUp() public virtual {
    vm.createSelectFork(vm.rpcUrl('gnosis'));
    _readConfigRegistry();
    _generateMockDataForTest();
    _deployYD();
  }
}
