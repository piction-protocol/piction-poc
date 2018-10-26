<template>
  <div>
    <b-table striped hover
             show-empty
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
             :items="fund.distributions"
             :small="true">
      <template slot="index" slot-scope="row">{{row.index + 1}}회차</template>
      <template slot="amount" slot-scope="row">{{Number(row.value) / Math.pow(10, 18)}} PXL</template>
      <template slot="distributableTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="distributedTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="state" slot-scope="row">{{getStateString(row)}}</template>
      <template slot="vote" slot-scope="row">
        <div v-if="completed(row) || progress(row)">
          {{row.item.votingCount}} / {{fund.supporters.length}}
        </div>
      </template>
    </b-table>
  </div>
</template>

<script>
  import moment from 'moment';
  import {Datetime} from 'vue-datetime';
  import BigNumber from 'bignumber.js'

  export default {
    props: ['fund'],
    data() {
      return {
        fields: [
          {key: 'index', label: '회차'},
          {key: 'amount', label: '수령 금액'},
          {key: 'distributableTime', label: '지급 가능 일시'},
          {key: 'distributedTime', label: '수령 일시'},
          {key: 'state', label: '수령 상태'},
          {key: 'vote', label: '반대'},
        ],
      }
    },
    methods: {
      completed(row) {
        if (Number(row.item.distributableTime) < this.$root.now) {
          return true;
        } else {
          return false;
        }
      },
      progress(row) {
        if (Number(row.item.distributableTime) - Number(this.fund.interval) < this.$root.now &&
          this.$root.now < Number(row.item.distributableTime)) {
          return true;
        } else {
          return false;
        }
      },
      getStateString: function (row) {
        if (row.item.state == 0) {
          if (this.progress(row)) {
            return '투표중';
          } else {
            return '지급전';
          }
        } else if (row.item.state == 1) {
          return '지급완료';
        } else if (row.item.state == 2) {
          return '지급거절';
        } else {
          return null
        }
      }
    },
  }
</script>

<style scoped>
</style>
