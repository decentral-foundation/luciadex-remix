// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract CustomToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol){
        _mint(msg.sender,1000 * 10 ** 18);
   }
}

contract Uniswap{
    string [] public tokens = ['CoinA', 'CoingB', 'CoinC'];
    mapping(string => ERC20) public tokenInstanceMap;
    uint ethValue = 1000000000000000;
    constructor() {
        for (uint i = 0; i < tokens.length; i++) {
            CustomToken token = new CustomToken(tokens[i], tokens[i]);
            tokenInstanceMap[tokens[i]] = token;
        }
    }

    function getBalance(string memory tokenName, address _address) public view returns (uint256){
        return tokenInstanceMap[tokenName].balanceOf(_address);
    }
    
    function swapEthToToken(string memory tokenName) public payable returns (uint) {
        uint inputValue = msg.value;
        uint outputValue = (inputValue / ethValue) * 10 ** 18;
        require(tokenInstanceMap[tokenName].transfer(msg.sender, outputValue));
        return outputValue;
    }
    
    function swapTokenToEth(string memory tokenName, uint _amount) public returns (uint) {
        uint exactAmount = _amount / 10 ** 18;
        uint ethToBeTransferred = exactAmount * ethValue; 
        require(address(this).balance >= ethToBeTransferred, "DEX is running low on balance");
        payable(msg.sender).transfer(ethToBeTransferred);
        require(tokenInstanceMap[tokenName].transferFrom(msg.sender, address(this), _amount));
        return ethToBeTransferred;
    }
    
    function swapTokenToToken(string memory srcTokenName, string memory destTokenName, uint _amount) public {
        require(tokenInstanceMap[srcTokenName].transferFrom(msg.sender, address(this), _amount));
        require(tokenInstanceMap[destTokenName].transfer(msg.sender, _amount));
    }
    
    function getEthBalance() public view returns (uint) {
        return address(this).balance;
    }
}
