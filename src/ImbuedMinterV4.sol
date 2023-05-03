// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";
import "./deployed/IImbuedNFT.sol";
import "./ImbuedData.sol";

contract ImbuedMintV4 is Ownable {
    IImbuedNFT constant public NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);

    // Order relevant variables per edition so that they are packed together,
    // reduced sload and sstore gas costs.
    struct MintInfo {
        uint16 nextId;
        uint16 maxId;
        bool openMint;
        bool canSelfMint;
        uint208 price;
    }

    enum Edition { LOVE, AWE, LIFE, LONGING, FRIENDSHIP, GRIEF, APPRECIATION}
    MintInfo[7] public mintInfos;

    constructor() {
        // Love is empty/closed for mint
        // Awe is empty/closed for mint
        mintInfos[2] = MintInfo(231, 299, true,  true,  0 ether); // Life
        mintInfos[3] = MintInfo(334, 399, true,  true,  0 ether); // Longing
        mintInfos[4] = MintInfo(407, 499, true,  false, 0 ether); // Friendship
        mintInfos[5] = MintInfo(501, 599, false, true,  0 ether); // Grief
        mintInfos[6] = MintInfo(601, 699, false, false, 0 ether); // Appreciation
    }

    // Mint tokens of a specific edition.
    function mint(Edition edition, uint8 amount) external payable {
        mint(uint(edition), amount, msg.sender, "");
  }

    error IncorrectPaymentAmount();
    error NotOpenForMint();
    error CannotPayForwardToSelf();
    error ImbuementTooLong();
    error NullImbuement();
    error EditionMintedOut();

    function mint(uint edition, uint8 amount, address receiver, string memory imbuement) public payable {
        // Check payment.
        MintInfo memory info = mintInfos[edition];
        if (info.price * amount != msg.value) revert IncorrectPaymentAmount();
        if (!info.openMint) revert NotOpenForMint();
        if (!info.canSelfMint) {
            if (receiver == msg.sender) revert CannotPayForwardToSelf();
        }
        _mint(receiver, edition, amount);
        if (bytes(imbuement).length > 0) {
            if (bytes(imbuement).length > 32) revert ImbuementTooLong();
            uint256 nextId = info.nextId;
            ImbuedData data = ImbuedData(NFT.dataContract());
            bytes32 imb = bytes32(bytes(imbuement));
            if (uint(imb) == 0) revert NullImbuement();
            data.imbueAdmin(nextId, imb, msg.sender, uint96(block.timestamp));
        }
    }

    // only owner

    /// (Admin only) Admin can mint without paying fee, because they are allowed to withdraw anyway.
    /// @param recipient what address should be sent the new token, must be an
    ///        EOA or contract able to receive ERC721s.
    /// @param amount the number of tokens to mint, starting with id `nextId()`.
    function adminMintAmount(address recipient, uint edition, uint8 amount) external onlyOwner() {
        _mint(recipient, edition, amount);
    }

    /// (Admin only) Can mint *any* token ID. Intended foremost for minting
    /// major versions for the artworks.
    /// @param recipient what address should be sent the new token, must be an
    ///        EOA or contract able to receive ERC721s.
    /// @param tokenId which id to mint, may not be a previously minted one.
    function adminMintSpecific(address recipient, uint256 tokenId) external onlyOwner() {
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
    function setEdition(uint edition, uint16 nextId, uint16 maxId, bool openMint, bool canSelfMint, uint208 price) external onlyOwner() {
        require(nextId % 100 <= maxId % 100, "nextId must be <= maxId");
        require(nextId / 100 == maxId / 100, "nextId and maxId must be in the same batch");
        require(NFT.provenance(nextId, 0, 0).length == 0, "nextId must not be minted yet");
        mintInfos[edition] = MintInfo(nextId, maxId, openMint, canSelfMint, price);
    }

    // internal

    // Rethink: reentrancy danger. Here we have several nextId.
    function _mint(address recipient, uint edition, uint8 amount) internal {
        MintInfo memory infoCache = mintInfos[edition];
        unchecked {
            uint256 newNext = infoCache.nextId + amount;
            if (newNext - 1 > infoCache.maxId) revert EditionMintedOut();
            for (uint256 i = 0; i < amount; i++) {
                NFT.mint(recipient, infoCache.nextId + i); // reentrancy danger. Handled by fact that same ID can't be minted twice.
            }
            mintInfos[edition].nextId = uint16(newNext);
        }
    }
}
