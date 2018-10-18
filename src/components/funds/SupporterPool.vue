<template>
  <div>
    <b-table striped hover
             show-empty
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
             :current-page="currentPage"
             :per-page="perPage"
             :items="distributions"
             thead-class="text-center"
             tbody-class="text-center"
             :small="true">
      <template slot="amount" slot-scope="row">{{$utils.toPXL(row.value)}} PXL</template>
      <template slot="distributableTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="distributedTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="state" slot-scope="row">{{getStateString(row.value)}}</template>
      <template slot="vote" slot-scope="row">
        <b-button :disabled="disabled(row)" variant="primary" size="sm" @click.stop="vote(row.index)">
          {{row.item.votingCount}} vote
        </b-button>
      </template>
    </b-table>
    <b-pagination class="d-flex justify-content-center" size="md"
                  :total-rows="distributions.length"
                  v-model="currentPage"
                  :per-page="perPage"
                  :limit="limit">
    </b-pagination>
  </div>
</template>

<script>
  import moment from 'moment';
  import {Datetime} from 'vue-datetime';
  import {record as _record} from './helper';
  import BigNumber from 'bignumber.js'

  export default {
    props: ['fund_id', 'fund', 'distributions', 'isDisabled'],
    data() {
      return {
        fields: [
          {key: 'amount', label: '지급금액'},
          {key: 'distributableTime', label: '지급가능일시'},
          {key: 'distributedTime', label: '지급일'},
          {key: 'state', label: '지급상태'},
          {key: 'vote', label: 'Vote'},
        ],
        currentPage: 1,
        perPage: 5,
        limit: 7,
      }
    },
    methods: {
      disabled(row) {
//        if (this.isDisabled) {
        if (false) {
          return true;
        } else if (row.item.state == 2) {
          return true;
        } else if (Number(row.item.distributableTime) - Number(this.fund.releaseInterval) < this.$root.now &&
          this.$root.now < Number(row.item.distributableTime)) {
          return false;
        } else {
          return true;
        }
      },
      vote: async function (index) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiFund.vote(this.fund_id, index);
        } catch (e) {
          alert(e)
        }
        loader.hide();
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
    },
  }
</script>

<style scoped>
</style>
