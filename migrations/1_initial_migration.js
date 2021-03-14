const Migrations = artifacts.require("Migrations");
const data = require('../secret.json');

module.exports = function (deployer, network, accounts) {
  deployer.deploy(Migrations, {from: data.address});
};
