// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)
pragma solidity ^0.8.1;

import "./ERC20.sol";
import "hardhat/console.sol";

contract ToLoPryCoin is ERC20 {

  string public constant _name = "Casino TLP";
  string public constant _symbol = "TLP";
  uint256 public constant _weiToTLP = 25000; // 25.000 wei = 1 TLP
  uint8 public constant _decimals = 2;
  uint256 public constant INITIAL_SUPPLY = 100000 * (10 ** uint256(_decimals));
  address payable public owner;

  constructor() ERC20(_name, _symbol, INITIAL_SUPPLY) payable {
    owner = payable(msg.sender);
   }

   function deposit() public payable {
     require(msg.value >= 25000 wei, "1 TLP token is worth 25.000 wei");
     uint tokenAmount = msg.value * 1 / 25000; // 1 TLP = 0.00025 ether, rounded down.
     console.log(tokenAmount);
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

   function contractTotalBalance() public view returns (uint256) {
     return address(this).balance;
   }
}