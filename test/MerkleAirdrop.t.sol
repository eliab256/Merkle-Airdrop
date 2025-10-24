//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {Token} from "../src/Token.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    Token public token;

    bytes32 public root = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public amountToClaim = 25 * 1e18;
    uint256 public initialSupply = amountToClaim * 4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [proofOne, proofTwo];
    address gasPayer;
    address user;
    uint256 userPrivatekey;

    function setUp() public {
        token = new Token();
        airdrop = new MerkleAirdrop(root, token);
        token.mint(token.owner(), initialSupply);
        token.transfer(address(airdrop), initialSupply);
        (user,userPrivatekey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, amountToClaim);
        (uint8 v, bytes32 r, bytes32 s ) = vm.sign(userPrivatekey, digest); 

        vm.prank(user);
        airdrop.claim(user, amountToClaim, proof, v, r, s);

        assertEq(token.balanceOf(user) - startingBalance , amountToClaim);
    }

    function testGasPayerCanPayTransactionForUserClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, amountToClaim);
        //user sign a message
        //vm.prank(user);
        (uint8 v, bytes32 r, bytes32 s ) = vm.sign(userPrivatekey, digest); 
        //gasPayer calls claim using the signed message
        vm.prank(gasPayer);
        airdrop.claim(user, amountToClaim, proof, v, r, s);
        assertEq(token.balanceOf(user) - startingBalance , amountToClaim);
    }
}