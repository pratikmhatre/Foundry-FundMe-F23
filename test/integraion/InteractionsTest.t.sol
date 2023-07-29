//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe private fundMe;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
    }

    function testUserCanFundAndWithdraw() external skipFork {
        address dummyUser = makeAddr("dummy");
        hoax(dummyUser, 1 ether);
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        assert(address(fundMe).balance == 0.01 ether);

        vm.prank(fundMe.getOwnerAddress());
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withDrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }

    modifier skipFork() {
        if (block.chainid != 31337) return;
        _;
    }
}
