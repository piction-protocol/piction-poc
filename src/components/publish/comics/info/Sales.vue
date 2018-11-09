<template>
  <div>
    <div class="font-size-20 font-weight-bold mt-5 mb-2">{{$t('매출정보')}}</div>
    <div class="d-flex mb-2">
      <div>
        <div>
          <span class="font-size-24 font-weight-bold">{{sales.totalPurchasedAmount}}</span>
          <span class="font-size-14 text-secondary">PXL</span>
        </div>
        <div class="font-size-14 text-secondary">{{$t('누적총매출')}}</div>
      </div>
      <div class="ml-5">
        <div>
          <span class="font-size-24 font-weight-bold">{{sales.totalPurchasedUserCount}}</span>
          <span class="font-size-14 text-secondary">{{$t('명')}}</span>
        </div>
        <div class="font-size-14 text-secondary">{{$t('구매한독자수')}}</div>
      </div>
    </div>
    <b-table striped hover
             show-empty
             :empty-text="$t('emptyList')"
             :fields="fields"
             :items="episodes"
             :small="true">
      <template slot="id" slot-scope="data">{{data.value + 1}}</template>
      <template slot="title" slot-scope="data">{{data.value}}</template>
      <template slot="purchasedAmount" slot-scope="data">{{data.value}} PXL</template>
    </b-table>
  </div>
</template>

<script>
  import Sales from '@models/Sales'
  import Web3Utils from '@utils/Web3Utils'

  export default {
    props: ['comic_id'],
    data() {
      return {
        sales: new Sales(),
        episodes: [],
        fields: [
          {key: 'id', label: '#'},
          {key: 'title', label: this.$t('에피소드제목')},
          {key: 'purchasedAmount', label: this.$t('매출')},
        ],
      }
    },
    methods: {},
    async created() {
      this.sales = await this.$contract.apiContents.getComicSales(this.comic_id);
      this.episodes = await this.$contract.apiContents.getMyEpisodes(this.comic_id);
      this.episodes = this.episodes.reverse()
    }
  }
</script>

<style scoped>
</style>