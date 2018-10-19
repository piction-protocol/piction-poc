<template>
  <div>
    <div class="d-flex justify-content-between align-items-end">
      <div class="page-title">Comics</div>
      <b-form-select style="width: 150px;" :value="genre" @change="setGenre">
        <option :value="undefined">전체</option>
        <option v-for="genre in genres" :value="genre.value">{{genre.text}}</option>
      </b-form-select>
    </div>
    <br>
    <b-row>
      <b-col cols="12" sm="6" md="4" lg="3"
             v-for="comic in filteredComics"
             :key="comic.address">
        <Item :comic="comic"/>
      </b-col>
    </b-row>
  </div>
</template>

<script>
  import Item from './Item'
  import Comic from '@models/Comic'
  import Web3Utils from '@utils/Web3Utils'

  export default {
    components: {Item},
    props: ['genre'],
    computed: {
      filteredComics() {
        if (this.genre) {
          return this.comics.filter(comic => comic.genres == this.genre);
        } else {
          return this.comics;
        }
      }
    },
    data() {
      return {
        comics: [],
        genres: Comic.genres
      }
    },
    methods: {
      async setComics() {
        let comics = await this.$contract.apiContents.getComics(this.$contract.accountManager);
        this.comics = comics.reverse();
      },
      setEvents() {
        const event = this.$contract.contentsManager.getContract()
          .events.RegisterContents({fromBlock: 'latest'}, async (error, event) => {
            let values = Web3Utils.prettyJSON(event.returnValues);
            let comic = new Comic(values.contentsAddress, JSON.parse(values.record));
            comic.setWriter(values.writerAddress, values.writerName);
            this.comics.splice(0, 0, comic);
          });
        this.web3Events.push(event);
      },
      setGenre(value) {
        this.$router.push({query: {genre: value}})
      },
    },
    async created() {
      this.setEvents();
      this.setComics();
    }
  }
</script>

<style scoped>
</style>