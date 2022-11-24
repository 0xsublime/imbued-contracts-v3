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
    address[] fixtures;

    function setUp() public {
        minter = new ImbuedMintV3(0x9B6F8932A5F75cEc3f20f91EabFD1a4e6e572C0A);
        vm.prank(imbuedDeployer); nft = new ImbuedNFT();
        vm.prank(imbuedDeployer); nft.setMintContract(address(minter));
        assertEq(address(minter.NFT()), address(nft));
        for (uint i = 0; i < users.length; i++) {
            vm.deal(users[i], 100 ether);
        }
        fixtures = [address(0), address(this), address(nft), address(minter), address(vm), 0x4e59b44847b379578588920cA78FbF26c0B4956C];

    }
 
    function testMint() public {
        uint216 price;
        (,,, price) = minter.mintInfos(uint(ImbuedMintV3.Edition.LIFE));
        vm.prank(users[0]); minter.mint{value: price}(ImbuedMintV3.Edition.LIFE, 1);
        assertEq(nft.ownerOf(201), address(users[0]));
        (,,, price) = minter.mintInfos(uint(ImbuedMintV3.Edition.LONGING));
        vm.prank(users[1]); minter.mint{value: price}(ImbuedMintV3.Edition.LONGING, 1);
        assertEq(nft.ownerOf(301), address(users[1]));
        (,,, price) = minter.mintInfos(uint(ImbuedMintV3.Edition.FRIENDSHIP));
        vm.prank(users[2]); minter.mint{value: price}(ImbuedMintV3.Edition.FRIENDSHIP, 1);
        assertEq(nft.ownerOf(461), address(users[2]));
    }

    function testBadFailMint(address user, uint8 amount) public {
        uint8 edition = uint8(ImbuedMintV3.Edition.FRIENDSHIP_MIAMI);
        (,,,uint216 price) = minter.mintInfos(uint(edition));
        uint256 mintCost = uint(price) * amount;
//      console.log("user", user);
//      console.log("amount", amount);
//      console.log("edition", uint(edition));
//      console.log("mintCost", mintCost);
//      console.log("nextId", nextId);

        vm.expectRevert();
        vm.deal(user, 100 ether); vm.prank(user); minter.mint{value: mintCost}(ImbuedMintV3.Edition(edition), amount);
    }

    function testFailMint1(address user, uint8 amount, uint edition) public {
        vm.assume(amount > 0);
        (uint16 nextId, uint16 maxId, , uint216 price) = minter.mintInfos(uint(edition));
        vm.assume(edition > 3 || user == address(0) || user == address(this) || user == address(nft) || user == address(minter) || user == address(vm) || user == 0x4e59b44847b379578588920cA78FbF26c0B4956C || uint(nextId) + amount - 1 > maxId);
        uint256 mintCost = uint(price) * amount;
//      console.log("user", user);
//      console.log("amount", amount);
//      console.log("edition", uint(edition));
//      console.log("mintCost", mintCost);
//      console.log("nextId", nextId);

        vm.deal(user, 100 ether); vm.prank(user); minter.mint{value: mintCost}(ImbuedMintV3.Edition(edition), amount);
    }

    function testMint2() public {
        (,,,uint216 price) = minter.mintInfos(uint(ImbuedMintV3.Edition.LIFE));
        vm.deal(users[0], 100 ether); vm.prank(users[0]); minter.mint{value: 99 * price}(ImbuedMintV3.Edition.LIFE, 99);
    }

    function testMint3() public {
        (,,,uint216 price) = minter.mintInfos(uint(ImbuedMintV3.Edition.LIFE));
        vm.deal(users[0], 100 ether); vm.prank(users[0]); minter.mint{value: 98 * price}(ImbuedMintV3.Edition.LIFE, 98);
    }

    function testMint(address user, uint8 amount, uint edition) public {
        uint edition = edition % 3;
        vm.assume(edition < 3);
        (uint16 nextId, uint16 maxId, bool active, uint216 price) = minter.mintInfos(uint(edition));
        assertTrue(active, "edition not active");
        vm.assume(user != address(0));
        vm.assume(user != address(this));
        vm.assume(user != address(nft));
        vm.assume(user != address(minter));
        vm.assume(uint(nextId) + amount - 1 <= maxId);
        uint256 mintCost = uint(price) * amount;
//      console.log("user", user);
//      console.log("amount", amount);
//      console.log("edition", uint(edition));
//      console.log("mintCost", mintCost);
//      console.log("nextId", nextId);

        vm.deal(user, 100 ether); vm.prank(user); minter.mint{value: mintCost}(ImbuedMintV3.Edition(edition), amount);
        for (uint i = 0; i < amount; i++) {
            assertEq(nft.ownerOf(nextId + i), user);
        }
    }

    function testSuccess() public {
        assertEq(uint(1), 1, "simple");
    }
 
    function testFail(uint256) public {
        assertEq(uint(1), 2, "simple");
    }
}
