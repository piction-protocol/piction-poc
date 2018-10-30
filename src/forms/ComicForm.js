export default class ComicForm {
  constructor(comic) {
    this.title;
    this.thumbnail = '';
    this.genres = '액션';
    this.synopsis;

    if (comic) {
      this.title = comic.title;
      this.thumbnail = comic.thumbnail;
      this.genres = comic.genres;
      this.synopsis = comic.synopsis;
    }
  }
}