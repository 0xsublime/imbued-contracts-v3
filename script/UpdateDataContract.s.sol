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


    address payable constant dataContract_MAINNET = payable(0x069d0d1Bd05A5c6454d08d318eDF493786E57ba4);
    address payable constant dataContract_POLYGON = payable(0xf5840D1E4f0179BF291030594ADa2aB81597eB5a);
    address constant adminContract_MAINNET = 0x9E0DA6C5045423EbFf1f6AbC32d64423f7125024;
    address constant adminContract_POLYGON = 0x0985A0AE172C85Ca9Cde1f21CcFE6CCa8929734e;

    ProxyAdmin admin;
    TransparentUpgradeableProxy proxy;
    ImbuedData dataContract;

    function setUp() public {
    }

    function run() public {
        require(false, "Don't execuite this script by accident");
        string memory network = "polygon";

        if (keccak256(abi.encodePacked(network)) == keccak256(abi.encodePacked("mainnet"))) {
            proxy = TransparentUpgradeableProxy(dataContract_MAINNET);
            admin = ProxyAdmin(adminContract_MAINNET);
        } else if (keccak256(abi.encodePacked(network)) == keccak256(abi.encodePacked("polygon"))) {
            proxy = TransparentUpgradeableProxy(dataContract_POLYGON);
            admin = ProxyAdmin(adminContract_POLYGON);
        } else {
            revert("Invalid network");
        }

        dataContract = ImbuedData(address(proxy));

        //require(false, "Don't run by accident");
        vm.createSelectFork(vm.rpcUrl(network));
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

        ImbuedData.Imbuement memory imb = dataContract.getLastImbuement(100);
        assertEq(imb.imbuement, "to live this is in my own flesh", "Token 100 has correct imbuement");
        assertEq(imb.imbuer, 0x11a3E98d538376108302bE6B38Ad9F183791767d, "Token 100 has correct address");
        assertEq(imb.timestamp, 1656455278, "Token 100 has correct timestamp");

        assertEq(NFT.owner(), IMBUEDDEPLOYER, "NFT owner is deployer");
        assertEq(admin.owner(), IMBUEDDEPLOYER, "ProxyAdmin owner is deployer");
        vm.prank(address(admin)); assertEq(proxy.admin(), address(admin), "Proxy admin is ProxyAdmin");
        assertEq(NFT.dataContract(), address(dataContract), "NFT data contract is data contract");
    }
}
