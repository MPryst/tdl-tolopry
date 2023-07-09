# tdl-tolopry
# Remix
## Upload the repository code into a new Remix Workspace.
## Deploy the ToLoPryCoin contract with some ether/gwei/wei (1 ether, for example)
## Deploy the NFTPrize contract with the ToLoPryCoin address as parameter
## Deploy the Blackjack contract with both ToLoPryCoin and NFTPrize addresses as parameters
## Call ToLoPryCoin.setOperator with the address of the Blackjack contract, to allow the Blackjack claiming tokens.
### Note: Keep the same account for all the deployments/transactions, since it will be the owner of the contracts.
#
# Truffle+Ganache (In progress...)
## Install Node.js
## npm install -g truffle 

## Download Ganache (https://trufflesuite.com/ganache/)
## chmod a+x ganache-2.7.1-x86_64.AppImage
## ./ganache-2.7.1-x86_64.AppImage

## Deploying locally
- ./ganache-2.7.1-linux-x86_64.AppImage (on the folder where downloaded)
- truffle compile
- trufle migrate (keep the ToLoPry coin contract address at hand)

## Interacting with the contracts
- with Ganache running and the contracts deployed:
- truffle console 
- let instance = await ToLoPryCoin.deployed()
- let accounts = await web3.eth.getAccounts()
- instance.name()
- instance.balanceOf(accounts[0])

##  Reference:
- https://www.quicknode.com/guides/ethereum-development/smart-contracts/how-to-setup-local-development-environment-for-solidity/how-to-setup-local-development-environment-for-solidity/#truffle
- https://eips.ethereum.org/EIPS/eip-20#methods
