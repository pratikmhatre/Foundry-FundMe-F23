//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceData} from "./PriceData.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NonAuth();

contract FundMe {
    AggregatorV3Interface private immutable i_aggregator;
    address[] private s_fundersList;

    using PriceData for uint;

    address private immutable i_ownerAddress;

    uint public constant MIN_VALUE = 2e18; // 2 USD
    mapping(address => uint) private s_fundersMap;

    constructor(address priceFeedAddress) {
        i_ownerAddress = msg.sender;
        i_aggregator = AggregatorV3Interface(priceFeedAddress);
    }

    function getFundersMap(address key) public view returns (uint) {
        return s_fundersMap[key];
    }

    function getFundersList(uint index) public view returns (address) {
        return s_fundersList[index];
    }

    function getOwnerAddress() public view returns (address) {
        return i_ownerAddress;
    }

    function fundMe() public payable {
        require(
            msg.value.getConversion(i_aggregator) >= MIN_VALUE,
            "It must be atleast 2 USD"
        );

        s_fundersList.push(msg.sender);
        s_fundersMap[msg.sender] += msg.value;
    }

    function withDraw() public onlyOwner {
        //clear mappings
        for (uint i = 0; i < s_fundersList.length; i++) {
            address addr = s_fundersList[i];
            s_fundersMap[addr] = 0;
        }
        //re-assign funders list
        s_fundersList = new address[](0);

        //initiate transfer
        (bool isSuccess, ) = payable(i_ownerAddress).call{
            value: address(this).balance
        }("");
        require(isSuccess, "Transaction did't went through!");
    }

    function cheapWithDraw() public onlyOwner {
        //clear mappings

        //saving list size in a variable instead of reading it from storage every time
        uint fundersListLength = s_fundersList.length;

        for (uint i = 0; i < fundersListLength; i++) {
            address addr = s_fundersList[i];
            s_fundersMap[addr] = 0;
        }
        //re-assign funders list
        s_fundersList = new address[](0);

        //initiate transfer
        (bool isSuccess, ) = payable(i_ownerAddress).call{
            value: address(this).balance
        }("");
        require(isSuccess, "Transaction did't went through!");
    }

    modifier onlyOwner() {
        if (msg.sender != i_ownerAddress) revert FundMe__NonAuth();
        _;
    }

    function getSenderAddress() public view returns (address) {
        return msg.sender;
    }

    function contractAddress() private view returns (address) {
        return address(this);
    }

    receive() external payable {
        fundMe();
    }

    fallback() external payable {}

    function getVersion() public view returns (uint256) {
        return i_aggregator.version();
    }
}
