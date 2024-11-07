// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import {Common} from 'script/deploy/Common.s.sol';

contract DeployYD is Common {
  string public _configPath = string(bytes('./script/deploy/config/deployYD.json'));

  address internal _deployer;

  function run() public {
    _deployer = vm.rememberKey(vm.envUint('DEPLOYER_PRIVATE_KEY'));
    _readConfigFile(_configPath);

    vm.startBroadcast(_deployer);
    // _deployContracts(_deployer);
    vm.stopBroadcast();
  }
}
