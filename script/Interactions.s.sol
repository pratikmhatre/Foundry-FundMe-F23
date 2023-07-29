//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint private constant SEND_VALUE = 0.01 ether;
    address private immutable i_USER = makeAddr("user");

    function run() external {
        address lastDeployedAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(lastDeployedAddress);
    }

    function fundFundMe(address addr) public {
        vm.startBroadcast();
        FundMe(payable(addr)).fundMe{value: SEND_VALUE}();
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function run() external {
        address lastDeployedAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withDrawFundMe(lastDeployedAddress);
    }

    function withDrawFundMe(address addr) public {
        vm.startBroadcast();
        FundMe(payable(addr)).withDraw();
        vm.stopBroadcast();
    }
}
