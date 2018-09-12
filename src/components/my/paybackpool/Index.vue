<template>
  <div role="group">
    <b-alert show variant="secondary">
      <div>작품을 구매하게 되면 보상으로 일정 PXL이 지급됩니다.</div>
      <div>지급 된 PXL은 <span class="text-danger font-weight-bold">지급일시가 지나야 출금이 가능</span>합니다.</div>
    </b-alert>
    <b-table striped hover
             :fields="fields"
             :items="list"
             :small="true">
      <template slot="index" slot-scope="row">{{Number(row.item.index) + 1}}</template>
      <template slot="createdTime" slot-scope="row">{{$utils.dateFmt(Number(row.item.createdTime))}}</template>
      <template slot="distributableTime" slot-scope="row">{{$utils.dateFmt(Number(row.item.distributableTime))}}
      </template>
      <template slot="amount" slot-scope="row">{{$utils.toPXL(row.item.amount)}} PXL</template>
      <template slot="released" slot-scope="row">{{row.item.released ? '지급완료' : '미지급'}}</template>
    </b-table>
    <b-button size="sm" variant="primary" class="form-control" @click="release"
              :disabled="amount==0">{{$utils.toPXL(amount)}} PXL 출금 신청
    </b-button>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';

  export default {
    data() {
      return {
        fields: [
          {key: 'index', label: '순번'},
          {key: 'createdTime', label: '생성일시'},
          {key: 'distributableTime', label: '지급일시'},
          {key: 'amount', label: '보상'},
          {key: 'released', label: '처리상태'},
        ],
        list: [],
        amount: 0,
      }
    },
    methods: {
      async release() {
        this.$loading('loading...');
        await this.$contract.userPaybackPool.release();
        window.location.reload();
      }
    },
    async created() {
      this.list = this.$utils.structArrayToJson(
        await this.$contract.userPaybackPool.getPaybackInfo(), ['index', 'amount', 'createdTime', 'distributableTime', 'released']
      )
      this.amount = this.list
        .filter(pool => !pool.released)
        .filter(o => Number(o.distributableTime) < new Date().getTime())
        .map(pool => Number(pool.amount))
        .reduce((a, v) => a + v, 0);
    }
  }
</script>

<style scoped>

</style>