// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


import "./ToLoPryCoin.sol";
import "./NFTPrize.sol";
import "hardhat/console.sol";


contract Blackjack {
    address owner;
    NFTPrize public nftMinter;
    ToLoPryCoin public coin;
   
    Deck public deck;
    string[] private possibleSuits = [
        "Corazones",
        "Picas",
        "Diamantes",
        unicode"Tréboles"
    ];
   
    uint256 dealerSum;


    mapping(address => uint256) playerSums;
    mapping(address => uint256) playerBets;
    mapping(address => uint256) playerCredit;




    event CardDealt(Card);
    event CasinoValue(uint256);
    event PlayerWon(address);
    event NaturalBlackjack();


    struct Card {
        uint number;
        string suit;
    }


    struct Deck {
        Card[52] cards;
        Card[] usedCards;
        uint currentIndex;
    }


    constructor(address coinContractAddress, address nftContractAddress ) {
        owner = msg.sender;        
        coin = ToLoPryCoin(coinContractAddress);
        nftMinter = NFTPrize(nftContractAddress);        
        createDeck();
    }


    function getDeck() public view returns (Deck memory) {
        return deck;
    }


    function createDeck() private {
        uint index = 0;
        for (uint256 i = 0; i < 4; i++) {
            for (uint256 j = 1; j <= 13; j++) {
                deck.cards[index] = Card(j, possibleSuits[i]);
                index++;
            }
        }
        shuffleDeck(uint256(keccak256(abi.encodePacked(block.timestamp))));
    }


    function shuffleDeck(uint256 _randomNumber) public payable {
        require(!checkGameOver(), "Blackjack: Can't shuffle an ongoing game!");
        require(deck.cards.length > 0, "Array is empty");


        for (uint256 i = 0; i < deck.cards.length; i++) {  
            uint256 n = i + (_randomNumber % (deck.cards.length - i));
            if (i != n) {
                Card memory temp = deck.cards[n];
                deck.cards[n] = deck.cards[i];
                deck.cards[i] = temp;
            }
        }
    }


    function startGame() public {
        Card memory card;
        for (uint256 i = 0; i < 2; i++) {
            card = this.getCard();
            dealerSum += card.number;
        }
        console.log("Game started");


        emit CasinoValue(card.number);
    }


    function joinGame() public {
        require(!checkGameOver(), "Blackjack: Can't join while on an ongoing game!");
        playerSums[msg.sender] = 0;
        playerBets[msg.sender] = 0;
        // Coin interaction: Joining a table effectively burns some users tokens.        
        // And to avoid making unnecesary contract calls in the future, we keep a local score.
        if (coin.burnAmountFor(msg.sender, 1000)) {
            playerCredit[msg.sender] += 1000;
        }
        console.log("Current player credit %s",  playerCredit[msg.sender]);
    }


    function placeBet(uint256 betValue) public {
        require(playerCredit[msg.sender] >= betValue, "Blackjack: Can't bet more than on the table!");


        playerBets[msg.sender] = betValue;        
        // Coin "interaction": We just update the credit of the player.
        playerCredit[msg.sender] -= betValue;
        console.log("Current player credit %s",  playerCredit[msg.sender]);        
    }


    function deal() public {
        require(playerBets[msg.sender] > 0);


        for (uint256 j = 0; j < 2; j++) {
            Card memory card = this.getCard();
            playerSums[msg.sender] += card.number;
           
        }


        if (playerSums[msg.sender] == 21) {
            emit NaturalBlackjack();
            nftMinter.mintTo(msg.sender);
            if (checkGameOver()) {                
                checkWinner();
            }
        }
    }


    // Test method ONLY FOR DEMO: To test the event + NFT minting.
     function fakeNaturalBlackjack() public {
          emit NaturalBlackjack();
           nftMinter.mintTo(msg.sender);
     }


    function hit() public {
        Card memory card = this.getCard();
        playerSums[msg.sender] += card.number;
        console.log("Curent card value: %s", playerSums[msg.sender]);
        if (playerSums[msg.sender] == 21) {
            console.log("BLACKJACK!");
            emit NaturalBlackjack();
            nftMinter.mintTo(msg.sender);
        }


        if (checkGameOver()) {
            console.log("Game Over");
            checkWinner();
        }
    }


    function stand() public {
        while (dealerSum < 17) {
            Card memory card = this.getCard();
            dealerSum += card.number;
            console.log("Current dealt number: %s", dealerSum);
        }
        checkWinner();
    }


    function checkGameOver() public view returns (bool) {
        if (playerSums[msg.sender] > 21) {
            return true;
        }


        if (playerSums[msg.sender] == 21 && dealerSum != 21) {
            return true;
        }


        console.log("Still playing!");
        return false;
    }


    function checkWinner() public returns (address) {
        uint256 betMultiplication = 2;
        if (playerSums[msg.sender] == 21) {
            betMultiplication = 3;
        }


        if (playerSums[msg.sender] > 21 && dealerSum < playerSums[msg.sender]) {
            emit PlayerWon(address(this));
            console.log("The house won!");
            playerBets[msg.sender] = 0;
            return address(this);
        }


        if (dealerSum > 21) {
            emit PlayerWon(msg.sender);
            console.log("Player won!");          
            // Coin "interaction": Increase the player's credit on the table.
            playerCredit[msg.sender] += playerBets[msg.sender] * betMultiplication;            
            playerBets[msg.sender] = 0;
            return msg.sender;
        }


        if (dealerSum > playerSums[msg.sender]) {
            console.log("The house won!");
            emit PlayerWon(address(this));
            playerBets[msg.sender] = 0;
            return address(this);
        }


        console.log("Player won!");
        emit PlayerWon(msg.sender);
        // Coin "interaction": Increase the player's credit
        playerCredit[msg.sender] +=  playerBets[msg.sender] * betMultiplication;
        playerBets[msg.sender] = 0;
        return msg.sender;
    }


    function getCard() public returns (Card memory) {
        if (deck.currentIndex > 51) {
            shuffleDeck(uint256(keccak256(abi.encodePacked(block.timestamp))));
            deck.currentIndex = 0;
        }
        Card memory card = deck.cards[deck.currentIndex];
        deck.currentIndex++;
        console.log("Card %s %s dealt.", card.number, card.suit);
        emit CardDealt(card);
        return card;
    }


    // Coin interaction: Claim the current tokens and "leave the table" by reseting the playerCredit.
    function claimTokens() public {
        require((playerSums[msg.sender] == 0 && playerBets[msg.sender] == 0) || checkGameOver(), "Can't leave an ongoing game!");
        require(playerCredit[msg.sender] > 0, "Blackjack: No tokens to claim!");


        if (coin.mintAmountFor(msg.sender, playerCredit[msg.sender])) {
            console.log("Claimed %s tokens back!",playerCredit[msg.sender]);
            playerCredit[msg.sender] = 0;
        }
    }


    function currentPlayerCredit() public view returns (uint256) {
     return playerCredit[msg.sender];
   }
}
