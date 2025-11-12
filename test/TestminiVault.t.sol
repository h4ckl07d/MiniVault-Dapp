// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;
import {Test} from "forge-std/Test.sol";
import {miniVault} from "../src/miniVault.sol";
import {DeployMiniVault} from "../script/DeployMiniVault.s.sol";

contract TestMiniVault is Test {
    miniVault minivault;

    // uint256 totalBalance;
    receive() external payable {}

    uint256 constant STARTING_VALUE = 1 ether;
    uint256 constant WITHDRAW_AMOUNT = 0.4 ether;

    function setUp() external {
        DeployMiniVault deployminivault = new DeployMiniVault();
        minivault = deployminivault.run();
    }

    function testOwnerIsMsgSender() external view {
        assertEq(minivault.getowner(), msg.sender);
    }

    function testUserCanWithdrawMoreThanBalance() external payable {
        vm.expectRevert();
        minivault.withdraw(msg.value);
    }

    function testDepositincreaseBalance() external payable {
        minivault.deposit{value: STARTING_VALUE}();
        uint256 totalBalance = minivault.getBalance();
        assertEq(totalBalance, STARTING_VALUE);
    }

    function testWithdrawDecreaseBalance() external payable {
        vm.deal(address(this), STARTING_VALUE);

        minivault.deposit{value: STARTING_VALUE}();
        vm.warp(block.timestamp + 60 minutes);

        minivault.withdraw(WITHDRAW_AMOUNT);

        uint256 miniVaultBalance = address(minivault).balance;
        assertEq(miniVaultBalance, STARTING_VALUE - WITHDRAW_AMOUNT);
    }
}
