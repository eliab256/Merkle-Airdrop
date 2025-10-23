// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/utils/Merkleproof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IErc20;
    error MerkleAirdrop__MerkleProofNotValid();

    event Claim(address account, uint256 amount);
    // some list of addresses
    address[] public claimers;
    bytes32 private immutable i_markleRoot;
    IERC20 private immutable i_airdropToken;

    constructor(bytes32 _markleRoot, IERC20 _airdropToken){
        i_markleRoot = _markleRoot;
        i_airdropToken = _airdropToken;
    }

    function claim(address _account, uint256 _amount, bytes32[] calldata markleProof) external {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));
        if(!MerkleProof.verify(markleProof, i_markleRoot, leaf)) {
            revert MerkleAirdrop__MerkleProofNotValid();
        }
        emit Claim(_account, _amount);
        i_airdropToken.safeTransfer(_account, _amount);
    }

    //prova push

}