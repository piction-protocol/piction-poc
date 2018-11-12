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
        <div v-b-popover.hover="row.value">
          <div v-if="row.value / parseInt(row.value) > 1">{{parseFloat(row.value).toFixed(2)}} PXL</div>
          <div v-else>{{row.value}} PXL</div>
        </div>
      </template>
      <template slot="startTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="distributableTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="distributedTime" slot-scope="row">{{$utils.dateFmt(row.value)}}</template>
      <template slot="state" slot-scope="row">{{$t(row.item.getStateString())}}</template>
      <template slot="vote" slot-scope="row">
        <div v-if="row.item.completed() || row.item.isCurrentPool()">
          {{row.item.votingCount}} / {{fund.supporters.length}}
        </div>
      </template>
      <template slot="row-details" slot-scope="row">
        <b-card class="text-center">
          <div v-if="row.item.state == 2">
            <div>{{row.item.index + 1}}{{$t('회차')}} <span class="font-weight-bold">{{row.item.amount}}PXL</span>{{$t('canclePayment')}}
            </div>
          </div>
          <div v-else>
            <div v-if="row.item.isVoting">
              <div>{{$t('votedMessage')}}</div>
            </div>
            <div v-else>
              <!-- <div>{{row.item.index + 1}}{{$t('회차')}} <span class="font-weight-bold">{{row.item.amount}}PXL</span>
                을 <span class="font-weight-bold">{{$utils.dateFmt(row.item.distributableTime)}}</span>
                에 작가에게 지급하는 것에 반대하십니까?
              </div> -->
              <div>
                {{row.item.index + 1}}{{$t('회차')}} {{$t('paymentVoting')}} <span class="font-weight-bold">{{row.item.amount}}PXL</span>
                , <span class="font-weight-bold">{{$utils.dateFmt(row.item.distributableTime)}}</span>
              </div>
              <b-button class="m-3" type="submit"
                        :disabled="row.item.isVoting"
                        @click="vote(row.item.index)" variant="outline-secondary">{{$t('투표참여')}}
              </b-button>
              <div>{{$t('votingGuide')}}</div>
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
          {key: 'index', label: this.$t('회차')},
          {key: 'amount', label: this.$t('수령금액')},
          {key: 'startTime', label: this.$t('투표시작일시')},
          {key: 'distributableTime', label: this.$t('지급가능일시')},
          {key: 'distributedTime', label: this.$t('수령일시')},
          {key: 'state', label: this.$t('수령상태')},
          {key: 'vote', label: this.$t('반대')},
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