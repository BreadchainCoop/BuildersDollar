// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import 'forge-std/console.sol';
import 'forge-std/StdJson.sol';
import {Script} from 'forge-std/Script.sol';
import {TransparentUpgradeableProxy} from '@oz/proxy/transparent/TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from '@oz/proxy/transparent/ProxyAdmin.sol';
import {OBDYieldDistributor, IOBDYieldDistributor} from 'contracts/OBDYieldDistributor.sol';

/// @dev used to deploy the YieldDistributor contract for scripts and tests
contract Common is Script {
  string internal _configData;
  address internal _admin;
  address internal _token;
  address internal _eas;

  uint256 internal _seasonDuration;
  uint64 internal _currentSeasonExpiry;
  uint64 internal _cycleLength;

  address[] internal _projects;

  IOBDYieldDistributor.YieldDistributorParams internal _params;
  IOBDYieldDistributor public obdYieldDistributor;

  function _readConfigFile(string memory _path) internal {
    _configData = vm.readFile(_path);
    _admin = stdJson.readAddress(_configData, '._admin');
    _eas = stdJson.readAddress(_configData, '._eas');
    _token = stdJson.readAddress(_configData, '._token');
    _projects = abi.decode(stdJson.parseRaw(_configData, '._projects'), (address[]));

    _params = IOBDYieldDistributor.YieldDistributorParams({
      cycleLength: stdJson.readUint(_configData, '._cycleLength'),
      lastClaimedTimestamp: stdJson.readUint(_configData, '._lastClaimedTimestamp'),
      minVouches: stdJson.readUint(_configData, '._minVouches'),
      precision: stdJson.readUint(_configData, '._precision')
    });
  }

  function _generateMockDataForTest() internal {}

  function _deployContracts(address _deployer) internal {
    bytes memory _implementationData =
      abi.encodeWithSelector(OBDYieldDistributor.initialize.selector, _token, _rewardToken, _params, _projects);

    address _implementation = address(new OBDYieldDistributor());
    address _proxy = address(new TransparentUpgradeableProxy(_implementation, _admin, _implementationData));
    console.log('Deployed YieldDistributor at address: {}', _proxy);

    obdYieldDistributor = YieldDistributor(_proxy);
  }
}
