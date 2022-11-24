// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import "forge-std/Test.sol";
 
// For just testing things out quick, checking EVM internals, etc.
contract Quick is Test {

    function setUp() public {
    }

    function testQuick() public {
        string memory foo = "foo bar";
        console.logBytes32(keccak256(abi.encodePacked(foo)));
        bytes32 hello = bytes32("hello");
        console.logBytes32(hello);
        console.logBytes(abi.encodePacked(hello));
        bytes32 hash = keccak256(abi.encodePacked(bytes32(0x0), hello));
        console.logBytes32(hash);

        bytes memory hello_b = abi.encodePacked(hello);
        console.logBytes(hello_b);
        console.log(string(hello_b));
        console.logBytes2(bytes2(hello));
    }
}