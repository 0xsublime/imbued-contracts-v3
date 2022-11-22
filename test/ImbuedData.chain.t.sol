// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import "forge-std/Test.sol";
import "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";
import "../src/deployed/ImbuedNFT.sol";
import "../src/ImbuedData.sol";
 
contract DataTestChain is Test {
    ImbuedNFT nft = ImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    ImbuedData implementation;
    TransparentUpgradeableProxy proxy;
    ImbuedData dataContract;
    ProxyAdmin admin;

    address imbuedDeployer = 0x34EeE73e731fB2A428444e2b2957C36A9b145017;

    function setUp() public {
        // uint forkBlock = 16_018_853;
        // No need for a fork block if running against a local node
        vm.createSelectFork(vm.rpcUrl("mainnet"));

        admin = new ProxyAdmin();
        implementation = new ImbuedData();
        //bytes memory calld = abi.encodeWithSignature("initialize(address[],address)", [address(this)], imbuedDeployer);
        proxy = new TransparentUpgradeableProxy(address(implementation), address(admin), "");
        address[] memory imbuers = new address[](1);
        imbuers[0] = address(this);
        dataContract = ImbuedData(address(proxy));
        dataContract.initialize(imbuers, imbuedDeployer);

        vm.prank(imbuedDeployer); nft.setDataContract(address(implementation));
    }

    function testLove() public {
        bytes memory expectedEntropy = hex"0000a6dd0000669400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000084e4000000000000c6beb4b200000000000000000000000000000000000000000000682700000000000000000000000050de00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        for (uint i = 0; i < 100; i++) {
            string[] memory imbs = nft.imbuements(i, 0, 0);
            for (uint j = 0; j < imbs.length; j++) {
                if (bytes32(abi.encodePacked(imbs[j])) != bytes32(0x0)) {
                    address own = nft.ownerOf(i);
                    bytes32 imb = bytes32(bytes(imbs[j]));
                    dataContract.imbueAdmin(i, imb, own, 0); // Not entirerly correct, maybe someone else imbued, but doesn't matter.
                }
            }
        }
        assertEq(expectedEntropy, dataContract.getEntropy(0));
    }

    function testAwe() public {
        bytes memory expectedEntropy = hex"391472920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f7b30000000000000000000000000000d6a100000000000000000000000000000000000000000000000000000000000000000000000000000000cb4a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        for (uint i = 100; i < 200; i++) {
            string[] memory imbs = nft.imbuements(i, 0, 0);
            for (uint j = 0; j < imbs.length; j++) {
                if (bytes32(abi.encodePacked(imbs[j])) != bytes32(0x0)) {
                    address own = nft.ownerOf(i);
                    bytes32 imb = bytes32(bytes(imbs[j]));
                    dataContract.imbueAdmin(i, imb, own, 0); // Not entirerly correct, maybe someone else imbued, but doesn't matter.
                }
            }
        }
        assertEq(expectedEntropy, dataContract.getEntropy(1));
    }

    function calcEntropy(uint256 tokenId, uint256 edition) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(tokenId, edition)));
    }

    function testSuccess() public {
        assertEq(uint(1), 1, "simple");
    }
 
    function testFail(uint256) public {
        assertEq(uint(1), 2, "simple");
    }
}
