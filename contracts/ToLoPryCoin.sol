// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.1;

import "./ERC20.sol";


contract ToLoPryCoin is ERC20 {  
  
  string public constant _name = "ToLoPry";
  string public constant _symbol = "TLP";
  uint8 public constant _decimals = 2;
  uint256 public constant INITIAL_SUPPLY = 100000 * (10 ** uint256(_decimals));
  
  constructor() ERC20(_name, _symbol, INITIAL_SUPPLY)  { }
    
}