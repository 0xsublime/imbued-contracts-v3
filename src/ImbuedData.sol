
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "openzeppelin-contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";

import "./deployed/IImbuedNFT.sol";

contract ImbuedData is AccessControlUpgradeable {
    IImbuedNFT public constant NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    bytes32 public constant IMBUER_ROLE = keccak256("IMBUER_ROLE");

    event Imbued(uint256 indexed tokenId, address indexed owner, string imbuement);

    struct Imbuement {
        bytes32 imbuement;
        address imbuer;
        uint96 timestamp;
    }

    mapping (uint256 => Imbuement[]) public imbuements;
    mapping (uint256 => bytes32) public tokenEntropy;

    constructor() initializer {}

    function initialize(address[] calldata imbuers, address admin) external initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(IMBUER_ROLE, admin);
        unchecked {
            for (uint256 i = 0; i < imbuers.length; ++i) {
                _grantRole(IMBUER_ROLE, imbuers[i]);
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

    function imbue(uint256 tokenId, bytes32 imbuement) external {
        require(NFT.ownerOf(tokenId) == msg.sender, "Caller is not owner");
        _imbue(tokenId, imbuement, msg.sender, uint96(block.timestamp));
    }

    function imbueAdmin(uint256 tokenId, bytes32 imbuement, address imbueFor, uint96 timestamp) external {
        require(hasRole(IMBUER_ROLE, msg.sender), "Caller is not an imbuer");
        _imbue(tokenId, imbuement, imbueFor, timestamp);
    }

    function _imbue(uint256 tokenId, bytes32 imbuement, address imbuer, uint96 timestamp) internal {
        require(uint(imbuement) != 0, "Imbuement cannot be empty");
        Imbuement memory imb = Imbuement(imbuement, imbuer, timestamp);
        imbuements[tokenId].push(imb);

        bytes32 oldEntropy = tokenEntropy[tokenId];
        bytes32 newEntropy = keccak256(abi.encodePacked(oldEntropy, imbuement));
        tokenEntropy[tokenId] = newEntropy;

        bytes memory imb_bytes = abi.encodePacked(imbuement);
        emit Imbued(tokenId, imbuer, string(imb_bytes));
    }


    function getEntropy(uint8 edition) external view returns (bytes memory) {
        bytes memory entropy = new bytes(0);
        uint start = edition * 100;
        unchecked {
            for (uint i ; i < 100; ++i) {
                bytes2 prefix = bytes2(tokenEntropy[start + i]);
                entropy = bytes.concat(entropy, prefix);
            }
        }
        return entropy;
    }
}