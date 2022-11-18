// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "openzeppelin-contracts/access/Ownable.sol";
import "./IImbuedNFT.sol";

contract ImbuedMintV3 is Ownable {
    IImbuedNFT constant public NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    IERC721 constant public metaverseMiamiTicket = IERC721(0x9B6F8932A5F75cEc3f20f91EabFD1a4e6e572C0A);


    mapping (uint256 => bool) public miamiTicketId2claimed; // token ids that are claimed.

    enum Edition { LIFE, LONGING, FRIENDSHIP }
    // Order relevant variables per edition so that they are packed together,
    // reduced sload and sstore gas costs.
    struct MintInfo {
        uint16 nextId;
        uint16 maxId;
        uint224 price;
    }

    MintInfo[3] public mintInfos;

    constructor() {
        mintInfos[uint(Edition.LIFE      )] = MintInfo(201, 299, 0.05 ether);
        mintInfos[uint(Edition.LONGING   )] = MintInfo(301, 399, 0.05 ether);
        mintInfos[uint(Edition.FRIENDSHIP)] = MintInfo(461, 499, 0.05 ether); // Friendship edition is 461-499, first 2x30 reserved for Miami ticket holders.
    }

    function mint(Edition edition, uint8 amount) external payable {
        // Check payment.
        require(mintInfos[uint(edition)].price * amount == msg.value, "Incorrect payment amount");
        _mint(msg.sender, edition, amount);
    }

    // only owner

    /// (Admin only) Admin can mint without paying fee, because they are allowed to withdraw anyway.
    /// @param recipient what address should be sent the new token, must be an
    ///        EOA or contract able to receive ERC721s.
    /// @param amount the number of tokens to mint, starting with id `nextId()`.
    function adminMintAmount(address recipient, Edition edition, uint8 amount) external payable onlyOwner() {
        _mint(recipient, edition, amount);
    }

    /// (Admin only) Can mint *any* token ID. Intended foremost for minting
    /// major versions for the artworks.
    /// @param recipient what address should be sent the new token, must be an
    ///        EOA or contract able to receive ERC721s.
    /// @param tokenId which id to mint, may not be a previously minted one.
    function adminMintSpecific(address recipient, uint256 tokenId) external payable onlyOwner() {
        NFT.mint(recipient, tokenId);
    }

    /// (Admin only) Withdraw the entire contract balance to the recipient address.
    /// @param recipient where to send the ether balance.
    function withdrawAll(address payable recipient) external payable onlyOwner() {
        recipient.call{value: address(this).balance}("");
    }

    /// (Admin only) self-destruct the minting contract.
    /// @param recipient where to send the ether balance.
    function kill(address payable recipient) external payable onlyOwner() {
        selfdestruct(recipient);
    }

    // internal

    // Rethink: reentrancy danger. Here we have several nextId.
    function _mint(address recipient, Edition edition, uint8 amount) internal {
        MintInfo memory infoCache = mintInfos[uint(edition)];
        unchecked {
            uint256 newNext = infoCache.nextId + amount;
            require(newNext - 1 <= infoCache.maxId, "Minting would exceed maxId");
            for (uint256 i = 0; i < amount; i++) {
                NFT.mint(recipient, infoCache.nextId + i); // reentrancy danger. Handled by fact that same ID can't be minted twice.
            }
            mintInfos[uint(edition)].nextId = uint16(newNext);
        }
    }
}