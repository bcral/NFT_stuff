//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// ** Counter ** contract is similar to a modified ERC1155Supply with OpenZeppelin
// Counter functionality
import "./utils/Counter.sol";
import "hardhat/console.sol";

contract AddressLimiter1155 is ERC1155, Counter, Ownable {

    // Mapping id => maximum supply per id
    mapping(uint256 => uint256) public MAX_ID_SUPPLY;
    // Mapping id => maximum allowed per address
    mapping(uint256 => uint256) public ID_ADDRESS_MAX;

    constructor(string memory _uri) ERC1155(_uri) {}

    // ********************
    // Environment Functions

    function setMaxSupplyForId(uint256 _id, uint256 _newMax) external onlyOwner {
        MAX_ID_SUPPLY[_id] = _newMax;
    }

    function getMaxSupplyForId(uint256 _id) public view returns(uint256) {
        return MAX_ID_SUPPLY[_id];
    }

    function setAddressMaxForId(uint256 _id, uint256 _newMax) external onlyOwner {
        ID_ADDRESS_MAX[_id] = _newMax;
    }

    function getAddressMaxForId(uint256 _id) public view returns(uint256) {
        return ID_ADDRESS_MAX[_id];
    }

    // ********************
    // Modifiers

    // Checks before and after transaction to ensure the amount of tokens allowed to 
    // be owned by any address isn't passed during the transaction
    modifier checkAddressMax (address _to, uint256 _id) {
        require(balanceOf(_to, _id) < ID_ADDRESS_MAX[_id], "This address is not allowed to own any more of this asset.");
        _;
        require(balanceOf(_to, _id) <= ID_ADDRESS_MAX[_id], "This address is not allowed to own this much of this asset.");
    }

    // Checks before and after transaction to ensure that the max amount of token 
    // supply isn't surpassed
    modifier checkMax (uint256 _id) {
        require(current(_id) < MAX_ID_SUPPLY[_id], "Max supply is already reached.");
        _;
        require(current(_id) <= MAX_ID_SUPPLY[_id], "Max supply is already reached.");
    }

    // Checks before and after transaction to ensure the amount of tokens allowed to 
    // be owned by any address isn't passed during the transaction
    modifier checkBatchAddressMax (address _to, uint256[] memory _ids, uint256[] memory _amounts) {
        // Loop through each id and amount
        for (uint i = 0; i < _ids.length; i++) {
            // require balanceOf to address + new minted amount is <= maximum address allowance
            require((balanceOf(_to, _ids[i]) + _amounts[i]) <= ID_ADDRESS_MAX[_ids[i]], "This address is not allowed to own any more of this asset.");
        }
        _;
        for (uint i = 0; i < _ids.length; i++) {
            // require balanceOf to address id is <= maximum address id allowance
            require(balanceOf(_to, _ids[i]) <= ID_ADDRESS_MAX[_ids[i]], "This address is not allowed to own this much of this asset.");
        }
    }

    // Checks before and after transaction to ensure that the max amount of token 
    // supply isn't surpassed
    modifier checkBatchMax (uint256[] memory _ids, uint256[] memory _amounts) {
        // since this modifier runs first, fail fast if array lengths are not equal
        require(_ids.length == _amounts.length);
        // Loop through each id and amount
        for (uint i = 0; i < _ids.length; i++) {
            // require current id supply + new minted supply is <= total allowed supply
            require((current(_ids[i]) + _amounts[i]) <= MAX_ID_SUPPLY[_ids[i]], "Max supply is already reached.");
        }
        _;
        for (uint i = 0; i < _ids.length; i++) {
            // require current id supply is <= total allowed supply
            require(current(_ids[i]) <= MAX_ID_SUPPLY[_ids[i]], "Max supply is already reached.");
        }
    }

    // ********************
    // Modifying Functions

    function mint(
        address to, 
        uint256 id, 
        uint256 amount) public checkMax(id) checkAddressMax(to, id) {
            add(id, amount);
            _mint(to, id, amount, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts) public checkBatchMax(ids, amounts) checkBatchAddressMax(to, ids, amounts) {
            for (uint i = 0; i < ids.length; i++) {
                add(ids[i], amounts[i]);
            }
            _mintBatch(to, ids, amounts, "");
    }

    // Burn token to reduce supply
    // Allow owners to burn their own tokens or approved addresses to burn 
    function burn(
        uint256 id,
        address from,
        uint256 amount) public virtual {
        require(balanceOf(from, id) >= amount  || 
                isApprovedForAll(from, msg.sender), 
                "Token cannot be burned without approval or ownership");
        sub(id, amount);
        _burn(from, id, amount);
    }

    // Call ERC1155 safeTransferFrom without the "data" arg
    function transferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public virtual checkMax(id) checkAddressMax(to, id) {
        super.safeTransferFrom(from, to, id, amount, "");
    }
}