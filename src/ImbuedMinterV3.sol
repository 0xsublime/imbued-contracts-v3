// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";
import "./deployed/IImbuedNFT.sol";

contract ImbuedMintV3 is Ownable, IERC721Receiver {
    IImbuedNFT constant public NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    IERC721 constant public metaverseMiamiTicket = IERC721(0x9B6F8932A5F75cEc3f20f91EabFD1a4e6e572C0A);

    mapping (uint256 => bool) public miamiTicketId2claimed; // token ids that are claimed.

    enum Edition { LIFE, LONGING, FRIENDSHIP, FRIENDSHIP_MIAMI }
    // Order relevant variables per edition so that they are packed together,
    // reduced sload and sstore gas costs.
    struct MintInfo {
        uint16 nextId;
        uint16 maxId;
        bool openMint;
        uint216 price;
    }

    MintInfo[4] public mintInfos;

    constructor() {
        mintInfos[uint(Edition.LIFE      )] = MintInfo(201, 299, true, 0.05 ether);
        mintInfos[uint(Edition.LONGING   )] = MintInfo(301, 399, true, 0.05 ether);
        mintInfos[uint(Edition.FRIENDSHIP_MIAMI)] = MintInfo(401, 460, false, 0.05 ether);
        // Friendship edition is 461-499, first 2x30 reserved for Miami ticket holders.
        mintInfos[uint(Edition.FRIENDSHIP)] = MintInfo(461, 499, true, 0 ether);
    }

    // Mint tokens of a specific edition.
    function mint(Edition edition, uint8 amount) external payable {
        // Check payment.
        MintInfo memory info = mintInfos[uint(edition)];
        require(info.price * amount == msg.value, "Incorrect payment amount");
        require(info.openMint, "This edition cannot be minted this way");
        _mint(msg.sender, edition, amount);
    }

    // Free mint for holders of the Metaverse Miami ticket, when they simultaneously mint one for a friend and imbue.
    // TODO: On new data contract, allow permissioned access to the imbue function for the minter contract.
    // That will greatly reduce the gas cost of this function.
    function mintFriendshipMiami(address friend, string calldata imbuement) external {
        uint256 nextId = mintInfos[uint(Edition.FRIENDSHIP_MIAMI)].nextId;
        uint256 friendId = nextId + 1;
        _mint(address(this), Edition.FRIENDSHIP_MIAMI, 1);
        _mint(address(this), Edition.FRIENDSHIP_MIAMI, 1);
        NFT.imbue(nextId, imbuement);
        NFT.imbue(friendId, imbuement);
        NFT.transferFrom(address(this), msg.sender, nextId);
        NFT.transferFrom(friend, msg.sender, nextId);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external view returns (bytes4) {
        require(msg.sender == address(NFT), "Only receive from Imbued contract, no other NFTs");
        return this.onERC721Received.selector;
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

    /// (Admin only) Set parameters of an edition.
    /// @param edition which edition to set parameters for. 
    /// @param nextId the next id to mint.
    /// @param maxId the maximum id to mint.
    /// @param price the price to mint one token.
    /// @dev nextId must be <= maxId.
    function setEdition(Edition edition, uint16 nextId, uint16 maxId, bool openMint, uint216 price) external onlyOwner() {
        require(nextId % 100 <= maxId % 100, "nextId must be <= maxId");
        require(nextId / 100 == maxId / 100, "nextId and maxId must be in the same batch");
        require(NFT.provenance(nextId, 0, 0).length == 0, "nextId must not be minted yet");
        mintInfos[uint(edition)] = MintInfo(nextId, maxId, openMint, price);
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