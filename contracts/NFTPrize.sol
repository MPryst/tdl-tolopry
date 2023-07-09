// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NFTPrize is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;
    address public _allowedMinter;


    constructor(address allowedMinter) ERC721("Blackjack ToLoPry Prize", "NFT") {
        // The initial allowed minter, other than the owner, will be the Blackjack contract, sent in the constructor.
        setApprovalForAll(msg.sender, true);
        setApprovalForAll(allowedMinter, true);
        _allowedMinter = allowedMinter;
    }
   
    function mintTo(address recipient) public returns (uint256)
    {        
        require(msg.sender == _allowedMinter, "Only the allowed address can mint an NFT.");
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }
}
