<template>
  <div>
    <h5>모집금액 회수 현황
      <b-button v-if="!isCreated && isSupported" variant="primary" size="sm" @click="createSupporterPool">create
      </b-button>
      <b-button v-if="isCreated && isSupported" :disabled="distributableAmount == 0" variant="primary" size="sm"
                @click="distribution">{{distributableAmount}}PXL 회수
      </b-button>
    </h5>
    <b-table striped hover
             :fields="fields"
             :items="computedDistributions"
             :small="true">
      <template slot="amount" slot-scope="row">{{row.value}}</template>
      <template slot="distributionTime" slot-scope="row">{{row.value}}</template>
      <template slot="distributedTime" slot-scope="row">{{row.value}}</template>
      <template slot="state" slot-scope="row">{{row.value}}</template>
      <template slot="vote" slot-scope="row">
        <b-button :disabled="row.item.disable" variant="primary" size="sm" @click.stop="vote(row.index)">
          {{row.item.votingCount}} vote
        </b-button>
      </template>
    </b-table>
  </div>
</template>

<script>
  import moment from 'moment';
  import {Datetime} from 'vue-datetime';
  import {record as _record} from './helper';
  import BigNumber from 'bignumber.js'

  export default {
    props: ['fund'],
    computed: {
      computedDistributions() {
        let distributions = [];
        this.distributions.forEach((distribution) => {
          let obj = {};
          obj.amount = `${this.$utils.toPXL(distribution.amount)} PXL`;
          obj.distributionTime = this.$utils.dateFmt(Number(distribution.distributionTime));
          obj.distributedTime = this.$utils.dateFmt(Number(distribution.distributedTime));
          obj.state = this.getStateString(distribution.state);
          obj.votingCount = distribution.votingCount;
          if (!moment().isBetween(Number(distribution.distributionTime - this.fund.releaseInterval), Number(distribution.distributionTime)) ||
            distribution.state != 0 || distribution.isVoting) {
            obj.disable = true;
          }
          distributions.push(obj)
        })
        return distributions;
      },
      isCreated() {
        return Number(this.fund.supporterPool) > 0;
      },
      isSupported() {
        return moment().isAfter(this.fund.endTime);
      },
    },
    data() {
      return {
        fields: [
          {key: 'amount', label: '회수금액'},
          {key: 'distributionTime', label: '회수가능일시'},
          {key: 'distributedTime', label: '회수일시'},
          {key: 'state', label: '회수상태'},
          {key: 'vote', label: 'Vote'},
        ],
        distributions: [],
        supporterPool: 0,
        supported: false,
        distributableAmount: 0
      }
    },
    methods: {
      createSupporterPool: async function () {
        this.$loading('loading...');
        try {
          await this.$contract.fund.createSupporterPool(this.fund.id);
        } catch (e) {
          alert(e)
        }
        this.$router.go(this.$router.path)
      },
      distribution: async function () {
        this.$loading('loading...');
        try {
          await this.$contract.supporterPool.distribution(this.fund.supporterPool);
        } catch (e) {
          alert(e)
        }
        this.$router.go(this.$router.path)
      },
      vote: async function (index) {
        this.$loading('loading...');
        try {
          await this.$contract.supporterPool.vote(this.fund.supporterPool, index);
        } catch (e) {
          alert(e)
        }
        this.$router.go(this.$router.path)
      },
      getStateString: function (state) {
        if (state == 0) {
          return '지급대기';
        } else if (state == 1) {
          return '지급완료';
        } else if (state == 2) {
          return '지급연기';
        } else {
          return null
        }
      }
    },
    async created() {
      if (Number(this.fund.supporterPool) > 0) {
        let distributions = await this.$contract.supporterPool.getDistributions(this.fund.supporterPool);
        distributions = await this.$utils.structArrayToJson(distributions,
          ['amount', 'distributionTime', 'distributedTime', 'state', 'votingCount', 'isVoting']);
        this.distributions = distributions;

        this.distributableAmount = new BigNumber(0)
        await this.distributions.forEach(distribution => {
          if (new Date().getTime() > distribution.distributionTime && distribution.state == 0) {
            this.distributableAmount = this.distributableAmount.plus(distribution.amount);
          }
        });
        this.distributableAmount = this.distributableAmount.div(Math.pow(10, 18)).toString();
      }
    },
  }
</script>

<style scoped>
</style>
