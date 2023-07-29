//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe private fundMe;
    uint256 private SEND_FUNDS = 0.01 ether;
    address private user = makeAddr("user");

    function setUp() external {
        fundMe = new DeployFundMe().run();
        deal(user, 1 ether);
    }

    function testIsMinUsd2() external {
        uint minValue = fundMe.MIN_VALUE();
        console.log(block.chainid);
        assertEq(minValue, 2e18);
    }

    function testSenderIsOwner() external {
        assertEq(fundMe.getSenderAddress(), address(this));
    }

    function testPriceFeedVersionIsCorrect() external {
        uint version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundingBelow2UsdFails() external {
        vm.expectRevert();
        fundMe.fundMe{value: 1e10}();
    }

    function testEnoughFundingGetsSuccess() external {
        fundMe.fundMe{value: SEND_FUNDS}();
    }

    function testBalanceIncreasesWithFunding() external {
        uint256 initialBalance = address(fundMe).balance;

        fundMe.fundMe{value: SEND_FUNDS}();

        uint256 finalBalance = address(fundMe).balance;

        assertEq(initialBalance + SEND_FUNDS, finalBalance);
    }

    function testBalanceIncreasesWithFunding2() external fundFirst {
        uint256 finalBalance = address(fundMe).balance;
        assertEq(SEND_FUNDS, finalBalance);
    }

    function testFundersListStoresFunderAddress() external {
        vm.prank(user);
        fundMe.fundMe{value: SEND_FUNDS}();
        assertEq(fundMe.getFundersList(0), user);
    }

    function testFundersMapStoresFunderData() external {
        vm.prank(user);
        fundMe.fundMe{value: SEND_FUNDS}();
        assertEq(fundMe.getFundersMap(user), SEND_FUNDS);
    }

    function testWithdrawalByNonOwnerFails() external {
        vm.expectRevert();
        vm.prank(user);
        fundMe.withDraw();
    }

    function testWithdrawalSuccess() external fundFirst {
        //assemble
        uint256 ownerBalance = fundMe.getOwnerAddress().balance;
        uint256 contractBalance = address(fundMe).balance;

        //act
        vm.prank(fundMe.getOwnerAddress());
        fundMe.withDraw();

        //assert
        uint256 finalContractBalance = address(fundMe).balance;
        uint256 finalOwnerBalance = fundMe.getOwnerAddress().balance;

        assertEq(finalContractBalance, 0);
        assertEq(finalOwnerBalance, contractBalance + ownerBalance);
    }

    function testWithdrawalSuccessWithMultipleFunders() external {
        //assemble

        //act
        for (uint160 i = 1; i < 20; i++) {
            hoax(address(i), SEND_FUNDS);
            fundMe.fundMe{value: SEND_FUNDS}();
        }

        uint initialBalance = fundMe.getOwnerAddress().balance;
        uint contractBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwnerAddress());
        fundMe.withDraw();
        vm.stopPrank();

        //assert
        uint finalBalance = fundMe.getOwnerAddress().balance;
        uint finalContractBalance = address(fundMe).balance;

        assertEq(finalContractBalance, 0);
        assertEq(finalBalance, initialBalance + contractBalance);
    }

    function testWithdrawalSuccessWithMultipleFundersCheaper() external {
        //assemble

        //act
        for (uint160 i = 1; i < 20; i++) {
            hoax(address(i), SEND_FUNDS);
            fundMe.fundMe{value: SEND_FUNDS}();
        }

        uint initialBalance = fundMe.getOwnerAddress().balance;
        uint contractBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwnerAddress());
        fundMe.cheapWithDraw();
        vm.stopPrank();

        //assert
        uint finalBalance = fundMe.getOwnerAddress().balance;
        uint finalContractBalance = address(fundMe).balance;

        assertEq(finalContractBalance, 0);
        assertEq(finalBalance, initialBalance + contractBalance);
    }

    modifier fundFirst() {
        vm.prank(user);
        fundMe.fundMe{value: SEND_FUNDS}();
        _;
    }
}
