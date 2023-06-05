# tdl-tolopry
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
