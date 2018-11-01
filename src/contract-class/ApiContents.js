import {abi} from '@contract-build-source/ApiContents'
import Comic from '@models/Comic';
import Episode from '@models/Episode';
import Writer from '@models/Writer';
import Sales from '@models/Sales'
import Web3Utils from '@utils/Web3Utils'

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
  async getComics(vue, addrs) {
    let result = addrs ?
      await this._contract.methods.getComicsByAddress(addrs).call() :
      await this._contract.methods.getComics().call();
    result = Web3Utils.prettyJSON(result);
    if (result.comicAddress.length == 0) {
      return [];
    } else {
      let comics = [];
      let records = JSON.parse(web3.utils.hexToUtf8(result.records));
      let writerNames = await vue.$contract.accountManager.getUserNames(result.writer);
      records.forEach((record, i) => {
        let comic = new Comic(record);
        comic.address = result.comicAddress[i].toLowerCase();
        comic.purchasedCount = Number(result.totalPurchasedCount[i]);
        comic.totalPurchasedAmount = new web3.utils.BN(result.totalPurchasedAmount[i]);
        comic.lastUploadedAt = Number(result.episodeLastUpdatedTime[i]);
        comic.createdAt = Number(result.contentCreationTime[i]);
        comic.writer = new Writer(result.writer[i], writerNames[i]);
        comics.push(comic);
      });
      return comics;
    }
  }

  // 작품 조회
  async getComic(address) {
    let result = await this._contract.methods.getComic(address).call();
    result = Web3Utils.prettyJSON(result);
    let comic = new Comic(JSON.parse(result.records))
    comic.address = address;
    comic.writer = new Writer(result.writer, result.writerName);
    return comic;
  };

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
        let comic = new Comic(record);
        comic.address = result.comicAddress[i].toLowerCase();
        comic.privateEpisodesCount = Number(result.privateEpisode[i]);
        comic.publishedEpisodesCount = Number(result.publishedEpisode[i]);
        comic.totalPurchasedAmount = new web3.utils.BN(result.totalPurchasedAmount[i]);
        comic.isBlock = result.isBlockComic[i]
        comic.writer = new Writer(vue.$store.getters.publicKey, vue.$store.getters.name);
        comics.push(comic);
      });
      return comics;
    }
  }

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
        let episode = new Episode(record);
        episode.id = Number(result.episodeIndex[i]);
        episode.number = i + 1;
        episode.price = Number(web3.utils.fromWei(result.price[i]));
        episode.isPurchased = result.isPurchased[i];
        episode.createdAt = Number(result.episodeCreationTime[i]);
        episodes.push(episode);
      });
      return episodes;
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
        let episode = new Episode(record);
        episode.id = Number(result.episodeIndex[i]);
        episode.number = i + 1;
        episode.price = Number(web3.utils.fromWei(result.price[i]));
        episode.publishedAt = Number(result.publishDate[i]);
        episode.status = result.isPublished[i];
        episode.purchasedAmount = Number(web3.utils.fromWei(result.purchasedAmount[i]));
        episodes.push(episode);
      });
      return episodes;
    }
  }

  // 회차 조회
  async getEpisode(address, id) {
    let result = await this._contract.methods.getEpisode(address, id).call();
    let cuts = await this._contract.methods.getCuts(address, id).call();
    result = Web3Utils.prettyJSON(result);
    let episode = new Episode(JSON.parse(result.records));
    episode.id = id;
    episode.price = web3.utils.fromWei(result.price);
    episode.isPurchased = result.isPurchased;
    episode.cuts = JSON.parse(cuts);
    episode.publishedAt = Number(result.publishDate);
    episode.status = result.isPublished;
    return episode;
  }

  // 작품 등록
  createComic(form) {
    return this._contract.methods.createComic(JSON.stringify(form)).send();
  }

  // 작품 수정
  updateComic(address, form) {
    return this._contract.methods.updateComic(address, JSON.stringify(form)).send();
  }

  // 에피소드 등록
  createEpisode(address, episode) {
    return this._contract.methods.createEpisode(
      address,
      JSON.stringify({title: episode.title, thumbnail: episode.thumbnail}),
      JSON.stringify(episode.cuts),
      web3.utils.toWei(String(episode.price)),
      episode.status,
      new Date(episode.publishedAt).getTime()
    ).send();
  }

  // 에피소드 수정
  updateEpisode(address, episode) {
    return this._contract.methods.updateEpisode(
      address,
      episode.id,
      JSON.stringify({title: episode.title, thumbnail: episode.thumbnail}),
      JSON.stringify(episode.cuts),
      web3.utils.toWei(String(episode.price)),
      episode.status,
      new Date(episode.publishedAt).getTime()
    ).send();
  }

  // 예치금 조회
  async getInitialDeposit(address) {
    let result = await this._contract.methods.getInitialDeposit(address).call();
    return Number(web3.utils.fromWei(result));
  }

  async getComicSales(address) {
    let result = await this._contract.methods.getComicSales(address).call();
    result = Web3Utils.prettyJSON(result);
    let sales = new Sales();
    sales.favoriteCount = Number(result.favoriteCount);
    sales.totalPurchasedAmount = Number(web3.utils.fromWei(result.totalPurchasedAmount));
    sales.totalPurchasedCount = Number(result.totalPurchasedCount);
    sales.totalPurchasedUserCount = Number(result.totalPurchasedUserCount);
    return sales;
  }
}

export default ApiContents;