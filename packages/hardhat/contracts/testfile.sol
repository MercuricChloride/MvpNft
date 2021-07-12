pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

contract ShouldntHoldNFT{
    uint num = 69;

    function readNum() public view returns (uint) {
        return num;
    }
}
