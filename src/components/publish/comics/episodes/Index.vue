<template>
  <div>
    <div class="text-center mb-5">
      <b-button variant="outline-secondary" :to="{name: 'publish-new-episode', params:{comic_id:comic_id}}">{{$t('새에피소드등록')}}</b-button>
      <b-button variant="outline-secondary" :to="{name: 'episodes', params:{comic_id:comic_id}}" class="ml-2">{{$t('작품보기')}}
      </b-button>
    </div>
    <div class="sort-text mb-2 float-right pr-3" @click="sort">
      <i :class="orderBy == 'desc' ? 'ml-2 fas fa-arrow-down' : 'ml-2 fas fa-arrow-up'"></i> {{$t('에피소드정렬')}}
    </div>
    <div class="clearfix"/>
    <b-row class="pl-3 pr-3">
      <b-col cols="12" sm="12" md="6" lg="6" style="padding: 2px;"
             v-for="(episode, index) in episodes"
             :key="episode.id">
        <Item :episode="episode"
              :comic_id="comic_id"/>
      </b-col>
    </b-row>
  </div>
</template>

<script>
  import Item from './Item'
  import Comic from '@models/Comic'

  export default {
    props: ['comic_id'],
    components: {Item},
    data() {
      return {
        comic: new Comic(),
        episodes: [],
        orderBy: 'desc'
      }
    },
    methods: {
      async setEpisodes() {
        const result = await this.$contract.apiContents.getMyEpisodes(this.comic_id);
        this.episodes = result.reverse();
      },
      sort(evt) {
        evt.preventDefault();
        this.orderBy = this.orderBy == 'desc' ? 'asc' : 'desc';
        this.episodes = this.episodes.reverse();
      },
      addEpisode() {
        this.$router.push({name: 'new-episode', params: {comic_id: this.comic_id}})
      },
    },
    async created() {
      await this.setEpisodes();
    }
  }
</script>

<style scoped>

</style>
