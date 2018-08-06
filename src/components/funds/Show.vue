<template>
  <div>
    <h3>{{content ? content.title : ''}}</h3>
    <b-alert show>
      <div><b>Amount raised : {{fund.fundRise}} PXL</b></div>
      <div>{{fund.startTime}} ~ {{fund.endTime}}</div>
      <div>Number of distributions : {{fund.poolSize}}</div>
      <div>Distribution interval : {{fund.releaseInterval}} hour</div>
      <div>Reward distribution rate : {{fund.distributionRate}}%</div>
    </b-alert>

    <b-button v-if="supportable" variant="primary" @click="support">support</b-button>
    <b-button v-if="poolCreateable" variant="primary" @click="createSupporterPool">crate pool</b-button>
    <b-button v-if="!supportable && !poolCreateable" variant="primary" @click="distribution">release pool</b-button>
    <br>
    <br>
    <h4 v-if="supporters.length > 0">Supporters</h4>
    <b-table striped hover :items="supporters" :small="true"></b-table>

    <h4 v-if="pools.length > 0">Pool</h4>
    <b-table striped hover :items="pools" :small="true"></b-table>

  </div>
</template>

<script>
  import moment from 'moment';
  import {Datetime} from 'vue-datetime';
  import {record as _record} from './helper';

  export default {
    props: ['content_id', 'fund_id'],
    computed: {
      supportable() {
        return moment().isBetween(this.fund.startTime, this.fund.endTime);
      },
      poolCreateable() {
        return moment().isAfter(this.fund.endTime) && this.fund.sponsorshipPool == 0;
      }
    },
    data() {
      return {
        content: null,
        fund: _record(),
        supporters: [],
        pools: [],
        max: 100,
        value: 10
      }
    },
    methods: {
      support: async function () {
        await this.$contract.pxl.approveAndCall(this.fund_id, 10, '');
        this.$router.go(this.$router.path)
      },
      createSupporterPool: async function () {
        await this.$contract.fund.createSupporterPool(this.fund_id);
        this.$router.go(this.$router.path)
      },
      distribution: async function () {
        await this.$contract.supporterPool.distribution(this.fund.sponsorshipPool);
        this.$router.go(this.$router.path)
      },
    },
    async created() {
      this.$contract.pxl.getTokenTransferable().then(r => console.log(`token transferable : ${r}`))
      this.$contract.pxl.balanceOf(this.fund.sponsorshipPool).then(r => console.log(`fund pxl : ${r / Math.pow(10, 18)}`))
      this.$contract.pxl.balanceOf(this.$root.account).then(r => console.log(`writer pxl : ${r / Math.pow(10, 18)}`))

      this.$contract.pxl._contract.getPastEvents('Transfer', {
        filter: {},
        fromBlock: 0,
        toBlock: 'latest'
      }, function(error, events){ console.log(events); })
        .then(function(events){
          console.log(events) // same results as the optional callback above
        });

      await this.$contract.contentInterface.getRecord(this.content_id)
        .then(r => this.content = JSON.parse(r));
      let fund = await this.$contract.fund.getInfo(this.fund_id);
      this.fund.startTime = moment(Number(fund[0])).format('YYYY-MM-DD HH:mm')
      this.fund.endTime = moment(Number(fund[1])).format('YYYY-MM-DD HH:mm')
      this.fund.fundRise = Number(fund[2]) / Math.pow(10, 18);
      this.fund.poolSize = Number(fund[3]);
      this.fund.releaseInterval = Number(fund[4]) / (60 * 60 * 1000);
      this.fund.distributionRate = Number(fund[5]);
      this.fund.detail = fund[6];
      this.fund.sponsorshipPool = fund[7];

      if (this.fund.sponsorshipPool > 0) {
        let pools = await this.$contract.supporterPool.getDistributions(this.fund.sponsorshipPool);
        let arr = this.$utils.structArrayToJson(pools, ['amount', 'distributionTime', 'distributedTime', 'state']);
        arr.forEach(obj => {
          obj.amount = `${(obj.amount / Math.pow(10, 18))} PXL`;
          obj.distributionTime = moment(Number(obj.distributionTime)).format('YYYY-MM-DD HH:mm');
          if (obj.distributedTime > 0) {
            obj.distributedTime = moment(Number(obj.distributedTime)).format('YYYY-MM-DD HH:mm');
          } else {
            obj.distributedTime = null;
          }
          obj.state = obj.state;
        })
        this.pools = arr;
      }

      let supporters = await this.$contract.fund.getSupporters(this.fund_id);
      let arr = this.$utils.structArrayToJson(supporters, ['address', 'investment', 'withdraw', 'distributionRate']);
      arr.forEach(obj => {
        obj.investment = `${(obj.investment / Math.pow(10, 18))} PXL`;
        obj.withdraw = `${(obj.withdraw / Math.pow(10, 18))} PXL`;
        obj.distributionRate = `${obj.distributionRate * 100}%`;
      })
      this.supporters = arr;
    }
  }
</script>

<style scoped>
</style>
