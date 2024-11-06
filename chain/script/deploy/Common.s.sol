// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import 'forge-std/console.sol';
import 'forge-std/StdJson.sol';
import {Script} from 'forge-std/Script.sol';
import {TransparentUpgradeableProxy} from '@openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from '@openzeppelin/proxy/transparent/ProxyAdmin.sol';
import {YieldDistributor, IYieldDistributor} from 'contracts/YieldDistributor.sol';

/// @dev used to deploy the YieldDistributor contract for scripts and tests
contract Common is Script {
  address internal _admin;
  address internal _baseToken;
  IYieldDistributor.YieldDistributorParams internal _params;
  address[] internal _projects;

  YieldDistributor public yieldDistributorProxy;

  function _readJson(string memory _path) internal {
    string memory _configData = vm.readFile(_path);

    _admin = stdJson.readAddress(_configData, '._admin');
    _baseToken = stdJson.readAddress(_configData, '._baseToken');

    _params = IYieldDistributor.YieldDistributorParams({
      currentVotes: 0,
      cycleLength: stdJson.readUint(_configData, '._cycleLength'),
      lastClaimedBlock: stdJson.readUint(_configData, '._lastClaimedBlock'),
      maxPoints: stdJson.readUint(_configData, '._maxPoints'),
      minRequiredVotingPower: stdJson.readUint(_configData, '._minRequiredVotingPower'),
      precision: stdJson.readUint(_configData, '._precision'),
      prevCycleStartBlock: 0,
      yieldFixedSplitDivisor: stdJson.readUint(_configData, '._yieldFixedSplitDivisor')
    });

    _projects = abi.decode(stdJson.parseRaw(_configData, '._projects'), (address[]));
  }

  function _deployContracts(address _deployer) internal {
    // TODO: add RewardToken contract deployment - just use precompute for now
    uint256 _nonce = 4; // if done immediately after this script? TODO: add to current nonce of use CREATE2
    address _rewardToken = computeCreateAddress(_deployer, _nonce);

    bytes memory _implementationData =
      abi.encodeWithSelector(YieldDistributor.initialize.selector, _baseToken, _rewardToken, _params, _projects);

    address _implementation = address(new YieldDistributor());
    address _proxy = address(new TransparentUpgradeableProxy(_implementation, _admin, _implementationData));
    console.log('Deployed YieldDistributor at address: {}', _proxy);

    yieldDistributorProxy = YieldDistributor(_proxy);
  }
}
