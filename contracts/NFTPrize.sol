// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NFTPrize is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;
    address public _allowedMinter;
    address public _owner;


    constructor() ERC721("Blackjack ToLoPry Prize", "NFT") {
        _owner = msg.sender;        
    }
   
    function mintTo(address recipient) public returns (uint256)
    {        
        require(msg.sender == _allowedMinter, "Only the allowed address can mint an NFT.");
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }


    function setAllowedMinter(address allowedMinter) public {
        // The allowed minter will be the Blackjack contract, and can only be changed by the contract owner.
        require(msg.sender == _owner, "NFTPrize: Only the owner can change the allowed minter");
        _allowedMinter = allowedMinter;
        setApprovalForAll(allowedMinter, true);
    }
}