// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import "forge-std/Test.sol";
import "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";
import "../src/ImbuedMinterV3.sol";
import "../src/deployed/ImbuedNFT.sol";
 
contract MinterTestChain is Test {
    ImbuedNFT nft = ImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);

    ImbuedData implementation;
    TransparentUpgradeableProxy proxy;
    ImbuedData dataContract;
    ProxyAdmin admin;

    // The lowest token ID is 1, the highest is 668.
    IERC721Enumerable miami = IERC721Enumerable(0x9B6F8932A5F75cEc3f20f91EabFD1a4e6e572C0A);

    ImbuedMintV3 public minter;
    address imbuedDeployer = 0x34EeE73e731fB2A428444e2b2957C36A9b145017;
    address[] users = [address(0x1), address(0x2), address(0x3)];
    address[] fixtures;

    address miamiWhale = 0xB80392D331e381299f37c2B110384b6a7BcB1a44;

    function setUp() public {
        // uint forkBlock = 16_018_853;
        // No need for a fork block if running against a local node
        vm.createSelectFork(vm.rpcUrl("mainnet"));

        minter = new ImbuedMintV3(0x9B6F8932A5F75cEc3f20f91EabFD1a4e6e572C0A);
        vm.prank(imbuedDeployer); nft.setMintContract(address(minter));
        vm.prank(imbuedDeployer); nft.setEditionTransferable(4);
        assertEq(address(minter.NFT()), address(nft));
        for (uint i = 0; i < users.length; i++) {
            vm.deal(users[i], 10 ether);
        }
        fixtures = [address(0), address(this), address(nft), address(minter), address(vm), 0x4e59b44847b379578588920cA78FbF26c0B4956C];

        admin = new ProxyAdmin();
        implementation = new ImbuedData();
        proxy = new TransparentUpgradeableProxy(address(implementation), address(admin), "");
        address[] memory imbuers = new address[](2);
        imbuers[0] = address(this);
        imbuers[1] = address(minter);
        dataContract = ImbuedData(address(proxy));
        dataContract.initialize(imbuers, imbuedDeployer);
        vm.prank(imbuedDeployer); nft.setDataContract(address(dataContract));
    }

    function testMinterUpgrade(uint16 tokenId, address friend, string calldata imbuement) public {
        bytes32 role = dataContract.IMBUER_ROLE();
        vm.prank(imbuedDeployer); dataContract.revokeRole(role, address(minter));
        minter = new ImbuedMintV3(0x9B6F8932A5F75cEc3f20f91EabFD1a4e6e572C0A);
        vm.prank(imbuedDeployer); nft.setMintContract(address(minter));
        vm.prank(imbuedDeployer); dataContract.grantRole(role, address(minter));
        testMiamiMint(tokenId, friend, imbuement);
    }

    function testMiamiMint(uint16 tokenId, address friend, string calldata imbuement) public {
        vm.assume(bytes(imbuement).length > 0);
        uint totalSupply = miami.totalSupply();
        vm.assume(tokenId >= 1 && tokenId <= totalSupply);
        vm.assume(bytes(imbuement).length <= 32);
        for (uint i = 0; i < fixtures.length; i++) {
            vm.assume(miami.ownerOf(tokenId) != fixtures[i]);
            vm.assume(friend != fixtures[i]);
        }
        address sender = miami.ownerOf(tokenId);
        (uint nextId, , ,) = minter.mintInfos(uint(ImbuedMintV3.Edition.FRIENDSHIP_MIAMI));
        vm.prank(sender); minter.mintFriendshipMiami(tokenId, friend, imbuement);
        assertEq(nft.ownerOf(nextId), friend);
        (uint nextIdNew, , ,) = minter.mintInfos(uint(ImbuedMintV3.Edition.FRIENDSHIP_MIAMI));
        assertEq(nextIdNew, nextId + 1);
    }

    function testFailMiamiMint(uint16 tokenId, address friend, string calldata imbuement) public {
        vm.assume(bytes(imbuement).length > 0);
        uint totalSupply = miami.totalSupply();
        vm.assume(tokenId >= 1 && tokenId <= totalSupply);
        vm.assume(bytes(imbuement).length <= 32);
        for (uint i = 0; i < fixtures.length; i++) {
            vm.assume(miami.ownerOf(tokenId) != fixtures[i]);
            vm.assume(friend != fixtures[i]);
        }
        address sender = miami.ownerOf(tokenId);
        (uint nextId, , ,) = minter.mintInfos(uint(ImbuedMintV3.Edition.FRIENDSHIP_MIAMI));
        vm.prank(sender); minter.mintFriendshipMiami(tokenId, friend, imbuement);
        vm.prank(sender); minter.mintFriendshipMiami(tokenId, friend, imbuement);
        assertEq(nft.ownerOf(nextId), friend);
        (uint nextIdNew, , ,) = minter.mintInfos(uint(ImbuedMintV3.Edition.FRIENDSHIP_MIAMI));
        assertEq(nextIdNew, nextId + 1);
    }

    function testFailMiamiMint(uint16 tokenId, address sender, address friend, string calldata imbuement) public {
        vm.assume(sender != miami.ownerOf(tokenId));
        vm.prank(sender); minter.mintFriendshipMiami(tokenId, friend, imbuement);
    }
 
    function testFailMiamiMint(uint16 tokenId, string calldata imbuement) public {
        address sender = miami.ownerOf(tokenId);
        vm.prank(sender); minter.mintFriendshipMiami(tokenId, sender, imbuement); // Can't make yourself the friend
    }

    function testMint() public {
        vm.prank(users[0]); minter.mint{value: 0.05 ether}(ImbuedMintV3.Edition.LIFE, 1);
        assertEq(nft.ownerOf(201), address(users[0]));
        vm.prank(users[1]); minter.mint{value: 0.05 ether}(ImbuedMintV3.Edition.LONGING, 1);
        assertEq(nft.ownerOf(301), address(users[1]));
        vm.prank(users[2]); minter.mint{value: 0.05 ether}(ImbuedMintV3.Edition.FRIENDSHIP, 1);
        assertEq(nft.ownerOf(461), address(users[2]));
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

        vm.deal(user, 10 ether); vm.prank(user); minter.mint{value: mintCost}(ImbuedMintV3.Edition(edition), amount);
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
