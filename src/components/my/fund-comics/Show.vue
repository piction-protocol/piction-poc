<template>
  <div>
    <div class="page-title">{{comic.title}}</div>
    <br>
    <Sales :comic_id="comic_id"/>
    <div class="font-size-20 font-weight-bold mt-5 mb-2">{{$t('myMenu.fund.fundInfo.title')}}</div>
    <b-col cols="12" sm="12" md="6" lg="6">
      <div class="d-flex justify-content-between mb-1">
        <div class="text-center pl-3">
          <div class="font-size-20">{{supporter.investment}} PXL</div>
          <div class="font-size-12">{{$t('myMenu.fund.fundInfo.fundraising')}}</div>
        </div>
        <div class="text-center pr-3">
          <div v-b-popover.hover="supporter.collection" class="font-size-20">
            <div v-if="supporter.collection / parseInt(supporter.collection) > 1">{{parseFloat(supporter.collection).toFixed(2)}} PXL</div>
            <div v-else>{{supporter.collection}} PXL</div>
          </div>
          <div class="font-size-12">{{$t('myMenu.fund.fundInfo.recovery')}}</div>
        </div>
      </div>
      <div class="position-relative" style="height: 12px">
        <b-progress :max="Number(supporter.investment)" height="6px" variant="primary">
          <b-progress-bar :value="Number(supporter.collection)"></b-progress-bar>
        </b-progress>
      </div>
      <div class="font-size-14" style="color: #9b9b9b">
        <div v-if="supporter.investment == supporter.collection">{{$t('myMenu.fund.fundInfo.completedMessage')}}</div>
        <div v-else>{{$t('myMenu.fund.fundInfo.inProgressMessage')}}</div>
      </div>
    </b-col>
    <div class="font-size-20 font-weight-bold mt-5 mb-2">{{$t('myMenu.fund.profits.title')}}</div>
    <b-col cols="12" sm="12" md="6" lg="6">
      <div class="d-flex justify-content-between mb-1">
        <div class="text-center pl-3">
          <div v-b-popover.hover="supporter.distributionRate" class="font-size-20">
            <div v-if="supporter.distributionRate / parseInt(supporter.distributionRate) > 1">{{parseFloat(supporter.distributionRate).toFixed(2)}} %</div>
            <div v-else>{{supporter.distributionRate}} %</div>
          </div>
          <div class="font-size-12">{{$t('수익분배율')}}</div>
        </div>
        <div class="text-center pr-3">
          <div v-b-popover.hover="supporter.reward" class="font-size-20">
            <div v-if="supporter.reward / parseInt(supporter.reward) > 1">{{parseFloat(supporter.reward).toFixed(2)}} %</div>
            <div v-else>{{supporter.reward}} %</div>
          </div>
          <div class="font-size-12">{{$t('myMenu.fund.profits.cumulativeProfits')}}</div>
        </div>
      </div>
      <div class="font-size-14" style="color: #9b9b9b">
        <div v-if="supporter.investment == supporter.collection">{{$t('myMenu.fund.profits.completedMessage')}}</div>
        <div v-else>{{$t('myMenu.fund.profits.inProgressMessage')}}</div>
      </div>
    </b-col>
    <div class="font-size-20 font-weight-bold mt-5 mb-2">{{$t('myMenu.fund.form.title')}}</div>
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
        fund_id: null,
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
      async endFund() {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiFund.endFund(this.fund_id);
        } catch (e) {
          alert(e);
        }
        loader.hide();
      },
    },
    async created() {
      this.comic = await this.$contract.apiContents.getComic(this.comic_id);
      this.fund_id = await this.$contract.apiFund.getFundAddress(this.comic_id);
      this.fund = await this.$contract.apiFund.getFund(this, this.fund_id);
      if(this.fund.needEndProcessing) {
        await this.endFund();
      }
      await this.setDistributions();
      this.supporter = await this.$contract.apiFund.getMySupporter(this, this.fund.address);
      this.fund.supporters = await this.$contract.apiFund.getSupporters(this, this.fund_id);
    }
  }
</script>

<style scoped>
</style>
