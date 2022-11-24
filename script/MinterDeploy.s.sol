// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";
import "../src/ImbuedMinterV3.sol";

contract MinterDeploy is Script, Test {

    IImbuedNFT constant NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    address constant IMBUEDDEPLOYER = 0x34EeE73e731fB2A428444e2b2957C36A9b145017;
    address constant METAVERSE_MIAMI_TICKET = 0x9B6F8932A5F75cEc3f20f91EabFD1a4e6e572C0A;

    ImbuedData constant dataContract = ImbuedData(0x069d0d1Bd05A5c6454d08d318eDF493786E57ba4);

    ImbuedMintV3 minter; 

    function setUp() public {}

    function run() public {
        require(false, "Don't execuite this script by accident");
        require(false, "This is depraecated, use DataDeploy.s.sol and MinterDeploy.s.sol");
        vm.createSelectFork(vm.rpcUrl("polygon"));
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        minter = new ImbuedMintV3(METAVERSE_MIAMI_TICKET);
        NFT.setMintContract(address(minter));

        bytes32 role = dataContract.IMBUER_ROLE();
        dataContract.grantRole(role, address(minter));

        vm.stopBroadcast();
        checkDeployment();
    }

    function checkDeployment() public {
        assertEq(NFT.owner(), IMBUEDDEPLOYER, "NFT owner is deployer");
        assertEq(minter.owner(), IMBUEDDEPLOYER, "Minter owner is deployer");
        assertEq(NFT.mintContract(), address(minter), "NFT mint contract is minter");
        assertEq(NFT.dataContract(), address(dataContract), "NFT data contract is data contract");
    }
}
