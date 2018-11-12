<template>
  <div class="pt-5 pl-5 pr-5 pb-2">
    <b-row>
      <b-col class="text-center">
        <div class="value">{{fund.maxcap}} <span class="symbol">PXL</span></div>
        <div class="label">{{$t('목표모집금액')}}</div>
      </b-col>
      <b-col class="text-center">
        <div class="value">{{fund.softcap}} <span class="symbol">PXL</span></div>
        <div class="label">{{$t('최소모집금액')}}</div>
      </b-col>
      <b-col class="text-center">
        <div class="value">
          <animated-number
            class="pxl"
            :value="fund.rise"
            :formatValue="formatValue"
            :duration="1000"/>
          <span class="symbol">PXL</span></div>
        <div class="label">{{$t('현재모금액')}}</div>
      </b-col>
      <b-col class="text-center">
        <div class="value">{{fund.supporters.length}} <span class="symbol">{{$t('명')}}</span></div>
        <div class="label">{{$t('참여자수')}}</div>
      </b-col>
      <b-col class="text-center">
        <div class="value">{{time ? time.number : 0}} <span class="symbol">{{time ? time.text : $t('일')}}</span></div>
        <div class="label">{{$t('남은모집기간')}}</div>
      </b-col>
    </b-row>
    <br>
    <div class="position-relative" style="height: 12px">
      <b-progress :max="fund.maxcap" height="6px" variant="primary" class="position-relative">
        <b-progress-bar :value="fund.rise"></b-progress-bar>
      </b-progress>
      <div class="position-absolute"
           :style="`top:-2px; width: 10px; height: 10px; border-radius: 10px; background-color: #FF6E27; left: ${fund.getSoftcapPercent()}%`"></div>
    </div>
    <div class="d-flex justify-content-end">
      <div class="label">{{fund.getRisePercent()}}% {{$t('모금됨')}}</div>
    </div>
  </div>
</template>

<script>
  import AnimatedNumber from "animated-number-vue";
  import Web3Utils from '@utils/Web3Utils'

  export default {
    components: {
      AnimatedNumber
    },
    props: ['fund'],
    computed: {
      time() {
        return this.fund.rise != this.fund.maxcap ? Web3Utils.remainTimeToStr(this, this.fund.endTime) : null;
      }
    },
    methods: {
      formatValue(value) {
        return `${value.toFixed(0)}`;
      },
    },
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
