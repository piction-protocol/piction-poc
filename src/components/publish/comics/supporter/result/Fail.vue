<template>
  <div>
    <div class="font-size-20 mb-2 font-weight-bold">모집기간</div>
    <div class="font-size-18 mb-4">
      {{$utils.dateFmt(new Date(fund.startTime).getTime())}} ~ {{$utils.dateFmt(new Date(fund.endTime).getTime())}}
      <span class="ml-1">(모집종료)</span>
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
    <div class="font-size-24 text-center p-5">
      <div>서포터 모집 모금액을 달성하지 못했습니다.</div>
      <div>모금된 금액은 모두 환급되었습니다.</div>
    </div>
  </div>
</template>

<script>
  import Fund from '@models/Fund';

  export default {
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
    },
    async created() {
      await this.setFundState();
    }
  }
</script>

<style scoped>
</style>