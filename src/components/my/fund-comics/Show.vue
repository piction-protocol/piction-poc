<template>
  <div>
    <div class="page-title">{{comic.title}}</div>
    <br>
    <Sales :comic_id="comic_id"/>
    <div class="font-size-20 font-weight-bold mt-5 mb-2">투자 정보</div>
    <b-col cols="12" sm="12" md="6" lg="6">
      <div class="d-flex justify-content-between mb-1">
        <div class="text-center pl-3">
          <div class="font-size-20">{{supporter.investment}} PXL</div>
          <div class="font-size-12">투자금</div>
        </div>
        <div class="text-center pr-3">
          <div class="font-size-20">{{supporter.collection}} PXL</div>
          <div class="font-size-12">회수금</div>
        </div>
      </div>
      <div class="position-relative" style="height: 12px">
        <b-progress :max="Number(supporter.investment)" height="6px" variant="primary">
          <b-progress-bar :value="Number(supporter.collection)"></b-progress-bar>
        </b-progress>
      </div>
      <div class="font-size-14" style="color: #9b9b9b">
        <div v-if="supporter.investment == supporter.collection">서포터 투자금이 모두 회수되었습니다.</div>
        <div v-else>현재 매출의 100%가 서포터 투자 회수금으로 분배되고 있습니다.</div>
      </div>
    </b-col>
    <div class="font-size-20 font-weight-bold mt-5 mb-2">수익 분배 정보</div>
    <b-col cols="12" sm="12" md="6" lg="6">
      <div class="d-flex justify-content-between mb-1">
        <div class="text-center pl-3">
          <div class="font-size-20">{{supporter.distributionRate}} %</div>
          <div class="font-size-12">수익 분배율</div>
        </div>
        <div class="text-center pr-3">
          <div class="font-size-20">{{supporter.reward}} PXL</div>
          <div class="font-size-12">누적 수익 분배 금액</div>
        </div>
      </div>
      <div class="font-size-14" style="color: #9b9b9b">
        <div v-if="supporter.investment == supporter.collection">작품 판매 시 실시간으로 수익이 분배되고 있습니다.</div>
        <div v-else>서포터 투자 회수금이 분배된 후 정해진 요율로 수익이 분배됩니다.</div>
      </div>
    </b-col>
    <div class="font-size-20 font-weight-bold mt-5 mb-2">모금액 작가 수령 관리</div>
    <SupporterPool :fund="fund"/>
  </div>
</template>

<script>
  import Sales from './Sales.vue'
  import SupporterPool from './SupporterPool.vue'
  import Comic from '@models/Comic'
  import Fund from '@models/Fund'
  import Supporter from '@models/Supporter'
  import Web3Utils from '@utils/Web3Utils'

  export default {
    components: {Sales, SupporterPool},
    props: ['comic_id'],
    data() {
      return {
        comic: new Comic(),
        fund: new Fund(),
        supporter: new Supporter()
      }
    },
    methods: {
      async setDistributions() {
        this.fund.distributions = await this.$contract.apiFund.getDistributions(this.fund);
        this.fund.distributions.forEach(o => o._showDetails = o.isCurrentPool());
      },
    },
    async created() {
      this.comic = await this.$contract.apiContents.getComic(this.comic_id);
      const address = await this.$contract.apiFund.getFundAddress(this.comic_id);
      this.fund = await this.$contract.apiFund.getFund(this, address);
      await this.setDistributions();
      this.supporter = await this.$contract.apiFund.getMySupporter(this, this.fund.address);
    }
  }
</script>

<style scoped>
</style>
