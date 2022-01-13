//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract AddressLimiter1155 is ERC1155 {
    using Counters for Counters.Counter;

    Counters.Counter public tokenCounter;
    uint256 MAX_SUPPLY;
    uint256 ADDRESS_MAX;

    constructor(uint256 _MAX_SUPPLY, uint256 _ADDRESS_MAX, string memory _uri) ERC1155(_uri) {
        MAX_SUPPLY = _MAX_SUPPLY;
        ADDRESS_MAX = _ADDRESS_MAX;
    }

}