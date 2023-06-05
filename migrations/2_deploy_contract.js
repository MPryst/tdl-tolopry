var Hero = artifacts.require("Hero");
const ToLoPryCoin = artifacts.require("ToLoPryCoin");

module.exports = function(deployer) {

  deployer.deploy(Hero,"Hulk");
  deployer.deploy(ToLoPryCoin, "ToLoPryCoin", "TLP", 100000);

};
