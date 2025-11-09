// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

error NotOwner();
error InvalidBalance();
error InsufficientBalance();

contract miniVault {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public LockedTimer;
    // bool callSuccess;
    address[] public depositors;

    address public i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    // record the activity of the contract on-chain
    event amountDeposited(
        address indexed from,
        uint256 amount,
        uint256 timestamp
    );

    // user should be able to fund the vault
    function deposit() public payable {
        balances[msg.sender] += msg.value;
        depositors.push(msg.sender);
        emit amountDeposited(msg.sender, msg.value, block.timestamp);
        LockedTimer[msg.sender] = block.timestamp + 60 minutes;
    }

    // onlyowner of the fault should have permission to do this
    function withdraw(uint256 amount) public {
        if (address(this).balance == 0) {
            revert InvalidBalance();
        }
        if (balances[msg.sender] <= amount) revert InsufficientBalance();
        balances[msg.sender] -= amount;
        require(block.timestamp >= LockedTimer[msg.sender], "Locked");

        (bool callSuccess, ) = payable(msg.sender).call{value: amount}("");
        require(callSuccess, "Call failed");
    }

    // get the entire balance of the vault
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getowner() external view returns (address) {
        return i_owner;
    }
}
