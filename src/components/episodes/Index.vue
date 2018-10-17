<template>
  <div>
    <Report v-if="!my" :content_id="content_id" class="float-right"/>
    <div class="clearfix"/>
    <div class="pt-4" align="center">
      <img :src="content.thumbnail" class="thumbnail mb-4"/>
      <h2 class="font-weight-bold mb-2">{{content.title}}
        <i v-if="my" class="ml-2 fas fa-edit"
           @click="updateContent"
           v-b-tooltip.hover :title="`작품수정`"></i>
      </h2>
      <div class="text-secondary font-italic mb-2">{{writerName}}</div>
      <b-badge variant="secondary bg-dark mb-2">{{content.genres}}</b-badge>
      <div class="synopsis-text">{{content.synopsis}}</div>
    </div>
    <i v-if="my"
       class="ml-2 fas fa-plus-square fa-lg"
       v-b-tooltip.hover :title="`회차등록`"
       @click="addEpisode"></i>
    <div class="sort-text mb-2 float-right pr-3" @click="sort">
      <i :class="orderBy == 'desc' ? 'ml-2 fas fa-arrow-down' : 'ml-2 fas fa-arrow-up'"></i> 에피소드 정렬
    </div>
    <div class="clearfix"/>
    <b-row class="pl-3 pr-3">
      <b-col cols="12" sm="12" md="6" lg="6" style="padding: 2px;"
             v-for="episode in episodes"
             :key="content.id">
        <Item :content="content"
              :episode="episode"
              :content_id="content_id"
              :my="my"
              :key="episode.number"/>
      </b-col>
    </b-row>
  </div>
</template>

<script>
  import Item from './Item'
  import Report from './Report'

  export default {
    props: ['content_id'],
    components: {Item, Report},
    data() {
      return {
        content: {},
        writer: '',
        writerName: '',
        episodes: [],
        orderBy: 'desc'
      }
    },
    computed: {
      my: function () {
        return this.writer.toLocaleLowerCase() == this.pictionConfig.account;
      }
    },
    methods: {
      updateContent() {
        this.$router.push({name: 'edit-content', params: {'content_id': this.content_id}});
      },
      setEvent() {
        this.$contract.apiContents.setEpisodeCreation((error, event) => {
          if (this.content_id.toLocaleLowerCase() != event.returnValues._contentAddress.toLocaleLowerCase()) return;
          var record = JSON.parse(event.returnValues._record);
          record.number = event.returnValues._episodeIndexId;
          record.buyCount = 0;
          record.purchased = false;
          record.price = event.returnValues._price;
          this.episodes.sort((a, b) => b.number - a.number);
          this.episodes.splice(0, 0, record);
        });
      },
      sort(evt) {
        evt.preventDefault();
        this.orderBy = this.orderBy == 'desc' ? 'asc' : 'desc';
        this.episodes = this.episodes.reverse();
      },
      addEpisode() {
        this.$router.push({name: 'new-episode', params: {content_id: this.content_id}})
      },
      async setContentDetail() {
        const contentDetail = await this.$contract.apiContents.getContentsDetail(this.content_id);
        this.content = contentDetail.record;
        this.writer = contentDetail.writer;
        this.writerName = contentDetail.writerName;
      },
      async loadList() {
        const result = await this.$contract.apiContents.getEpisodeFullList(this.content_id);
        if (!result.episodeRecords_) return;
        let records = JSON.parse(web3.utils.hexToUtf8(result.episodeRecords_));
        records.forEach((record, i) => {
          record.number = i;
          record.buyCount = result.buyCount_[i];
          record.purchased = result.isPurchased_[i];
          record.price = result.price_[i];
        });
        this.episodes = records.reverse();
      }
    },
    async created() {
      this.setEvent();
      this.setContentDetail();
      this.loadList();
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
