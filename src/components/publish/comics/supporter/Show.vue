<template>
  <div>
    <div class="font-size-20 mb-2 font-weight-bold">{{$t('모집기간')}}</div>
    <div class="font-size-18 mb-4">
      {{$utils.dateFmt(fund.startTime)}} ~ {{$utils.dateFmt(fund.endTime)}}
      <span class="ml-1">({{statusText}})</span>
    </div>
    <div class="font-size-20 mb-2 font-weight-bold">{{$t('모집현황')}}</div>
    <div class="d-flex justify-content-between mb-1">
      <div class="text-center pl-3">
        <div class="font-size-20">{{fund.softcap}} PXL</div>
        <div class="font-size-12">{{$t('최소모집금액')}}</div>
      </div>
      <div class="text-center pr-3">
        <div class="font-size-20">{{fund.maxcap}} PXL</div>
        <div class="font-size-12">{{$t('목표모집금액')}}</div>
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
        <div class="font-size-12">{{$t('현재모금액')}}</div>
      </div>
    </div>
    <div v-if="success != false">
      <div class="font-size-20 mb-2 font-weight-bold">{{$t('모집정보')}}</div>
      <b-row>
        <b-col cols="2">{{$t('1인당모금가능액')}}</b-col>
        <b-col cols="2">{{fund.min}}PXL ~ {{fund.max}}PXL</b-col>
      </b-row>
      <b-row>
        <b-col cols="2">{{$t('모금액수령방법')}}</b-col>
        <b-col cols="2">{{fund.poolSize}}{{$t('회분할')}} / {{fund.interval / (1000 * 60 * 60)}}{{$t('시간간격')}}</b-col>
      </b-row>
      <b-row class="mb-4">
        <b-col cols="2">{{$t('최초모금액수령일')}}</b-col>
        <b-col cols="2">{{$utils.dateFmt(new Date(fund.firstDistributionTime).getTime())}}</b-col>
      </b-row>
      <div v-if="fund.distributions.length > 0">
        <div class="font-size-20 font-weight-bold mt-5 mb-2">{{$t('모금액작가수령일정')}}</div>
        <SupporterPool :fund="fund"/>
        <div class="text-center">
          <b-button type="submit" size="sm"
                    @click="releaseDistribution"
                    :disabled="distributionsTotalAmount == 0"
                    variant="outline-secondary">{{distributionsTotalAmount.toString()}} {{$t('PXL수령받기')}}
          </b-button>
        </div>
      </div>
      <div class="font-size-20 font-weight-bold mt-5 mb-2 ">{{$t('서포터')}} ({{$t('fundSupportersLength', {length: fund.supporters.length})}})</div>
      <Supporters :supporters="fund.supporters"/>
    </div>
    <div v-if="success == false" class="font-size-24 text-center p-5">
      <div>서포터 모집 모금액을 달성하지 못했습니다.</div>
      <div>모금된 금액은 모두 환급되었습니다.</div>
    </div>
  </div>
</template>

<script>
  import Fund from '@models/Fund';
  import SupporterPool from './SupporterPool'
  import Supporters from '@/components/funds/Supporters'
  import BigNumber from 'bignumber.js'

  export default {
    components: {SupporterPool, Supporters},
    props: ['comic_id', 'fund_id'],
    computed: {
      statusText() {
        if (new Date(this.fund.startTime).getTime() > this.$root.now) {
          return this.$t('모집예정');
        } else if (new Date(this.fund.endTime).getTime() < this.$root.now || this.fund.rise == this.fund.maxcap) {
          return this.$t('모집종료');
        } else {
          return this.$t('현재모집중');
        }
      }
    },
    data() {
      return {
        fund: new Fund(),
        success: null,
        distributionsTotalAmount: 0
      }
    },
    methods: {
      async setFundState() {
        this.fund = await this.$contract.apiFund.getFund(this, this.fund_id);
        if(this.fund.needEndProcessing) {
          await this.endFund();
        }
      },
      async setSupporters() {
        this.fund.supporters = await this.$contract.apiFund.getSupporters(this, this.fund_id);
      },
      async setDistributions() {
        this.fund.distributions = await this.$contract.apiFund.getDistributions(this.fund);
        this.distributionsTotalAmount = this.fund.distributions
          .filter(d => d.distributableTime < this.$root.now && d.state == 0)
          .map(d => d.amount)
          .reduce((a, b) => BigNumber(a).plus(BigNumber(b)), 0);
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
      async releaseDistribution() {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiFund.releaseDistribution(this.fund_id);
          await this.setDistributions();
        } catch (e) {
          alert(e);
        }
        loader.hide();
      },
    },
    async created() {
      await this.setFundState();
      await this.setSupporters();
      await this.setDistributions();
    }
  }
</script>

<style scoped>
</style>
