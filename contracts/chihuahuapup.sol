// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract WOOFIEPUPChihuahua is ERC721, ERC721Enumerable, Pausable, Ownable {

    // ===== 1. Property Variables ===== //

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    IERC20 private immutable _usdc;
    IERC20 private immutable _woofie;
    address private immutable _treasure_donation;
    mapping (address => bool) public _MonthlyIsActive;
    mapping (uint => address) public _MonthlyController;
    uint private _total_mapping = 0;
    mapping (address => uint) public _MonthlyDeadLine;
    mapping (address => uint) public _lastWithdrawal;
    uint256 public _MonthlyPrice = 25*10**5;
    mapping (address => uint256) private _RewardBalance;

    uint256 public MINT_PRICE_IN_USDC = 200*10*6;
    uint256 public MINT_PRICE_WOOFIE = 15*10*17;
    uint public MAX_SUPPLY = 15000;

    // ===== 2. Lifecycle Methods ===== //

    constructor(address usdc_, address woofie_, address marketing_) ERC721("$WOOFIEPUP - Chihuahua pup", "WOOFIEPUPChihuahua") {
        // Start token ID at 1. By default is starts at 0.
        _usdc = IERC20(usdc_);
        _woofie = IERC20(woofie_);
        _treasure_donation = marketing_;
        _tokenIdCounter.increment();
    } 

    function aclaimReward() public {
        require(_MonthlyIsActive[msg.sender], "you'll need to pay the monthly fees to be able to withdraw ");
        require(_MonthlyDeadLine[msg.sender] > block.timestamp, "you'll need to pay the monthly fees to be able to withdraw ");
        require(_RewardBalance[msg.sender] > 0, "you'll don't have any rewards to withdraw");
        require(_lastWithdrawal[msg.sender] < block.timestamp, "you'll need to wait until the next day to withdraw");
        require(_woofie.balanceOf(address(this)) > _RewardBalance[msg.sender], "Not Enough WOOFIE Balance Try Again Later");
        _lastWithdrawal[msg.sender] = block.timestamp + 86400;
        _woofie.transfer(msg.sender, _RewardBalance[msg.sender]);
        _RewardBalance[msg.sender] = 0;
    }

    function monthlyFeeCollector () public payable {
        require(msg.value >= _MonthlyPrice, "Not enouth to pay the monthly fee");
        require(!_MonthlyIsActive[msg.sender], "You already payed the monthly fee");
        require(_usdc.balanceOf(msg.sender) >= _MonthlyPrice, "Not Enough USDC Balance Try Again Later");
        _usdc.transferFrom(msg.sender, address(this), _MonthlyPrice);
        _MonthlyIsActive[msg.sender] = true;
        _MonthlyDeadLine[msg.sender] = block.timestamp + 2592000;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to) public payable {
        // ❌ Check that totalSupply is less than MAX_SUPPLY
        require(totalSupply() < MAX_SUPPLY, "Can't mint anymore tokens.");
        require(msg.value >= MINT_PRICE_IN_USDC, "Not enought USDC");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _usdc.transferFrom(msg.sender, address(this), msg.value);
        _usdc.transfer( _treasure_donation, msg.value/2);
        _total_mapping += 1;
        _MonthlyController[_total_mapping] = msg.sender;
        for ( uint i = 0; i < _total_mapping; i++) {
            if (_MonthlyIsActive[_MonthlyController[i]]) {
                _RewardBalance[_MonthlyController[i]] += getWoofiePriceInUsdc() * MINT_PRICE_IN_USDC * 117 / 100;
            }
        }
        _safeMint(to, tokenId);

    }

    function woofieMint(address to) public payable {
        // ❌ Check that totalSupply is less than MAX_SUPPLY
        uint256 tokenPrice = getWoofiePriceInUsdc() * MINT_PRICE_IN_USDC;
        require(totalSupply() < MAX_SUPPLY, "Can't mint anymore tokens.");
        require(msg.value >= tokenPrice, "Not enought WOOFIE");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _woofie.transferFrom(msg.sender, address(this), msg.value);
        _woofie.transfer(_treasure_donation, msg.value/2);
        _total_mapping += 1;
        _MonthlyController[_total_mapping] = msg.sender;
        for ( uint i = 0; i < _total_mapping; i++) {
            if (_MonthlyIsActive[_MonthlyController[i]]) {
                _RewardBalance[msg.sender] += tokenPrice * 117 / 100;
            }
        }
        _safeMint(to, tokenId);

    }

    function getReward(address from) public view returns(uint256) {
        return _RewardBalance[from];
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://linktophoto.com";
    }

    function getWoofiePriceInUsdc() internal virtual returns (uint256) {
        return MINT_PRICE_WOOFIE;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    { 
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}