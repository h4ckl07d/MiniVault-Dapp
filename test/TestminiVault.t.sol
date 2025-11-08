// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;
import {Test} from "forgestd";
import {miniVault} from "../src/miniVault.sol";
import {DeployMiniVault} from "../script/DeployMiniVault.s.sol";

contract TestMinniVault is Test {
    miniVault minivault;

    function setUp() external {
        DeployMiniVault deployminivault = new DeployMiniVault();
        minivault = deployminivault.run();
    }

    function testOwnerIsMsgSender() external view {
        assertEq(minivault.getowner(), msg.sender);
    }
}
