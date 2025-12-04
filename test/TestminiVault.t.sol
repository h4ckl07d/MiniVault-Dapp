// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;
import {Test} from "forge-std/Test.sol";
import {miniVault} from "../src/miniVault.sol";
import {DeployMiniVault} from "../script/DeployMiniVault.s.sol";

contract TestMiniVault is Test {
    miniVault minivault;

    // uint256 totalBalance;
    receive() external payable {}

    address USER = makeAddr("user");
    uint256 constant STARTING_VALUE = 1 ether;
    uint256 constant WITHDRAW_AMOUNT = 0.4 ether;
    uint256 constant DEPOSIT_AMOUNT = 0.5 ether;

    event amountDeposited(
        address indexed from,
        uint256 amount,
        uint256 timestamp
    );

    function setUp() external {
        DeployMiniVault deployminivault = new DeployMiniVault();
        minivault = deployminivault.run();
        vm.deal(USER, STARTING_VALUE);
    }

    function testOwnerIsMsgSender() external view {
        assertEq(minivault.getowner(), msg.sender);
    }

    function testUserCanWithdrawMoreThanBalance() external payable {
        vm.expectRevert();
        minivault.withdraw(WITHDRAW_AMOUNT);
    }

    function testDepositIncreasesBalance() external payable {
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

    function testWithdrawBeforeLockFails() external payable {
        vm.deal(address(this), STARTING_VALUE);

        minivault.deposit{value: STARTING_VALUE}();
        vm.warp(block.timestamp + 50 minutes);

        uint256 before = minivault.getBalance();

        vm.expectRevert(bytes("Locked"));
        minivault.withdraw(WITHDRAW_AMOUNT);

        uint256 afterRevert = minivault.getBalance();
        assertEq(before, afterRevert);
    }

    function testDepositEventEmission() external {
        vm.startPrank(USER);

        // uint256 DEPOSIT_AMOUNT;
        vm.expectEmit(true, false, false, true, address(minivault));

        emit amountDeposited(USER, STARTING_VALUE, block.timestamp);

        minivault.deposit{value: STARTING_VALUE}();
        vm.stopPrank();
    }
}
