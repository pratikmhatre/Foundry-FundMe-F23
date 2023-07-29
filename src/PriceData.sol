// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceData {
    function getConversion(
        uint input,
        AggregatorV3Interface aggregator
    ) internal view returns (uint) {
        return (input * getRate(aggregator)) / 1e18;
    }

    //1 ETH -> USD
    function getRate(
        AggregatorV3Interface aggregator
    ) internal view returns (uint) {
        (, int price, , , ) = aggregator.latestRoundData();
        return uint(price * 1e10);
    }
}
