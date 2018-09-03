require('dotenv-flow').config({default_node_env: 'private'});
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
    },
    private: {
      provider: new HDWalletProvider(process.env.PRIVATE_KEY, "http://52.203.39.129:8545/"),
      network_id: 2323,
      gas: 6000000,
      gasPrice: 100000000000
    }
  }
};
