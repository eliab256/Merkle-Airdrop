// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script, console } from "forge-std/Script.sol";
import { Token } from "../src/Token.sol";
import { MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract DeployMerkleAirdrop is Script {
     function run() public returns (Token, MerkleAirdrop) {
        vm.startBroadcast();
            
        vm.stopBroadcast();
        return (token, merkleAirdrop);
    }
}