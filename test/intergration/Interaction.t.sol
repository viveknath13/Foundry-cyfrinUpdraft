// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundme} from "../../script/DeployFundMe.s.sol";
import {Funding,WithdrawFund} from "../../script/Interactions.s.sol";

contract TestFundMeIntergration is Test {
    address User = makeAddr("User");
    uint256 constant send_val = 10 ether; ////100000000000000000
    uint256 constant starting_Balance = 10 * 1 ether;
    uint256 constant Gas_Price = 1;
    FundMe fundMe;


    function setUp() external {
        DeployFundme deployFundMe = new DeployFundme();
        fundMe = deployFundMe.run();
        vm.deal(User, starting_Balance);
    }

    function testUserCanFund() public {
        // vm.prank(User);
        // vm.deal(User, 1e18);
        Funding fundFundMe = new Funding();
        fundFundMe.FundFundMe(address(fundMe));


            WithdrawFund withdrawFundMe = new WithdrawFund();

            withdrawFundMe.WithdrawFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);

    }
}
