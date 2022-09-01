//SPDX-License-Identifier: MIT
//contracts\WoofieToken.sol:WoofieToken

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDC is ERC20 {

    constructor (uint256 _totalSupply) ERC20("USD Coin", "USDC") {
        _mint(msg.sender, _totalSupply*10**decimals());
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

}