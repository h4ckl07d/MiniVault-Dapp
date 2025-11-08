// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

error NotOwner();

contract miniVault {
    mapping(address => uint) depositorToAmount;
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
        depositorToAmount[msg.sender] += msg.value;
        depositors.push(msg.sender);
        // emit amountDeposited();
    }

    // onlyowner of the fault should have permission to do this
    function withdraw() public onlyOwner {}

    // get the entire balance of the vault
    function getBalance() external view returns (uint256) {}

    function getowner() external view returns (address) {
        return i_owner;
    }
}
