<template>
  <div>
    <b-card :title="content.title"
            img-alt="Image"
            img-top
            tag="article"
            class="mb-2">
      <p class="card-text">
        <b-list-group>
          <b-list-group-item v-for="fund in funds" :key="fund.id">
            <b-alert show>{{fund.startTime}} ~ {{fund.endTime}}</b-alert>
            <b>Amount raised : {{fund.fundRise}} PXL</b>
            <div>Number of distributions : {{fund.poolSize}}</div>
            <div>Distribution interval : {{fund.releaseInterval}} hour</div>
            <div>Reward distribution rate : {{fund.distributionRate}}%</div>
            <hr>
            <div>{{fund.detail}}</div>
            <router-link :to="{ name: 'show-fund', params: { content_id: content.id, fund_id: fund.id }}"
                         class="font-italic float-right">more
            </router-link>
          </b-list-group-item>
        </b-list-group>
      </p>
      <div align="center">
        <b-button v-if="fundable" variant="primary" @click="addFund">Add Fund</b-button>
        <b-button variant="primary" @click="addEpisode">Add Episode</b-button>
        <b-button :disabled="releaseable" variant="primary" @click="release">Release</b-button>
      </div>
    </b-card>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';
  import moment from 'moment';
  import {Datetime} from 'vue-datetime';

  export default {
    props: ['content'],
    data() {
      return {
        funds: [],
        fundable: false,
        releaseable: true,
      }
    },
    methods: {
      addFund: function () {
        this.$router.push({name: 'new-fund', params: {content_id: this.content.id}})
      },
      addEpisode: function () {
        this.$router.push({name: 'new-episode', params: {content_id: this.content.id}})
      },
      release: async function () {
        this.$loading('loading...');
        try {
          await this.$contract.depositPool.release(this.content.id);
        } catch (e) {
          alert(e);
        }
        window.location.reload();
      }
    },
    async created() {
      let funds = await this.$contract.fundManager.getFunds(this.content.id);
      funds.forEach(async address => {
        let obj = await this.$contract.fund.getInfo(address);
        let fund = {};
        fund.id = address;
        fund.startTime = moment(Number(obj[0])).format('YYYY-MM-DD HH:mm')
        fund.endTime = moment(Number(obj[1])).format('YYYY-MM-DD HH:mm')
        fund.fundRise = this.$utils.toPXL(obj[2]);
        fund.poolSize = Number(obj[3]);
        fund.releaseInterval = Number(obj[4]) / (60 * 60 * 1000);
        fund.distributionRate = Number(obj[5]) / Math.pow(10, 18) * 100;
        fund.detail = obj[6];
        this.funds.push(fund);
        this.fundable = Number(obj[1]) < new Date().getTime();
      });
      if (funds.length == 0) {
        this.fundable = true;
      }
      let deposit = await this.$contract.depositPool.getDeposit(this.content.id)
      if (BigNumber(deposit).gt(0)) {
        this.releaseable = false;
      }
    }
  }
</script>

<style scoped>
</style>
