import Writer from '@models/Writer'

export default class SupporterPool {
  constructor(supporter = {investment: '0', collection: '0', distributionRate: '0', reward: '0'}) {
    this.investment = web3.utils.fromWei(supporter.investment);
    this.collection = web3.utils.fromWei(supporter.collection);
    this.distributionRate = web3.utils.fromWei((supporter.distributionRate * 100).toString());
    this.reward = web3.utils.fromWei(supporter.reward);
    this.writer = new Writer();
  }
}