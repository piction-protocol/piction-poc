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
            <router-link :to="{ name: 'episodes', params: { content_id: content.id }}" class="font-italic float-right">more
            </router-link>
          </b-list-group-item>
        </b-list-group>
      </p>
      <b-button v-if="fundable" variant="primary" @click="addFund">Add fund</b-button>
    </b-card>
  </div>
</template>

<script>
  import moment from 'moment';
  import {Datetime} from 'vue-datetime';

  export default {
    props: ['content'],
    data() {
      return {
        funds: [],
        fundable: false
      }
    },
    methods: {
      addFund: async function (evt) {
        this.$router.push({name: 'new-fund', params: {content_id: this.content.id}})
      }
    },
    async created() {
      let funds = await this.$contract.fundManager.getFunds(this.content.id);
      funds.forEach(async address => {
        await this.$contract.fund.getInfo(address).then(r => {
          let fund = {};
          fund.id = address;
          fund.startTime = moment(Number(r[0])).format('YYYY-MM-DD HH:mm')
          fund.endTime = moment(Number(r[1])).format('YYYY-MM-DD HH:mm')
          fund.fundRise = Number(r[2]);
          fund.poolSize = Number(r[3]);
          fund.releaseInterval = Number(r[4]) / (60 * 60 * 1000);
          fund.distributionRate = Number(r[5]);
          fund.detail = r[6];
          this.funds.push(fund);
        });
      });
      if (funds.length == 0 || funds[funds.length - 1].endTime < new Date().getTime()) {
        this.fundable = true;
      }
    }
  }
</script>

<style scoped>
</style>
