
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "openzeppelin-contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";

import "./deployed/IImbuedNFT.sol";

contract ImbuedData is AccessControlUpgradeable {
    IImbuedNFT constant public NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    bytes32 public constant IMBUER_ROLE = keccak256("IMBUER_ROLE");

    constructor() initializer {}

    function initialize(address[] calldata imbuers) external initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
        unchecked {
            for (uint256 i = 0; i < imbuers.length; ++i) {
                _setupRole(IMBUER_ROLE, imbuers[i]);
            }
        }
    }

    // Unnecessary! Implemented by default in AccessControl
    /*
    function removeImbuer(address imbuer) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        revokeRole(IMBUER_ROLE, imbuer);
    }

    function addImbuer(address imbuer) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        grantRole(IMBUER_ROLE, imbuer);
    }
    */

    function imbue(uint256 tokenId, string calldata imbuement) external {
        require(NFT.ownerOf(tokenId) == msg.sender, "Caller is not owner");
// TODO: add imbuements to this contract        NFT.imbue(tokenId, imbuement);
    }

    function imbueAdmin(uint256 tokenId, string calldata imbuement) external {
        require(hasRole(IMBUER_ROLE, msg.sender), "Caller is not an imbuer");
// TODO: add imbuements to this contract        NFT.imbue(tokenId, imbuement);
    }

}