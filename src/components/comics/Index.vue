<template>
  <div>
    <div class="page-title">{{$t('comics')}}</div>
    <br>
    <b-tabs>
      <template slot="tabs">
        <b-nav-item slot="tabs" @click="setTab('popular')" :active="!$route.hash || $route.hash == '#popular'">Popular
        </b-nav-item>
      </template>
      <template slot="tabs">
        <b-nav-item slot="tabs" @click="setTab('updated')" :active="$route.hash == '#updated'">Updated</b-nav-item>
      </template>
      <template slot="tabs">
        <b-nav-item slot="tabs" @click="setTab('new')" :active="$route.hash == '#new'">New</b-nav-item>
      </template>
    </b-tabs>
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
        if (!this.$route.hash || this.$route.hash == '#popular') {
          return this.comics.sort((a, b) => b.purchasedCount - a.purchasedCount);
        } else if (this.$route.hash == '#updated') {
          return this.comics.sort((a, b) => b.lastUploadedAt - a.lastUploadedAt);
        } else {
          return this.comics.sort((a, b) => b.createdAt - a.createdAt);
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
        let comics = await this.$contract.apiContents.getComics(this);
        this.comics = comics.reverse();
      },
      setEvents() {
        const event = this.$contract.contentsManager.getContract()
          .events.RegisterContents({fromBlock: 'latest'}, async (error, event) => {
            let values = Web3Utils.prettyJSON(event.returnValues);
            let comic = new Comic(JSON.parse(values.record));
            comic.address = values.contentsAddress;
            comic.writer = new Writer(values.writerAddress, values.writerName);
            this.comics.splice(0, 0, comic);
          });
        this.web3Events.push(event);
      },
      async setTab(tab) {
        this.$router.replace({hash: `#${tab}`});
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