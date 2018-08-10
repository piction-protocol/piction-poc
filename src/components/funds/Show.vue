<template>
  <div>
    <h3>{{content ? content.title : ''}}</h3>
    <b-alert show>
      <div>{{fund.detail}}</div>
      <hr>
      <div><b>Amount raised : {{$utils.toPXL(fund.fundRise)}} PXL</b></div>
      <div>{{$utils.dateFmt(fund.startTime)}} ~ {{$utils.dateFmt(fund.endTime)}}</div>
      <div>Number of distributions : {{fund.poolSize}}</div>
      <div>Distribution interval : {{fund.releaseInterval / (60 * 60 * 1000)}} hour</div>
      <div>Reward distribution rate : {{fund.distributionRate / Math.pow(10, 18) * 100}}%</div>
    </b-alert>
    <Supporters :fund_id="fund_id" :supportable="supportable"/>
    <SupporterPool v-if="fund.id" :fund="fund"/>
  </div>
</template>

<script>
  import moment from 'moment';
  import {record as _record} from './helper';
  import SupporterPool from './SupporterPool';
  import Supporters from './Supporters';
  import BigNumber from 'bignumber.js'

  export default {
    components: {SupporterPool, Supporters},
    props: ['content_id', 'fund_id'],
    computed: {
      supportable() {
        return moment().isBetween(this.fund.startTime, this.fund.endTime);
      },
    },
    data() {
      return {
        content: null,
        fund: _record(),
      }
    },
    methods: {},
    async created() {
      let content = await this.$contract.contentInterface.getRecord(this.content_id);
      this.content = JSON.parse(content);

      let fund = await this.$contract.fund.getInfo(this.fund_id);
      this.fund.startTime = Number(fund[0]);
      this.fund.endTime = Number(fund[1]);
      this.fund.fundRise = Number(fund[2]);
      this.fund.poolSize = fund[3];
      this.fund.releaseInterval = fund[4];
      this.fund.distributionRate = fund[5];
      this.fund.detail = fund[6];
      this.fund.supporterPool = fund[7];
      this.fund.id = this.fund_id
    }
  }
</script>

<style scoped>
</style>
