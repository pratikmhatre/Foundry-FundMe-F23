// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    Config public activeConfig;
    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 1) {
            activeConfig = getMainNetConfig();
        } else if (block.chainid == 11155111) {
            activeConfig = getSepoliaConfig();
        } else {
            //chainid = 31337
            activeConfig = getOrCreateAnvilConfig();
        }
    }

    struct Config {
        address priceFeed;
    }

    function getOrCreateAnvilConfig() internal returns (Config memory) {
        //if mock contract is already deployed on anvil, return its address
        // if (activeConfig.priceFeed != address(0)) return existing pricefeed address;

        vm.startBroadcast();
        MockV3Aggregator mockAggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        return Config({priceFeed: address(mockAggregator)});
    }

    function getSepoliaConfig() internal pure returns (Config memory) {
        return Config({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    function getMainNetConfig() internal pure returns (Config memory) {
        return Config({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    }
}
