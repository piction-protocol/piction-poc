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
      <template slot="startTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="distributableTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="distributedTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="state" slot-scope="row">{{row.item.getStateString()}}</template>
      <template slot="vote" slot-scope="row">
        <div v-if="row.item.completed() || row.item.isCurrentPool()">
          {{row.item.votingCount}} / {{fund.supporters.length}}
        </div>
      </template>
      <template slot="row-details" slot-scope="row">
        <b-card class="text-center">
          <div v-if="row.item.state == 2">
            <div>{{row.item.index + 1}}회차 <span class="font-weight-bold">{{row.item.amount}}PXL</span> 지급은 취소되었습니다.</div>
          </div>
          <div v-else>
            <div v-if="row.item.isVoting">
              <div>투표에 참여하였습니다.</div>
            </div>
            <div v-else>
              <div>{{row.item.index + 1}}회차 <span class="font-weight-bold">{{row.item.amount}}PXL</span>
                을 <span class="font-weight-bold">{{$utils.dateFmt(row.item.distributableTime)}}</span>
                에 작가에게 지급하는 것에 반대하십니까?
              </div>
              <b-button class="m-3" type="submit"
                        :disabled="row.item.isVoting"
                        @click="vote(row.item.index)" variant="outline-secondary">투표 참여
              </b-button>
              <div>수령 가능 일시 전까지 투표가 진행되며, 수령 가능 일시 전까지 투표를 하지 않으시면 찬성으로 자동 처리됩니다.</div>
            </div>
          </div>
        </b-card>
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
          {key: 'startTime', label: '투표 시작 일시'},
          {key: 'distributableTime', label: '지급 가능 일시'},
          {key: 'distributedTime', label: '수령 일시'},
          {key: 'state', label: '수령 상태'},
          {key: 'vote', label: '반대'},
        ],
      }
    },
    methods: {
      async vote(index) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiFund.vote(this.fund.address, index);
          this.$parent.setDistributions();
        } catch (e) {
          alert(e);
        }
        loader.hide();
      },
    },
  }
</script>

<style scoped>
</style>