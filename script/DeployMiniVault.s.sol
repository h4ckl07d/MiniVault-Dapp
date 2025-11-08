// SPDX-License-Identifier:MIT

pragma solidity ^0.8.26;

import{Script} from "forgestd"
import {miniVault} from "../src/miniVault.sol";


contract DeployMiniVault is Script {
    miniVault public minivault;

    function run() external returns(miniVault){
        vm.startBroadcast();
        minivault = new miniVault();
        vm.stopBroadcast();
        return miniVault;
    }
    
}
