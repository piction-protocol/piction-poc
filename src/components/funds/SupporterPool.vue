<template>
  <div>
    <b-table striped hover
             show-empty
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
             :items="distributions"
             thead-class="text-center"
             tbody-class="text-center"
             :small="true">
      <template slot="amount" slot-scope="row">{{$utils.toPXL(row.value)}} PXL</template>
      <template slot="distributableTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="distributedTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="state" slot-scope="row">{{getStateString(row.value)}}</template>
      <template slot="vote" slot-scope="row">
        <b-button :disabled="row.item.disable" variant="primary" size="sm" @click.stop="vote(row.index)">
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
    props: ['distributions'],
    data() {
      return {
        fields: [
          {key: 'amount', label: '회수금액'},
          {key: 'distributableTime', label: '회수가능일시'},
          {key: 'distributedTime', label: '회수일시'},
          {key: 'state', label: '회수상태'},
          {key: 'vote', label: 'Vote'},
        ],
        currentPage: 1,
        perPage: 3,
        limit: 7,
      }
    },
    methods: {
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
    },
  }
</script>

<style scoped>
</style>
