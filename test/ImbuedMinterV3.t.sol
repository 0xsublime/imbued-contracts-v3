// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import "forge-std/Test.sol";
import "../src/ImbuedMinterV3.sol";
 
contract MinterTest is Test {
    ImbuedMintV3 public minter;
 
    function setUp() public {
        minter = new ImbuedMintV3();
    }
 
    function testSuccess() public {
        assertEq(uint(1), 1, "simple");
    }
 
    function testFail(uint256 x) public {
        assertEq(uint(1), 2, "simple");
    }
}
