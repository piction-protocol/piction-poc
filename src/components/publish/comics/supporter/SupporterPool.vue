<template>
  <div>
    <b-table striped hover
             show-empty
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
             :items="fund.distributions"
             :small="true">
      <template slot="index" slot-scope="row">{{row.value + 1}}회차</template>
      <template slot="amount" slot-scope="row">{{row.value}} PXL</template>
      <template slot="distributableTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="distributedTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="state" slot-scope="row">{{row.item.getStateString()}}</template>
      <template slot="vote" slot-scope="row">
        <div v-if="row.item.completed() || row.item.isCurrentPool()">
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
    methods: {},
  }
</script>

<style scoped>
</style>