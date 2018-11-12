<template>
  <div>
    <b-table striped hover
             show-empty
             :empty-text="$t('emptyList')"
             :fields="fields"
             :items="fund.distributions"
             :small="true">
      <template slot="index" slot-scope="row">{{row.value + 1}}{{$t('회차')}}</template>
      <template slot="amount" slot-scope="row">
        <div v-b-popover.hover="row.value" >
          <div v-if="row.value / parseInt(row.value) > 1">{{parseFloat(row.value).toFixed(2)}} PXL</div>
          <div v-else>{{row.value}} PXL</div>
        </div>
      </template>
      <template slot="distributableTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="distributedTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="state" slot-scope="row">{{$t(row.item.getStateString())}}</template>
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

  export default {
    props: ['fund'],
    data() {
      return {
        fields: [
          {key: 'index', label: this.$t('회차')},
          {key: 'amount', label: this.$t('수령금액')},
          {key: 'distributableTime', label: this.$t('지급가능일시')},
          {key: 'distributedTime', label: this.$t('수령일시')},
          {key: 'state', label: this.$t('수령상태')},
          {key: 'vote', label: this.$t('반대')},
        ],
      }
    },
    methods: {},
  }
</script>

<style scoped>
</style>