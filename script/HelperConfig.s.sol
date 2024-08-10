// SPDX-License-Identifier: MIT

//Deploy mocks when we are on a local anvil chain
//keep track of contract address across the different chain
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant decimalNumber = 8;
    int256 public initial_price = 2000e8;

    NetWorkConfig public activeNetWorkConfig;

    struct NetWorkConfig {
        address priceFeed;
    }

    //if we are on a local anvil , we deploy mock,
    //Otherwise grab the existing address from the live network

    constructor() {
        if (block.chainid == 11155111) {
            activeNetWorkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetWorkConfig = getEthMainnetConfig();
        } else {
            activeNetWorkConfig = getorCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetWorkConfig memory) {
        //priceFeed Address
        NetWorkConfig memory sepoilaConfig = NetWorkConfig({priceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43});
        return sepoilaConfig;
    }

    function getEthMainnetConfig() public pure returns (NetWorkConfig memory) {
        NetWorkConfig memory EthereumMainnetConfig =
            NetWorkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return EthereumMainnetConfig;
    }

    function getorCreateAnvilEthConfig() public returns (NetWorkConfig memory) {
        //price feed
        //Deploy the mocks
        //return the mocks address

        if (activeNetWorkConfig.priceFeed != address(0)) {
            return activeNetWorkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(decimalNumber, initial_price);
        vm.stopBroadcast();

        NetWorkConfig memory AnvilConfig = NetWorkConfig({priceFeed: address(mockPriceFeed)});

        return AnvilConfig;
    }
}
