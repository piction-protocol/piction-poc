<template>
  <div>
    <div class="font-size-20 font-weight-bold mb-2">{{$t('작품정보')}}</div>
    <div class="d-flex">
      <b-img fluid :src="comic.thumbnail" class="thumbnail"/>
      <div class="d-flex align-content-between flex-wrap p-3">
        <div class="title-text w-100">{{comic.title}}</div>
        <b-badge variant="secondary bg-dark">{{$t('genres.' + comic.genres)}}</b-badge>
        <b-button type="submit" size="sm" variant="outline-secondary" block
                  :to="{name:'publish-edit-comic', params:{comic_id: comic_id}}">{{$t('정보수정')}}
        </b-button>
      </div>
    </div>
    <Sales :comic_id="comic_id"/>
    <Deposit :comic_id="comic_id"/>
  </div>
</template>

<script>
  import Deposit from './Deposit.vue'
  import Sales from './Sales.vue'
  import Comic from '@models/Comic'
  import Web3Utils from '@utils/Web3Utils'

  export default {
    components: {Sales, Deposit},
    props: ['comic_id'],
    computed: {
      releaseDateText() {
        let time = Web3Utils.remainTimeToStr(this, this.releaseDate)
        return time ? time : {number: '0', text: this.$t('초')};
      }
    },
    data() {
      return {
        comic: new Comic(),
        deposit: 0,
        releaseDate: 0,
      }
    },
    methods: {},
    async created() {
      this.comic = await this.$contract.apiContents.getComic(this.comic_id);
      this.deposit = await this.$contract.depositPool.getDeposit(this.comic_id);
      this.releaseDate = await this.$contract.depositPool.getReleaseDate(this.comic_id);
    }
  }
</script>

<style scoped>
  .thumbnail {
    width: 128px;
    height: 128px;
    border: 1px solid #979797;
    background-position: center;
    background-size: cover;
    background-color: #e8e8e8;
  }
</style>
