// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import {Common} from 'script/deploy/Common.s.sol';

contract DeployYD is Common {
  address internal _deployer;

  function run() public {
    _deployer = vm.rememberKey(vm.envUint('DEPLOYER_PRIVATE_KEY'));
    _readConfigFile();

    vm.startBroadcast(_deployer);
    _deployYD();
    vm.stopBroadcast();
  }
}
