// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        AggregatorV3Interface PriceFedd = AggregatorV3Interface(priceFeed);
        (, int256 price,,,) = PriceFedd.latestRoundData();
        return uint256(price * 1e10);
    }

    function getconversionRate(uint256 EthAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * EthAmount) / 1e18;
        return ethAmountInUsd;
    }
}
