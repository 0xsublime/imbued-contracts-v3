// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";
import "../src/ImbuedData.sol";

contract MigrateImbuements is Script, Test {
    IImbuedNFT constant NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    address constant IMBUEDDEPLOYER = 0x34EeE73e731fB2A428444e2b2957C36A9b145017;

    ImbuedData dataContract;

    function setUp() public {
    }

    function run() public {
        vm.createSelectFork(vm.rpcUrl("polygon"));

        address dataContractAddress = NFT.dataContract();
        TransparentUpgradeableProxy proxy = TransparentUpgradeableProxy(payable(dataContractAddress));
        dataContract = ImbuedData(address(proxy));

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint[] memory tokenIds = new uint[](13);
        bytes32[] memory imbuements = new bytes32[](13);
        address[] memory imbueFors = new address[](13);
        uint96[] memory timestamps = new uint96[](13);

        // tx 0xe8de6779d4f396725319985cd787bf66dc74ef508a4f9ed92268d83e21866f33
        tokenIds[0] = 1;
        imbuements[0] = hex"4672656a2c20497269732c204d616c696e2c2047757374616600000000000000";
        imbueFors[0] = 0xF55DBe114957eAeC2BF06c651B680aDfE39dd581;
        timestamps[0] = 1640636114;
        // tx 0xa86dd27a61cc439978107e75543178637aad83543083b324a2c91004370931f9
        tokenIds[1] = 44;
        imbuements[1] = hex"646f206e6f7420646f7562742c206c6f766520796f757273656c660000000000";
        imbueFors[1] = 0x3E02Ac054398e2C7886A4739AD3214163238872d;
        timestamps[1] = 1640723741;
        // tx 0x128de0e94ed9bcde2169514a5802c91cf30313f6d7b9e0cf04e4fd39f29feb83
        tokenIds[2] = 64;
        imbuements[2] = hex"466163696c69746174696f6e20697320616e20616374206f66204c6f76650000";
        imbueFors[2] = 0xF55DBe114957eAeC2BF06c651B680aDfE39dd581;
        timestamps[2] = 1640732624;
        // tx 0x3c985b32797d425c1bad8a769ded4d89ed038a96fb38b5cd5afc6649599e4ded
        tokenIds[3] = 3;
        imbuements[3] = hex"5769746e65737300000000000000000000000000000000000000000000000000";
        imbueFors[3] = 0x492B1acdb6F1A28418dFc59B4fC9BCF5B8B2D88D;
        timestamps[3] = 1641820991;
        // tx 0x66f9d7c87b0b6253e7ae5b1311cbeacf728c0a6a3a76f06259afa4645784c5ec
        tokenIds[4] = 40;
        imbuements[4] = hex"46616d696c6a0000000000000000000000000000000000000000000000000000";
        imbueFors[4] = 0xF55DBe114957eAeC2BF06c651B680aDfE39dd581;
        timestamps[4] = 1641940066;
        // tx 0x3ba20caf69cc0f6077639b3ba82f62e3bdd3ef34c013d539755c7cc28447b211
        tokenIds[5] = 45;
        imbuements[5] = hex"4265636175736520492063616e206469652c20692063616e204c6f76652e0000";
        imbueFors[5] = 0xF55DBe114957eAeC2BF06c651B680aDfE39dd581;
        timestamps[5] = 1643409121;
        // tx 0xcca47b324a804cf65313446da79b7a60fd0a9573867dd07eca9df72397d6fb08
        tokenIds[6] = 101;
        imbuements[6] = hex"416c6c7420c3a4722070c3a56869747461740000000000000000000000000000";
        imbueFors[6] = 0xF55DBe114957eAeC2BF06c651B680aDfE39dd581;
        timestamps[6] = 1654689162;
        // tx 0xad7f5ba0976fe9dc17d8d663dcfcb33a818f85a94802b61f572559d7770a0ace
        tokenIds[7] = 165;
        imbuements[7] = hex"56696272616e74204c6f76650000000000000000000000000000000000000000";
        imbueFors[7] = 0x2bf33FEA506a6Eb92F8c044cE649939fA6CEAB41;
        timestamps[7] = 1655371866;
        // tx 0xf2a59f72cc13de665baa4ec336061adf95f25a26bfb21ad044d98ce90d51d0a6
        tokenIds[8] = 57;
        imbuements[8] = hex"6d7973656c6620262065766572797468696e67206265796f6e64000000000000";
        imbueFors[8] = 0xeC5E053B5F0a19ccB9a1C392fec5567E821a6a54;
        timestamps[8] = 1655371866;
        // tx 0x6a3732a599f49f96dc66798a1d4c87abaae55e9987659ea967e35eab2f53da5f
        tokenIds[9] = 100;
        imbuements[9] = hex"746f206c697665207468697320697320696e206d79206f776e20666c65736800";
        imbueFors[9] = 0x11a3E98d538376108302bE6B38Ad9F183791767d;
        timestamps[9] = 1656296256;
        // Has a self-transfer, so currently imbued twice: tx 0xb5e35f357e4502e4a13819a3d12368755ca08d4adfac169b399e07d486c2cded
        tokenIds[10] = 100;
        imbuements[10] = hex"746f206c697665207468697320697320696e206d79206f776e20666c65736800";
        imbueFors[10] = 0x11a3E98d538376108302bE6B38Ad9F183791767d;
        timestamps[10] = 1656455278;
        // tx 0xaac72ddf80d2378be00d44d43a72d518fbdbd03d7e50cc86502a6ebec3bc6781
        tokenIds[11] = 144;
        imbuements[11] = hex"486f706500000000000000000000000000000000000000000000000000000000";
        imbueFors[11] = 0x11a3E98d538376108302bE6B38Ad9F183791767d;
        timestamps[11] = 1657072353;
        // tx 0x322a9efe45e36469bc8bde582c07852a07d955d37990ac4b21c61291281829da
        tokenIds[12] = 136;
        imbuements[12] = hex"43616461207265737069726f20657320756e2061736f6d62726f000000000000";
        imbueFors[12] = 0x11a3E98d538376108302bE6B38Ad9F183791767d;
        timestamps[12] = 1657072502;

        dataContract.imbueAdmin(tokenIds, imbuements, imbueFors, timestamps);

        vm.stopBroadcast();
        checkDeployment();
    }

    function checkDeployment() public {
        bytes memory loveExpectedEntropy = hex"0000a6dd0000669400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000084e4000000000000c6beb4b200000000000000000000000000000000000000000000682700000000000000000000000050de00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        bytes memory aweExpectedEntropy = hex"391472920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f7b30000000000000000000000000000d6a100000000000000000000000000000000000000000000000000000000000000000000000000000000cb4a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        bytes memory loveEntropy = dataContract.getEntropy(0);
        bytes memory aweEntropy = dataContract.getEntropy(1);
        assertEq(loveEntropy, loveExpectedEntropy, "Love entropy should match");
        assertEq(aweEntropy, aweExpectedEntropy, "Awe entropy should match");
        dataContract.getNumImbuements(101);
        ImbuedData.Imbuement memory imb = dataContract.getLastImbuement(9876);
        assertEq(imb.imbuement, "\"this token does not exist\"", "Imbuement 1337 has correct imbuement");
        assertEq(imb.imbuer, 0xdEad000000000000000000000000000000000000, "Imbuement 1337 has correct address");
        assertEq(imb.timestamp, 12345, "Imbuement 1337 has correct timestamp");

        assertEq(NFT.owner(), IMBUEDDEPLOYER, "NFT owner is deployer");
        assertEq(NFT.dataContract(), address(dataContract), "NFT data contract is data contract");
    }
}
