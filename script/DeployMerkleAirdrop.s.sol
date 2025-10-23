// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script, console } from "forge-std/Script.sol";
import { Token } from "../src/Token.sol";
import { MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol;

contract DeployMerkleAirdrop is Script {
    bytes32 private s_markleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public amount = 25 * 1e18;
    uint256 public initialSupply = amount * 4;

    function deployMerkleAirdrop() public returns (Token, MerkleAirdrop) {
        vm.startBroadcast();
            Token token = new Token();
            MerkleAirdrop merkleAirdrop = new MerkleAirdrop(s_markleRoot, IERC20(address(token)));
            token.mint(token.owner(), initialSupply);
            token.transfer(address(airdrop), initialSupply);
        vm.stopBroadcast();
        return (token, merkleAirdrop);
    }

    function run() public returns (Token, MerkleAirdrop) {
        deployMerkleAirdrop();
        
    }
}