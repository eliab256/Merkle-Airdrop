//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    error ClaimAirdropScript__InvalidSignatureLenght();

        address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        uint256 CLAIMING_AMOUNT =  25 * 1e18;
        bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
        bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
        bytes32[] proof = [proofOne, proofTwo];

        bytes private signature = hex"fbd2270e6f23fb5fe9248480c0f4be8a4e9bd77c3ad0b1333cc60b5debc511602a2a06c24085d8d7c038bad84edc53664c8ce0346caeaa3570afec0e61144dc11c";

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v,r,s) = splitSignature(signature);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v,r,s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s ){
        if(sig.length != 65){ //65 beacuse v is iunt8 (1 byte), r = 32 bytes, s = 32 bytes   1+32+32 = 65
            revert ClaimAirdropScript__InvalidSignatureLenght();
        }
        assembly {
            r:= mload(add(sig, 32))
            s:= mload(add(sig, 64))
            v:= byte(0, mload(add(sig,96)))
        }
    }


    function run() external {

    }
}