//SPDX-License-Identifier: MIT
//contracts\WoofieToken.sol:WoofieToken

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WoofieToken is ERC20 {

    constructor (uint256 _totalSupply) ERC20("Woofie Token", "WOOFIE") {
        _mint(msg.sender, _totalSupply*10**decimals());
    }

}


