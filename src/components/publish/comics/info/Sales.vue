<template>
  <div>
    <div class="font-size-20 font-weight-bold mt-5 mb-2">매출 정보</div>
    <div class="d-flex mb-2">
      <div>
        <div>
          <span class="font-size-24 font-weight-bold">{{sales.totalPurchasedAmount}}</span>
          <span class="font-size-14 text-secondary">PXL</span>
        </div>
        <div class="font-size-14 text-secondary">누적 총 매출</div>
      </div>
      <div class="ml-5">
        <div>
          <span class="font-size-24 font-weight-bold">{{sales.totalPurchasedUserCount}}</span>
          <span class="font-size-14 text-secondary">명</span>
        </div>
        <div class="font-size-14 text-secondary">구매한 독자 수</div>
      </div>
    </div>
    <b-table striped hover
             show-empty
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
             :items="episodes"
             :small="true">
      <template slot="key" slot-scope="data">{{data.value}}</template>
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
          {key: 'key', label: '#'},
          {key: 'title', label: '에피소드 제목'},
          {key: 'purchasedAmount', label: '매출'},
        ],
      }
    },
    methods: {},
    async created() {
      this.sales = await this.$contract.apiContents.getMyComicSales(this.comic_id);
      this.episodes = await this.$contract.apiContents.getMyEpisodes(this.comic_id);
      this.episodes = this.episodes.reverse()
    }
  }
</script>

<style scoped>
</style>