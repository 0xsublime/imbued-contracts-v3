// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";
import "../src/deployed/ImbuedNFT.sol";
import "../src/ImbuedMinterV3.sol";

contract GasTestChain is Test {
    ImbuedNFT constant nft = ImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    ImbuedData implementation;
    TransparentUpgradeableProxy proxy;
    ImbuedData dataContract;
    ProxyAdmin admin;
    ImbuedMintV3 minter;

    address imbuedDeployer = 0x34EeE73e731fB2A428444e2b2957C36A9b145017;

    address constant alice = address(uint160(uint256(keccak256("alice"))));
    address constant miamiWhale = 0xB80392D331e381299f37c2B110384b6a7BcB1a44;

    function setUp() public {
        // uint forkBlock = 16_018_853;
        // No need for a fork block if running against a local node
        vm.createSelectFork(vm.rpcUrl("mainnet"));
        vm.deal(alice, 10 ether);

        minter = new ImbuedMintV3(0x9B6F8932A5F75cEc3f20f91EabFD1a4e6e572C0A);
        vm.prank(imbuedDeployer); nft.setMintContract(address(minter));
        vm.prank(imbuedDeployer); nft.setEditionTransferable(4);
        assertEq(address(minter.NFT()), address(nft));

        admin = new ProxyAdmin();
        implementation = new ImbuedData();
        //bytes memory calld = abi.encodeWithSignature("initialize(address[],address)", [address(this)], imbuedDeployer);
        proxy = new TransparentUpgradeableProxy(address(implementation), address(admin), "");
        address[] memory imbuers = new address[](2);
        imbuers[0] = address(this);
        imbuers[1] = address(minter);
        dataContract = ImbuedData(address(proxy));
        dataContract.initialize(imbuers, imbuedDeployer);

        vm.prank(imbuedDeployer); nft.setDataContract(address(dataContract));
    }

    function testMint1() public {
        (,,,uint216 price) = minter.mintInfos(uint(ImbuedMintV3.Edition.LIFE));
        vm.prank(alice); minter.mint{value: price}(ImbuedMintV3.Edition.LIFE, 1);
    }

    function testMint2() public {
        (,,,uint216 price) = minter.mintInfos(uint(ImbuedMintV3.Edition.LIFE));
        vm.prank(alice); minter.mint{value: 2 * price}(ImbuedMintV3.Edition.LIFE, 2);
    }

    function testMint5() public {
        (,,,uint216 price) = minter.mintInfos(uint(ImbuedMintV3.Edition.LIFE));
        vm.prank(alice); minter.mint{value: 5 * price}(ImbuedMintV3.Edition.LIFE, 5);
    }

    function testMiamiMint() public {
        vm.prank(miamiWhale); minter.mintFriendshipMiami(221, alice, "We are best buddies");
    }
}