export default class EpisodeForm {
  constructor(episode) {
    this.id;
    this.title;
    this.thumbnail = '';
    this.price;
    this.cuts = [];
    this.publishedAt = new Date().toISOString()
    this.status = true;

    if (episode) {
      this.id = episode.id;
      this.title = episode.title;
      this.thumbnail = episode.thumbnail;
      this.price = episode.price;
      this.cuts = episode.cuts;
      this.publishedAt = new Date(episode.publishedAt).toISOString();
      this.status = episode.status;
    }
  }
}