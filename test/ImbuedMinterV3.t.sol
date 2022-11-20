// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import "forge-std/Test.sol";
import "../src/ImbuedMinterV3.sol";
import "../src/deployed/ImbuedNFT.sol";
 
contract MinterTest is Test {
    ImbuedNFT nft;
    ImbuedMintV3 public minter;
    address imbuedDeployer = 0x34EeE73e731fB2A428444e2b2957C36A9b145017;
    address[] users = [address(0x1), address(0x2), address(0x3)];

    function setUp() public {
        minter = new ImbuedMintV3();
        vm.prank(imbuedDeployer); nft = new ImbuedNFT();
        vm.prank(imbuedDeployer); nft.setMintContract(address(minter));
        assertEq(address(minter.NFT()), address(nft));
        for (uint i = 0; i < users.length; i++) {
            vm.deal(users[i], 10 ether);
        }
    }
 
    function testMint() public {
        vm.prank(users[0]); minter.mint{value: 0.05 ether}(ImbuedMintV3.Edition.LIFE, 1);
        assertEq(nft.ownerOf(201), address(users[0]));
        vm.prank(users[1]); minter.mint{value: 0.05 ether}(ImbuedMintV3.Edition.LONGING, 1);
        assertEq(nft.ownerOf(301), address(users[1]));
        vm.prank(users[2]); minter.mint{value: 0.05 ether}(ImbuedMintV3.Edition.FRIENDSHIP, 1);
        assertEq(nft.ownerOf(461), address(users[2]));
    }

    function testSuccess() public {
        assertEq(uint(1), 1, "simple");
    }
 
    function testFail(uint256 x) public {
        assertEq(uint(1), 2, "simple");
    }
}
