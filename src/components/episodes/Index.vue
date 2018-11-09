<template>
  <div>
    <div v-if="my">
      <b-button variant="outline-secondary"
                :to="{name:'publish-episodes', params:{comic_id:comic_id}}"
                size="sm" class="float-right">{{$t('관리')}}
      </b-button>
    </div>
    <div v-else>
      <Report :comic_id="comic_id" class="float-right"/>
    </div>
    <div class="clearfix"/>
    <div class="pt-4" align="center">
      <img :src="comic.thumbnail" class="thumbnail mb-4"/>
      <h2 class="font-weight-bold mb-2">{{comic.title}}</h2>
      <div class="text-secondary font-italic mb-2">{{comic.writer.name}}</div>
      <b-badge variant="secondary bg-dark mb-2">{{comic.genres}}</b-badge>
      <div class="synopsis-text">{{comic.synopsis}}</div>
    </div>
    <div class="sort-text mb-2 float-right pr-3" @click="sort">
      <i :class="orderBy == 'desc' ? 'ml-2 fas fa-arrow-down' : 'ml-2 fas fa-arrow-up'"></i> {{$t('에피소드정렬')}}
    </div>
    <div class="clearfix"/>
    <b-row class="pl-3 pr-3">
      <b-col cols="12" sm="12" md="6" lg="6" style="padding: 2px;"
             v-for="(episode, index) in episodes"
             :key="episode.id">
        <Item :comic="comic"
              :episode="episode"
              :comic_id="comic_id"/>
      </b-col>
    </b-row>
  </div>
</template>

<script>
  import Item from './Item'
  import Report from './Report'
  import Comic from '@models/Comic'

  export default {
    props: ['comic_id'],
    components: {Item, Report},
    data() {
      return {
        comic: new Comic(),
        episodes: [],
        orderBy: 'desc'
      }
    },
    computed: {
      my() {
        return this.comic.writer.address == this.pictionConfig.account;
      }
    },
    methods: {
      async setComic() {
        this.comic = await this.$contract.apiContents.getComic(this.comic_id);
      },
      async setEpisodes() {
        const result = await this.$contract.apiContents.getEpisodes(this.comic_id);
        this.episodes = result.reverse();
      },
      updateContent() {
        this.$router.push({name: 'edit-comic', params: {'comic_id': this.comic_id}});
      },
      setEvents() {
        // TODO: 에피소드 등록 이벤트 처리
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
      this.setEvents();
      this.setComic();
      this.setEpisodes();
    }
  }
</script>

<style scoped>
  .thumbnail {
    width: 200px;
    height: 200px;
    background-position: center;
    background-size: cover;
    border: 1px solid #979797;
  }

  .synopsis-text {
    font-size: 14px;
    color: #6c757d;
    white-space: pre-line;
  }

  .sort-text {
    font-size: 12px;
  }
</style>
