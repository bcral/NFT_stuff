// SPDX-License-Identifier: MIT
// Based on: OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

abstract contract Counter {
    struct Count {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    mapping(uint256 => Count) public countIndex;

    function current(uint256 index) internal view returns (uint256) {
        return countIndex[index]._value;
    }

    function increment(uint256 index) internal {
        unchecked {
            countIndex[index]._value += 1;
        }
    }

    function decrement(uint256 index) internal {
        uint256 value = countIndex[index]._value;
        require(value > 0, "Count: decrement overflow");
        unchecked {
            countIndex[index]._value = value - 1;
        }
    }

    function add(uint256 index, uint256 newValue) internal {

        countIndex[index]._value += newValue;
    }

    function sub(uint256 index, uint256 newValue) internal {
        uint256 value = countIndex[index]._value;
        require(value > 0, "Count: decrement overflow");

        countIndex[index]._value = value - newValue;
    }
}