var Hero = artifacts.require("Hero");
const ToLoPryCoin = artifacts.require("ToLoPryCoin");
const CoinFlip = artifacts.require("CoinFlip")
const Blackjack = artifacts.require("Blackjack")

module.exports = async function(deployer) {

  deployer.deploy(Hero,"Hulk");
  deployer.deploy(ToLoPryCoin);
  deployer.deploy(CoinFlip);
  await deployer.deploy(Blackjack);
};
