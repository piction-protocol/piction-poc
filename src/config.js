import store from './store'
import councilSource from '../build/contracts/Council.json'

export default async (network) => {
  const returnConfig = {};
  const councilAddress = councilSource.networks[network].address;
  const council = new web3.eth.Contract(councilSource.abi, councilAddress);
  const pictionConfig = await council.methods.getPictionConfig().call();

  returnConfig.account = store.getters.publicKey.toLowerCase();

  returnConfig.pictionAddress = {
    council: councilAddress,
    pxl: pictionConfig.pxlAddress_,
    userPaybackPool: pictionConfig.pictionAddress_[0],
    depositPool: pictionConfig.pictionAddress_[1],
    pixelDistributor: pictionConfig.pictionAddress_[2],
    report: pictionConfig.pictionAddress_[3],
    contentsDistributor: pictionConfig.pictionAddress_[4]
  };

  returnConfig.managerAddress = {
    contentsManager: pictionConfig.managerAddress_[0],
    fundManager: pictionConfig.managerAddress_[1],
    accountManager: pictionConfig.managerAddress_[2],
  };

  returnConfig.apiAddress = {
    apiContents: pictionConfig.apiAddress_[0],
    apiReport: pictionConfig.apiAddress_[1],
    apiFund: pictionConfig.apiAddress_[2],
  };

  returnConfig.pictionValue = {
    initialDeposit: Number(pictionConfig.pictionValue_[0]),
    reportRegistrationFee: Number(pictionConfig.pictionValue_[1]),
    depositReleaseDelay: Number(pictionConfig.pictionValue_[2]),
    defaultGas: 6000000,
  };

  return returnConfig;
}