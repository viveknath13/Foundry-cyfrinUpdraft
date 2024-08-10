// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract Funding is Script {
    uint256 constant SEND_VAL = 0.01 ether;

    function FundFundMe(address recentDeployed) public {
    vm.startBroadcast();
        FundMe(payable(recentDeployed)).getfund{value: SEND_VAL}();
        vm.stopBroadcast();

        console.log("Funding with %s", SEND_VAL);
    }

    function run() external {
        address recentDeployed = DevOpsTools.get_most_recent_deployment("Funding", block.chainid);

        vm.startBroadcast();
        FundFundMe(recentDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFund is Script {
    uint256 constant SEND_VAL = 0.01 ether;

    function WithdrawFundMe(address recentDeployed) public {
    vm.startBroadcast();
        FundMe(payable(recentDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw Funding balance");
    }

    function run() external {
        address recentDeployed = DevOpsTools.get_most_recent_deployment("Funding", block.chainid);

       
        WithdrawFundMe(recentDeployed);

    }
}
