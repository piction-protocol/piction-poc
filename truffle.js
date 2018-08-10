require('dotenv-flow').config({default_node_env: 'ropsten'});
var HDWalletProvider = require("truffle-hdwallet-provider-privkey");

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
    ropsten: {
      provider: new HDWalletProvider(process.env.PRIVATE_KEY, "https://ropsten.infura.io/"),
      network_id: 3,
      gas: 7000000,
      gasPrice: 100000000000
    }
  }
};
