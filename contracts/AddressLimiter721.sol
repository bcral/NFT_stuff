//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract AddressLimiter721 is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter public tokenCounter;
    uint256 MAX_SUPPLY;
    uint256 ADDRESS_MAX;

    constructor(uint256 _MAX_SUPPLY, uint256 _ADDRESS_MAX, string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        MAX_SUPPLY = _MAX_SUPPLY;
        ADDRESS_MAX = _ADDRESS_MAX;
    }

    // ********************
    // Modifiers

    // Checks before and after transaction to ensure the amount of tokens allowed to 
    // be owned by any address isn't passed during the transaction
    modifier checkAddressMax (address _to) {
        require(balanceOf(_to) < ADDRESS_MAX, "This address is not allowed to own any more of this asset.");
        _;
        require(balanceOf(_to) <= ADDRESS_MAX, "This address is not allowed to own this much of this asset.");
    }

    // Checks before transaction to ensure that the max amount of token supply isn't
    // surpassed
    modifier checkMax () {
        require(tokenCounter.current() < MAX_SUPPLY, "Max supply is already reached.");
        _;
    }

    // ********************
    // Functions

    // Mint with max supply andd max address limiters
    function mint(
        address to) public virtual checkAddressMax(to) checkMax {
        _safeMint(to, tokenCounter.current(), "");
        tokenCounter.increment();
    }

    // Transfer with address ownership limit check
    function transferFrom( 
        address from,
        address to,
        uint256 tokenId) public virtual override checkAddressMax(to) {
        super.transferFrom(from, to, tokenId);
    }

    // Safe transfer with address ownership limit check
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId) public virtual override checkAddressMax(to) {
        super.safeTransferFrom(from, to, tokenId);
    }

    // Safe transfer with address ownership limit check with data
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data) public virtual override checkAddressMax(to) {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}
