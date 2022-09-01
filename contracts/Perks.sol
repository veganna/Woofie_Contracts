//SPDX-License-Identifier: MIT
//contracts\Perks.sol:Perks

pragma solidity ^0.8.0;


import "./WoofieToken.sol";

contract Perks is WoofieToken {
    bool private _is_golden_hour = false;
    uint private _start_golden_hour = 0;
    uint private _end_golden_hour = 0;
    address private immutable _wormhole;
    address private immutable _marketing;
    address private immutable _treasure_donation;
    address private immutable _owner;
    
    constructor (uint256 _totalSupply, address wormhole_, address marketing_, address treasure_donation_) WoofieToken(_totalSupply) {
        _wormhole = wormhole_;
        _marketing = marketing_;
        _treasure_donation = treasure_donation_;
        _owner = msg.sender;
    }

    function wormholeAddress() public view returns (address) {
        return _wormhole;
    }

    function marketingAddress() public view returns (address) {
        return _marketing;
    }

    function treasureDonationAddress() public view returns (address) {
        return _treasure_donation;
    }

    function isGoldenHour() public view returns (bool){
        return _is_golden_hour;
    }

    function setGoldenHour() public {
        require(msg.sender == _owner, "Only the owner can set the golden hour");
        _is_golden_hour = true;
        _start_golden_hour = block.timestamp;
        _end_golden_hour = _start_golden_hour + 3600;
    }

    function _beforeTokenTransfer() internal virtual {
        if (_is_golden_hour && block.timestamp < _end_golden_hour) {
            _is_golden_hour = false;
        }
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        if (!_is_golden_hour){
            _transfer(owner, to, amount*95/100);
            _transfer(owner, _wormhole, amount/100);
            _transfer(owner, _marketing, amount*2/100);
            _transfer(owner, _treasure_donation, amount*2/100);
        }else{
            _transfer(owner, to, amount);
        }
        return true;
    }
}