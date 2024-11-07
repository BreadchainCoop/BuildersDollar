// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

// --- Constants for Tests ---

uint256 constant START = 32_323_232_323;
uint256 constant MARGIN_ERROR = 3;
uint256 constant MINIMUM_VOTE = 10 ether;

address constant ADMIN = 0x918dEf5d593F46735f74F9E2B280Fe51AF3A99ad;
address constant TOKEN = 0xa555d5344f6FB6c65da19e403Cb4c1eC4a1a5Ee3;
address constant EAS = address(0x1);
uint256 constant SEASON_DURATION = 30 days;
uint64 constant CURRENT_SEASON_EXPIRY = 32_323_232_323;
uint64 constant CYCLE_LENGTH = 7 days;
uint64 constant LAST_CLAIMED_TIMESTAMP = 32_323_232_323;
uint256 constant MIN_VOUCHES = 3;
uint256 constant PRECISION = 1e18;

address constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
address constant A_DAI = 0x82E64f49Ed5EC1bC6e43DAD4FC8Af9bb3A2312EE;
address constant AAVE_LP = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
address constant AAVE_REWARDS = 0x929EC64c34a17401F460460D4B9390518E5B473e;
string constant BD_NAME = 'Builders Dollar';
string constant BD_SYM = 'OBDUSD';
