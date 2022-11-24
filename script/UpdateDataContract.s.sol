// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";
import "../src/ImbuedData.sol";

contract UpdateDataContract is Script, Test {

    IImbuedNFT constant NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    address constant IMBUEDDEPLOYER = 0x34EeE73e731fB2A428444e2b2957C36A9b145017;

    ProxyAdmin constant admin = ProxyAdmin(0x0985A0AE172C85Ca9Cde1f21CcFE6CCa8929734e);
    TransparentUpgradeableProxy constant proxy = TransparentUpgradeableProxy(payable(0xf5840D1E4f0179BF291030594ADa2aB81597eB5a));
    ImbuedData constant dataContract = ImbuedData(address(proxy));

    function setUp() public {
    }

    function run() public {
        require(false, "Don't run by accident");
        vm.createSelectFork(vm.rpcUrl("polygon"));
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ImbuedData implementation = new ImbuedData();
        admin.upgrade(proxy, address(implementation));

        vm.stopBroadcast();
        checkDeployment();
    }

    function checkDeployment() public {
        dataContract.getEntropy(0);
        dataContract.getEntropy(2);
        dataContract.getNumImbuements(101);
        ImbuedData.Imbuement memory imb = dataContract.getLastImbuement(9876);
        assertEq(imb.imbuement, "this token does not exist", "Imbuement 1337 has correct imbuement");
        assertEq(imb.imbuer, address(0xdead), "Imbuement 1337 has correct address");
        assertEq(imb.timestamp, 12345, "Imbuement 1337 has correct timestamp");

        assertEq(NFT.owner(), IMBUEDDEPLOYER, "NFT owner is deployer");
        assertEq(admin.owner(), IMBUEDDEPLOYER, "ProxyAdmin owner is deployer");
        vm.prank(address(admin)); assertEq(proxy.admin(), address(admin), "Proxy admin is ProxyAdmin");
        assertEq(NFT.dataContract(), address(dataContract), "NFT data contract is data contract");
    }
}
