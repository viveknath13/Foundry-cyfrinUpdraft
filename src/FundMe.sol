// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    address[] private s_funders;

    mapping(address => uint256) private s_amount_Funded_thorugh_address;

    uint256 public constant MINIMUM_USD = 5e18;

    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    modifier onlyowner() {
        //     require(msg.sender == i_owner, "Hey you are not the owner...");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function getfund() public payable {
        require(msg.value.getconversionRate(s_priceFeed) >= MINIMUM_USD, "Please send enough money.");

        s_funders.push(msg.sender);
        s_amount_Funded_thorugh_address[msg.sender] += msg.value;
    }

    function cheperWithdraw() public onlyowner {
        uint256 fundersLength = s_funders.length;

        for (uint256 i = 0; i < fundersLength; i++) {
            address ownerOfFund = s_funders[i];
            s_amount_Funded_thorugh_address[ownerOfFund] = 0;
        }
        s_funders = new address[](0); //reset the array

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    function withdraw() public onlyowner {
        for (uint256 i = 0; i < s_funders.length; i++) {
            address ownerOfFund = s_funders[i];
            s_amount_Funded_thorugh_address[ownerOfFund] = 0;
        }
        s_funders = new address[](0); //reset the array

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    receive() external payable {}

    fallback() external payable {
        getfund();
    }

    function getAddresstoAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_amount_Funded_thorugh_address[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
