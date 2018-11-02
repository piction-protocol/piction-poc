export default class SupporterPool {
  constructor(fund, index, distribution) {
    this.index = index;
    this.amount = web3.utils.fromWei(distribution.amount);
    this.distributableTime = Number(distribution.distributableTime);
    this.distributedTime = Number(distribution.distributedTime);
    this.isVoting = distribution.isVoting;
    this.state = Number(distribution.state);
    this.votingCount = Number(distribution.votingCount);
    this.startTime = (this.distributableTime == 0) ? 0 : this.distributableTime - fund.interval;
    this.endTime = this.distributableTime;
  }

  isCurrentPool() {
    const now = new Date().getTime();
    return this.startTime < now && now < this.endTime;
  }

  completed() {
    if (this.endTime < new Date().getTime()) {
      return true;
    } else {
      return false;
    }
  }

  getStateString() {
    if (this.state == 0) {
      if (this.isCurrentPool()) {
        return '투표중';
      } else {
        return '지급전';
      }
    } else if (this.state == 1) {
      return '지급완료';
    } else if (this.state == 2) {
      return '지급거절';
    } else {
      return null
    }
  }
}