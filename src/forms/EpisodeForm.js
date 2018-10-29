export default class EpisodeForm {
  constructor(episode = {
    id: null,
    title: '',
    thumbnail: '',
    price: 0,
    cuts: [],
    publishedAt: new Date().getTime(),
    status: true
  }) {
    this.id = episode.id;
    this.title = episode.title;
    this.thumbnail = episode.thumbnail;
    this.price = episode.price;
    this.cuts = episode.cuts;
    this.publishedAt = new Date(episode.publishedAt).toISOString();
    this.status = episode.status;
  }
}