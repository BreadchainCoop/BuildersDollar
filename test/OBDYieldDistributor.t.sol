// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.22;

import 'script/Constants.s.sol';
import {Base} from 'test/Base.t.sol';
import {IOBDYieldDistributor} from 'interfaces/IOBDYieldDistributor.sol';

contract OBDYieldDistributorTest is Base {
  address[] __attestors;

  function testDeploy() public {
    assertEq(address(obdYieldDistributor.token()), _token);
    assertEq(address(obdYieldDistributor.eas()), _eas);
    assertEq(obdYieldDistributor.SEASON_DURATION(), _seasonDuration);
    assertEq(obdYieldDistributor.currentSeasonExpiry(), _currentSeasonExpiry);

    IOBDYieldDistributor.YieldDistributorParams memory _params = obdYieldDistributor.params();
    assertEq(_params.cycleLength, CYCLE_LENGTH);
    assertEq(_params.lastClaimedTimestamp, LAST_CLAIMED_TIMESTAMP);
    assertEq(_params.minVouches, MIN_VOUCHES);
    assertEq(_params.precision, PRECISION);
  }
}
