// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundme} from "../../script/DeployFundMe.s.sol";

contract TestFundMe is Test {
    uint256 constant send_val = 10 ether; ////100000000000000000
    uint256 constant starting_Balance = 10 * 1 ether;
    uint256 constant Gas_Price = 1;
    FundMe fundMe;
    address User = makeAddr("User");

    function setUp() external {
        // fundMe = new FundMe();
        DeployFundme deployFundMe = new DeployFundme();
        fundMe = deployFundMe.run();
        vm.deal(User, starting_Balance);
    }

    function testFundMe() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public view {
        //     console.log(fundMe.i_owner());
        //     console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsDueToETH() public {
        vm.expectRevert();
        //The next line revert
        //assert(this tx fails/revert)
        fundMe.getfund();
    }

    function testUpdateFund() public {
        vm.startPrank(User);

        fundMe.getfund{value: send_val}();

        uint256 fundingAmount = fundMe.getAddresstoAmountFunded(User);
        assertEq(send_val, fundingAmount);
    }

    function testArrayFunder() public {
        vm.prank(User);
        fundMe.getfund{value: send_val}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, User);
    }

    modifier onlyFunded() {
        vm.prank(User);
        fundMe.getfund{value: send_val}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public onlyFunded {
        vm.expectRevert(); //next line should revert/ignore the next line
        vm.prank(User); //user is now the owner
        fundMe.withdraw();
    }

    function testSingleWithdraw() public onlyFunded {
        uint256 StaringOwnerBalance = fundMe.getOwner().balance;
        uint256 StartingfundMeBalance = address(fundMe).balance;

        //Act

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 EndingOwnerBalance = fundMe.getOwner().balance;
        uint256 EndingfundMeBalance = address(fundMe).balance;

        assertEq(EndingfundMeBalance, 0);
        assertEq(EndingOwnerBalance, StaringOwnerBalance + StartingfundMeBalance);
    }

    function testMultipalWithdraw() public onlyFunded {
        //Arrange
        uint160 numberOfFunder = 10;
        uint160 startingFunderIndex = 1;
        /*
        vm.prank()new address;
        vm.deal()//new address;
        address

        ***/
        for (uint160 i = startingFunderIndex; i < numberOfFunder; i++) {
            hoax(address(i), send_val);
            fundMe.getfund{value: send_val}();
        }
        //Act
        uint256 StartingOwnerBalance = fundMe.getOwner().balance;
        uint256 StartingfundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        //Assert
        assert(address(fundMe).balance == 0);
        assert(StartingfundMeBalance + StartingOwnerBalance == fundMe.getOwner().balance);
    }
}
