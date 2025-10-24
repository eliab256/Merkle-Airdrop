// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712{
    using SafeERC20 for IERC20;
    error MerkleAirdrop__MerkleProofNotValid();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__SignatureNotValid();

    event Claim(address account, uint256 amount);
    // some list of addresses
    address[] public claimers;
    bytes32 private immutable i_markleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address => bool) public s_hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");
    struct AirdropClaim{
        address account;
        uint256 amount;
    }

    constructor(bytes32 _markleRoot, IERC20 _airdropToken)EIP712("MerkeAirdrop", "1"){
        i_markleRoot = _markleRoot;
        i_airdropToken = _airdropToken;
    }

    function claim(address _account, uint256 _amount, bytes32[] calldata markleProof, uint8 v, bytes32 r, bytes32 s) external {
        if(s_hasClaimed[_account]){ 
            revert MerkleAirdrop__AlreadyClaimed();
        }
        //check the signature
        if(!_isValidSignature(_account, getMessageHash(_account, _amount), v, r, s)){
            revert MerkleAirdrop__SignatureNotValid();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));
        if(!MerkleProof.verify(markleProof, i_markleRoot, leaf)) {
            revert MerkleAirdrop__MerkleProofNotValid();
        }
        s_hasClaimed[_account] = true;
        emit Claim(_account, _amount);
        i_airdropToken.safeTransfer(_account, _amount);
    }

    function getMessageHash(address _account, uint256 _amount) public view returns(bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: _account, amount: _amount}))));
    }

    function _isValidSignature(address _account, bytes32 _digest, uint8 v, bytes32 r, bytes32 s ) internal pure returns(bool) {
        (address actualSigner, , ) = ECDSA.tryRecover(_digest,v,r,s);
        return actualSigner == _account;
    }

    function getMerkleRoot() external view returns (bytes32){
        return i_markleRoot;
    }

    function getAirdroptoken() external view returns (IERC20){
        return i_airdropToken;
    }

}