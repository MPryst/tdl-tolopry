// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)
pragma solidity ^0.8.1;


import "./ERC20.sol";
import "hardhat/console.sol";
import "./NFTPrize.sol";


contract ToLoPryCoin is ERC20 {    


  string public constant _name = "ToLoPry Coin";
  string public constant _symbol = "TLP";
  uint256 public constant _weiToTLP = 25000; // 25.000 wei = 1 TLP
  uint8 public constant _decimals = 2;
  uint256 public constant INITIAL_SUPPLY = 100000 * (10 ** uint256(_decimals));
 
  address payable public owner;
  address public allowedOperator;


  constructor() ERC20(_name, _symbol, INITIAL_SUPPLY) payable {
    require(msg.value > 0, "Need some initial currency to start functioning.");
    owner = payable(msg.sender);
   }


   function setOperator(address operator) public {
     require(_msgSender() == owner, "Only the owner can designate an operator.");
     allowedOperator = operator;
   }


   function deposit() public payable {
     require(msg.value >= 25000 wei, "1 TLP token is worth 25.000 wei");
     uint tokenAmount = msg.value * 1 / 25000; // 1 TLP = 0.00025 ether, rounded down.
     console.log("User exchanged wei for %s TLP Tokens", tokenAmount);
     increaseAllowance(msg.sender, tokenAmount);    
   }


   function withdraw() public returns (bool) {
    address payable payableSender = payable(msg.sender);
    uint256 prizeToClaim = _weiToTLP * balanceOf(msg.sender);


    if (decreaseAllowance(msg.sender, balanceOf(msg.sender))) {
      address payable receiver = payableSender;
      receiver.transfer(prizeToClaim);
    } else {
      return false;
    }


     return true;    
   }


  // A modified version of decreaseAllowance, to be called from an allowed contract, on behalf of the spender.
   function burnAmountFor(address spender, uint256 amount) public returns (bool) {
     require(_msgSender() == allowedOperator || _msgSender() == owner, "Coins: Can only be managed by authorized accounts.");
      address coinOwner = spender;
      uint256 currentAllowance = allowance(coinOwner, spender);
      require(currentAllowance >= amount, "ERC20: decreased allowance below zero");
      unchecked {
          _approve(coinOwner, spender, currentAllowance - amount);
      }
       
      _burn(spender, amount);
      return true;      
   }


// A modified version of decreaseAllowance, to be called from an allowed contract, on behalf of the spender.
   function mintAmountFor(address spender, uint256 amount) public returns (bool) {
     require(_msgSender() == allowedOperator || _msgSender() == owner, "Coins: Can only be managed by authorized accounts.");
     address coinOwner = spender;
        _approve(coinOwner, spender, allowance(coinOwner, spender) + amount);
        _mint(spender, amount);
        return true;
    }


   function contractTotalBalance() public view returns (uint256) {
     return address(this).balance;
   }
}