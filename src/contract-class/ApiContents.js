import {abi} from '@contract-build-source/ApiContents'
import Comic from '@models/Comic';
import Episode from '@models/Episode';
import Sales from '@models/Sales'
import Web3Utils from '@utils/Web3Utils'
import BigNumber from 'bignumber.js'

class ApiContents {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getContract() {
    return this._contract;
  }

  // 작품 목록 조회
  async getComics(vue) {
    let result = await this._contract.methods.getComics().call();
    result = Web3Utils.prettyJSON(result);
    if (result.comicAddress.length == 0) {
      return [];
    } else {
      let comics = [];
      let records = JSON.parse(web3.utils.hexToUtf8(result.records));
      let writerNames = await vue.$contract.accountManager.getUserNames(result.writer);
      records.forEach((record, i) => {
        let comic = new Comic(
          result.comicAddress[i],
          record,
          result.totalPurchasedCount[i],
          result.episodeLastUpdatedTime[i],
          result.contentCreationTime[i]
        );
        comic.setWriter(result.writer[i], writerNames[i]);
        comics.push(comic);
      });
      return comics;
    }
  }

  // 작품 조회
  async getComic(address) {
    let result = await this._contract.methods.getComic(address).call();
    result = Web3Utils.prettyJSON(result);
    let comic = new Comic(address, JSON.parse(result.records))
    comic.setWriter(result.writer, result.writerName);
    return comic;
  };

  // 에피소드 목록 조회
  async getEpisodes(address) {
    let result = await this._contract.methods.getEpisodes(address).call();
    result = Web3Utils.prettyJSON(result);
    if (result.episodeIndex.length == 0) {
      return [];
    } else {
      let episodes = [];
      let records = JSON.parse(web3.utils.hexToUtf8(result.records));
      records.forEach((record, i) => {
        let episode = new Episode(
          result.episodeIndex[i],
          i + 1,
          record,
          result.price[i] / Math.pow(10, 18),
          result.isPurchased[i],
          undefined, undefined, undefined,
          result.episodeCreationTime[i]
        );
        episodes.push(episode);
      });
      return episodes;
    }
  }

  async getEpisode(address, key) {
    let result = await this._contract.methods.getEpisode(address, key).call();
    let cuts = await this._contract.methods.getCuts(address, key).call();
    result = Web3Utils.prettyJSON(result);
    let episode = new Episode(
      key,
      0,
      JSON.parse(result.records),
      result.price / Math.pow(10, 18),
      result.isPurchased,
      JSON.parse(cuts),
      new Date(Number(result.publishDate)),
      result.isPublished
    )
    return episode;
  }

  // 작품 등록
  createComic(comic) {
    return this._contract.methods.createComic(JSON.stringify(comic)).send();
  }

  // 작품 수정
  updateComic(address, comic) {
    return this._contract.methods.updateComic(address, JSON.stringify(comic)).send();
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
    return this._contract.methods.updateEpisode(
      address,
      episode.key,
      JSON.stringify({title: episode.title, thumbnail: episode.thumbnail}),
      JSON.stringify(episode.cuts),
      BigNumber(episode.price * Math.pow(10, 18)),
      episode.status,
      new Date(episode.publishedAt).getTime()
    ).send();
  }

  // 예치금 조회
  getInitialDeposit(address) {
    return this._contract.methods.getInitialDeposit(address).call();
  }

  // 내 작품 조회
  async getMyComics(vue) {
    let result = await this._contract.methods.getMyComics().call();
    result = Web3Utils.prettyJSON(result);
    if (result.comicAddress.length == 0) {
      return [];
    } else {
      let comics = [];
      let records = JSON.parse(web3.utils.hexToUtf8(result.records));
      records.forEach((record, i) => {
        let comic = new Comic(result.comicAddress[i], record);
        comic.privateEpisodesCount = Number(result.privateEpisode[i]);
        comic.publishedEpisodesCount = Number(result.publishedEpisode[i]);
        comic.totalPurchasedAmount = Number(result.totalPurchasedAmount[i]);
        comic.isBlock = result.isBlockComic[i]
        comic.setWriter(vue.$store.getters.publicKey, vue.$store.getters.name);
        comics.push(comic);
      });
      return comics;
    }
  }

  // 내 에피소드 목록 조회
  async getMyEpisodes(address) {
    let result = await this._contract.methods.getMyEpisodes(address).call();
    result = Web3Utils.prettyJSON(result);
    if (result.episodeIndex.length == 0) {
      return [];
    } else {
      let episodes = [];
      let records = JSON.parse(web3.utils.hexToUtf8(result.records));
      records.forEach((record, i) => {
        let episode = new Episode(result.episodeIndex[i], i + 1, record, result.price[i] / Math.pow(10, 18));
        episode.publishedAt = result.publishDate[i]
        episode.status = result.isPublished[i];
        episode.purchasedAmount = result.purchasedAmount[i] / Math.pow(10, 18);
        episodes.push(episode);
      });
      return episodes;
    }
  }

  async getMyComicSales(address) {
    let result = await this._contract.methods.getMyComicSales(address).call();
    result = Web3Utils.prettyJSON(result);
    let sales = new Sales();
    sales.favoriteCount = Number(result.favoriteCount);
    sales.totalPurchasedAmount = Number(result.totalPurchasedAmount) / Math.pow(10, 18);
    sales.totalPurchasedCount = Number(result.totalPurchasedCount);
    sales.totalPurchasedUserCount = Number(result.totalPurchasedUserCount);
    return sales;
  }
}

export default ApiContents;