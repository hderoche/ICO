const MyToken = artifacts.require("MyToken");
const data = require('../secret.json');
module.exports = function (deployer, network, accounts) {
  deployer.deploy(MyToken, 10, 1000000, {from: data.address});
};
