import {abi} from '@contract-build-source/ApiContents'
import Comic from '@models/Comic';
import Web3Utils from '@utils/Web3Utils'
import BigNumber from 'bignumber.js'

class ApiContents {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  // 작품 목록 조회
  async getComics(accountManagerContract) {
    let result = await this._contract.methods.getComics().call();
    result = Web3Utils.prettyJSON(result);
    if (result.comicAddress.length == 0) {
      return [];
    } else {
      let comics = [];
      let records = JSON.parse(web3.utils.hexToUtf8(result.records));
      let writerNames = await accountManagerContract.getUserNames(result.writer);
      records.forEach((record, i) => {
        let comic = new Comic(
          result.comicAddress[i],
          record,
          result.totalPurchasedCount[i],
          result.episodeLastUpdatedTime[i],
          result.contentCreationTime[i]
        );
        comic.setWriter(result.writer[i], writerNames[i]);
        comics.push(comic.toJSON());
      });
      return comics;
    }
  }

  // 작품 조회
  async getComic(address) {
    let result = await this._contract.methods.getComic(address).call();
    return Web3Utils.prettyJSON(result);
  };

  // 에피소드 목록 조회
  async getEpisodes(address) {
    console.log(address)
    let result = await this._contract.methods.getEpisodes(address).call();
    console.log(result)
    return result;
  }

  // 작품 등록
  createComic(record) {
    return this._contract.methods.createComic(JSON.stringify(record)).send();
  }

  // 에피소드 등록
  createEpisode(address, episode) {
    return this._contract.methods.createEpisode(
      address,
      JSON.stringify({title: episode.title, thumbnail: episode.thumbnail}),
      JSON.stringify(episode.cuts),
      BigNumber(episode.price * Math.pow(10, 18)),
      episode.status,
      new Date(episode.publishedAt).getTime()
    ).send();
  }

  // 에피소드 수정
  updateEpisode(address, episode) {
    return this._contract.methods.createEpisode(
      address,
      episode.index,
      JSON.stringify({title: episode.title, thumbnail: episode.thumbnail}),
      JSON.stringify(episode.cuts),
      BigNumber(episode.price * Math.pow(10, 18)),
      episode.status,
      new Date(episode.publishedAt).getTime()
    ).send();
  }


  // 여기까지

  getContract() {
    return this._contract;
  }

  setRegisterContents(f) {
    this.registerContents = f;
  }

  setEpisodeCreation(f) {
    this.episodeCreation = f;
  }

  addContents(record) {
    return this._contract.methods.addContents(JSON.stringify(record), BigNumber(record.marketerRate).multipliedBy(Math.pow(10, 18))).send();
  }

  updateContent(contentsAddress, record) {
    return this._contract.methods.updateContent(contentsAddress, JSON.stringify(record), BigNumber(record.marketerRate).multipliedBy(Math.pow(10, 18))).send();
  }

  getContentsFullList() {
    return this._contract.methods.getContentsFullList().call();
  }

  getContentsRecord(contentsAddress) {
    return this._contract.methods.getContentsRecord(contentsAddress).call();
  }

  getWriterContentsList(writer) {
    return this._contract.methods.getWriterContentsList(writer).call();
  }

  /**
   * 작품 레코드 조회
   * @param {Address.<Array>} contentsAddress - 작품 주소 목록
   * @returns {Object.<Array>} 작품 레코드 목록
   */
  async getRecords(contentsAddress) {
    var contents = await this._contract.methods.getContentsRecord(contentsAddress).call();
    return contents.records_ ? JSON.parse(web3.utils.hexToUtf8(contents.records_)) : [];
  }

  /**
   * 작품 상세 정보 조회
   * @param {Address} contentsAddress
   * @returns {Object} 작품 상세 정보
   */
  async getContentsDetail(contentsAddress) {
    var result = await this._contract.methods.getContentsDetail(contentsAddress).call();
    result = Web3Utils.prettyJSON(result);
    result.record = JSON.parse(result.record);
    return result;
  }

  getContentsWriterName(contentsAddress) {
    return this._contract.methods.getContentsWriterName(contentsAddress).call();
  }

  addEpisode(contentsAddress, record, cuts, price) {
    return this._contract.methods.addEpisode(
      contentsAddress,
      JSON.stringify(record),
      JSON.stringify(cuts),
      BigNumber(price * Math.pow(10, 18))
    ).send();
  }

  updateEpisode(contentsAddress, index, record, cuts, price) {
    return this._contract.methods.updateEpisode(
      contentsAddress,
      index,
      JSON.stringify(record),
      JSON.stringify(cuts),
      BigNumber(price * Math.pow(10, 18))
    ).send();
  }

  getEpisodeDetail(contentsAddress, index, buyer) {
    return this._contract.methods.getEpisodeDetail(contentsAddress, index, buyer).call();
  }

  getEpisodeFullList(contentsAddress) {
    return this._contract.methods.getEpisodeFullList(contentsAddress).call();
  }

  getEpisodeCuts(contentsAddress, index) {
    return this._contract.methods.getEpisodeCuts(contentsAddress, index).call();
  }

  getInitialDeposit(writer) {
    return this._contract.methods.getInitialDeposit(writer).call();
  }

}

export default ApiContents;