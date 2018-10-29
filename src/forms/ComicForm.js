export default class ComicForm {
  constructor(comic = {title:'', thumbnail:'', genres:'액션', synopsis:''}) {
    this.title = comic.title;
    this.thumbnail = comic.thumbnail;
    this.genres = comic.genres;
    this.synopsis = comic.synopsis;
  }

  setRecord(record) {

  }
}