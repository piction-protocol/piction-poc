<template>
  <div class="pt-5 pl-5 pr-5 pb-2">
    <b-row>
      <b-col class="text-center">
        <div class="value">{{$utils.toPXL(fund.maxcap).toFixed(0)}} <span class="symbol">PXL</span></div>
        <div class="label">목표 모집 금액</div>
      </b-col>
      <b-col class="text-center">
        <div class="value">{{$utils.toPXL(fund.softcap).toFixed(0)}} <span class="symbol">PXL</span></div>
        <div class="label">최소 모집 금액</div>
      </b-col>
      <b-col class="text-center">
        <div class="value">{{$utils.toPXL(fund.rise).toFixed(0)}} <span class="symbol">PXL</span></div>
        <div class="label">현재 모금액</div>
      </b-col>
      <b-col class="text-center">
        <div class="value">{{fund.supporters.length}} <span class="symbol">명</span></div>
        <div class="label">참여자 수</div>
      </b-col>
      <b-col class="text-center">
        <div class="value">7 <span class="symbol">일</span></div>
        <div class="label">남은 모집 기간</div>
      </b-col>
    </b-row>
    <div class="mt-3 position-relative">
      <b-progress :max="$utils.toPXL(fund.maxcap)" height="5px" variant="dark">
        <b-progress-bar :value="$utils.toPXL(fund.rise)"></b-progress-bar>
      </b-progress>
      <b-progress v-if="fund.rise < fund.softcap"
                  :value="$utils.toPXL(fund.rise)"
                  :max="$utils.toPXL(fund.maxcap)" height="5px" variant="dark"
                  class="position-absolute w-100"
                  style="top:0; opacity: 0.15">
        <b-progress-bar variant="danger" :value="$utils.toPXL(fund.softcap)"></b-progress-bar>
      </b-progress>
    </div>
    <div class="d-flex justify-content-end">
      <div class="label">{{fund.getRisePercent()}}% 모금됨</div>
    </div>
  </div>
</template>

<script>
  export default {
    props: ['fund'],
  }
</script>

<style scoped>
  .value {
    font-size: 22px;
    font-weight: bold;
  }

  .symbol {
    font-size: 14px;
    color: #c1c1c1;
  }

  .label {
    font-size: 12px;
    color: #4a4a4a;
  }
</style>
