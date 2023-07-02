// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Casino.sol";
import "./ToLoPryCoin.sol";

contract Blackjack {
    address owner;
    Deck public deck;
    string[] private possibleSuits = [
        "Corazones",
        "Picas",
        "Diamantes",
        unicode"Tréboles"
    ];
    ToLoPryCoin public coin;
    uint256 dealerSum;

    mapping(address => uint256) playerSums;
    mapping(address => uint256) playerBets;

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

    constructor() {
        owner = msg.sender;
        coin = new ToLoPryCoin();
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

        emit CasinoValue(card.number);
    }

    function joinGame() public {
        playerSums[msg.sender] = 0;
        playerBets[msg.sender] = 0;
        coin.transfer(msg.sender, 1000);
    }

    function placeBet(uint256 betValue) public {
        playerBets[msg.sender] = betValue;
        coin.transferFrom(msg.sender, address(this), betValue);
    }

    function deal() public {
        require(playerBets[msg.sender] > 0);

        for (uint256 j = 0; j < 2; j++) {
            Card memory card = this.getCard();
            playerSums[msg.sender] += card.number;
        }

        if (playerSums[msg.sender] == 21) {
            emit NaturalBlackjack();
            if (checkGameOver()) {
                checkWinner();
            }
        }
    }

    function hit() public {
        Card memory card = this.getCard();
        playerSums[msg.sender] += card.number;
        if (playerSums[msg.sender] == 21) {
            emit NaturalBlackjack();
        }

        if (checkGameOver()) {
            checkWinner();
        }
    }

    function stand() public {
        while (dealerSum < 17) {
            Card memory card = this.getCard();
            dealerSum += card.number;
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

        return false;
    }

    function checkWinner() public returns (address) {
        uint256 betMultiplication = 2;
        if (playerSums[msg.sender] == 21) {
            betMultiplication = 3;
        }

        if (playerSums[msg.sender] > 21 && dealerSum < playerSums[msg.sender]) {
            emit PlayerWon(address(this));
            playerBets[msg.sender] = 0;
            return address(this);
        }

        if (dealerSum > 21) {
            emit PlayerWon(msg.sender);
            coin.transfer(msg.sender, playerBets[msg.sender] * 2);
            playerBets[msg.sender] = 0;
            return msg.sender;
        }

        if (dealerSum > playerSums[msg.sender]) {
            emit PlayerWon(address(this));
            playerBets[msg.sender] = 0;
            return address(this);
        }

        emit PlayerWon(msg.sender);
        coin.transfer(msg.sender, playerBets[msg.sender] * 2);
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
        emit CardDealt(card);
        return card;
    }
}
