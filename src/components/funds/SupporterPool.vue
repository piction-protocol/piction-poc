<template>
  <div>
    <h4>Supporter Pool
      <b-button v-if="!isCreated && isSupported" variant="primary" size="sm" @click="createSupporterPool">create
      </b-button>
      <b-button v-if="isCreated && isSupported" :disabled="distributableAmount == 0" variant="primary" size="sm"
                @click="distribution">{{distributableAmount}}PXL distribution
      </b-button>
    </h4>
    <b-table striped hover :items="computedDistributions" :small="true"></b-table>
  </div>
</template>

<script>
  import moment from 'moment';
  import {Datetime} from 'vue-datetime';
  import {record as _record} from './helper';
  import BigNumber from 'bignumber.js'

  export default {
    props: ['fund', 'fund_id'],
    computed: {
      computedDistributions() {
        let distributions = [];
        this.distributions.forEach(distribution => {
          let obj = {};
          obj.amount = `${(BigNumber(distribution.amount).div(Math.pow(10, 18)))} PXL`;
          obj.distributionTime = moment(Number(distribution.distributionTime)).format('YYYY-MM-DD HH:mm');
          if (distribution.distributedTime > 0) {
            obj.distributedTime = moment(Number(distribution.distributedTime)).format('YYYY-MM-DD HH:mm');
          } else {
            obj.distributedTime = null;
          }
          obj.state = this.getStateString(distribution.state);
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
        distributions: [],
        supporterPool: 0,
        supported: false,
        distributableAmount: 0
      }
    },
    methods: {
      createSupporterPool: async function () {
        try {
          await this.$contract.fund.createSupporterPool(this.fund.id);
        } catch (e) {
          alert(e)
        }
        this.$router.go(this.$router.path)
      },
      distribution: async function () {
        try {
          await this.$contract.supporterPool.distribution(this.fund.supporterPool);
        } catch (e) {
          alert(e)
        }
        this.$router.go(this.$router.path)
      },
      getStateString: function (state) {
        if (state == 0) {
          return 'PENDING';
        } else if (state == 1) {
          return 'PAID';
        } else if (state == 2) {
          return 'CANCEL_PAYMENT';
        } else {
          return null
        }
      }
    },
    async created() {
      if (Number(this.fund.supporterPool) > 0) {
        let distributions = await this.$contract.supporterPool.getDistributions(this.fund.supporterPool);
        this.distributions = await this.$utils.structArrayToJson(distributions, ['amount', 'distributionTime', 'distributedTime', 'state']);

        this.distributableAmount = new BigNumber(0)
        await this.distributions.forEach(distribution => {
          if (new Date().getTime() > distribution.distributionTime && this.getStateString(distribution.state) == 'PENDING') {
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
