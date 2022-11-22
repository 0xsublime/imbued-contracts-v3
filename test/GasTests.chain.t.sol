// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/deployed/ImbuedNFT.sol";
import "../src/ImbuedMinterV3.sol";

contract GasTestChain is Test {
    ImbuedNFT constant nft = ImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    ImbuedMintV3 minter;

    address imbuedDeployer = 0x34EeE73e731fB2A428444e2b2957C36A9b145017;

    address constant alice = address(uint160(uint256(keccak256("alice"))));
    address constant miamiWhale = 0xB80392D331e381299f37c2B110384b6a7BcB1a44;

    function setUp() public {
        // uint forkBlock = 16_018_853;
        // No need for a fork block if running against a local node
        vm.createSelectFork(vm.rpcUrl("mainnet"));
        vm.deal(alice, 10 ether);

        minter = new ImbuedMintV3();
        vm.prank(imbuedDeployer); nft.setMintContract(address(minter));
        vm.prank(imbuedDeployer); nft.setEditionTransferable(4);
        assertEq(address(minter.NFT()), address(nft));

    }

    function testMint1() public {
        vm.prank(alice); minter.mint{value: 0.05 ether}(ImbuedMintV3.Edition.LIFE, 1);
    }

    function testMint2() public {
        vm.prank(alice); minter.mint{value: 0.10 ether}(ImbuedMintV3.Edition.LIFE, 2);
    }

    function testMint5() public {
        vm.prank(alice); minter.mint{value: 0.25 ether}(ImbuedMintV3.Edition.LIFE, 5);
    }
    function testMiamiMint() public {
        vm.prank(miamiWhale); minter.mintFriendshipMiami(221, alice, "We are best buddies");
    }
}