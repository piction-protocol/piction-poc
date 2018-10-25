<template>
  <div>
    <div class="font-size-20 mb-2 font-weight-bold">모집기간</div>
    <div class="font-size-18 mb-4">
      {{$utils.dateFmt(new Date(fund.startTime).getTime())}} ~ {{$utils.dateFmt(new Date(fund.endTime).getTime())}}
      <span class="ml-1">(현재 모집 중)</span>
    </div>
    <div class="font-size-20 mb-2 font-weight-bold">모집 현황</div>
    <div class="d-flex justify-content-between mb-1">
      <div class="text-center pl-3">
        <div class="font-size-20">{{fund.softcap}} PXL</div>
        <div class="font-size-12">최소 모집 금액</div>
      </div>
      <div class="text-center pr-3">
        <div class="font-size-20">{{fund.maxcap}} PXL</div>
        <div class="font-size-12">목표 모집 금액</div>
      </div>
    </div>
    <div class="position-relative" style="height: 12px">
      <b-progress :max="fund.maxcap" height="6px" variant="primary" class="position-relative">
        <b-progress-bar :value="fund.rise"></b-progress-bar>
      </b-progress>
      <div class="position-absolute"
           :style="`top:-2px; width: 10px; height: 10px; border-radius: 10px; background-color: #FF6E27; left: ${fund.getSoftcapPercent()}%`"></div>
    </div>
    <div class="d-flex justify-content-center mb-4">
      <div class="text-center">
        <div class="font-size-20">{{fund.rise}} PXL</div>
        <div class="font-size-12">현재까지 모금액</div>
      </div>
    </div>
    <div class="font-size-20 mb-2 font-weight-bold">모집 정보</div>
    <b-row>
      <b-col cols="2">1인당 모금 가능액</b-col>
      <b-col cols="2">{{fund.min}}PXL ~ {{fund.max}}PXL</b-col>
    </b-row>
    <b-row>
      <b-col cols="2">모금액 수령 방법</b-col>
      <b-col cols="2">{{fund.poolSize}}회 분할 / {{fund.interval / (1000 * 60 * 60)}}시간 간격</b-col>
    </b-row>
    <b-row class="mb-4">
      <b-col cols="2">최초 모금액 수령일</b-col>
      <b-col cols="2">{{$utils.dateFmt(new Date(fund.firstDistributionTime).getTime())}}</b-col>
    </b-row>
    <div class="font-size-20 mb-2 font-weight-bold">서포터 (총 {{fund.supporters.length}}명)</div>
    <Supporters :supporters="fund.supporters"/>
  </div>
</template>

<script>
  import Fund from '@models/Fund';
  import Supporters from '@/components/funds/Supporters'

  export default {
    components: {Supporters},
    props: ['comic_id', 'fund_id'],
    data() {
      return {
        fund: new Fund(),
      }
    },
    methods: {
      async setFundState() {
        this.fund = await this.$contract.apiFund.getFund(this, this.fund_id);
      },
      async setSupporters() {
        this.fund.supporters = await this.$contract.apiFund.getSupporters(this, this.fund_id);
      },
    },
    async created() {
      await this.setFundState();
      await this.setSupporters();
    }
  }
</script>

<style scoped>
</style>
