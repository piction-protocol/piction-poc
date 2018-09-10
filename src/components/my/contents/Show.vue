<template>
  <div>
    <b-row style="margin-bottom: 8px">
      <b-col cols="3">
        <img :src="record.thumbnail" class="thumbnail"/>
      </b-col>
      <b-col style="padding: 15px">
        <div>
          <h5>{{record.title}}</h5>
          <p>{{record.synopsis}}</p>
          <b-button variant="outline-success" @click="showContent" size="sm">작품보기</b-button>
          <b-button variant="outline-success" @click="addEpisode" size="sm">회차등록</b-button>
          <b-button variant="outline-success" :disabled="fundDisable" @click="addFund" size="sm">서포터모집</b-button>
          <b-button variant="outline-success" :disabled="deposit == 0" @click="release" size="sm">
            예치금 {{deposit}}PXL 회수
          </b-button>
        </div>
      </b-col>
    </b-row>
    <br>
    <h5>서포터 모집 현항</h5>
    <b-table striped hover
             :fields="fields"
             :items="funds"
             @row-clicked="detail"
             :small="true">
      <template slot="ordinal" slot-scope="row">{{row.item.ordinal}}</template>
      <template slot="fundTime" slot-scope="row">
        {{$utils.dateFmt(row.item.startTime)}}~{{$utils.dateFmt(row.item.endTime)}}
      </template>
      <template slot="distributionRate" slot-scope="row">{{$utils.toPXL(row.item.distributionRate) * 100}}%</template>
      <template slot="fundRise" slot-scope="row">{{$utils.toPXL(row.item.fundRise)}} PXL</template>
      <template slot="state" slot-scope="row">
        <b-badge :variant="row.item.state.variant">{{row.item.state.label}}</b-badge>
      </template>
    </b-table>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';
  import moment from 'moment';

  export default {
    props: ['content_id'],
    data() {
      return {
        fields: [
          {key: 'ordinal', label: '기수'},
          {key: 'fundTime', label: '모집기간'},
          {key: 'distributionRate', label: '분배비율'},
          {key: 'fundRise', label: '모집금액'},
          {key: 'state', label: '진행상태'},
        ],
        record: {},
        deposit: 0,
        funds: [],
        fundDisable: false,
      }
    },
    methods: {
      detail(item) {
        this.$router.push({name: 'show-fund', params: {content_id: item.content_id, fund_id: item.fund_id}})
      },
      getState(obj) {
        if (obj.startTime > new Date().getTime()) {
          return {'label': '대기', 'variant': 'warning'};
        } else if (obj.endTime > new Date().getTime()) {
          return {'label': '진행중', 'variant': 'success'};
        } else {
          return {'label': '완료', 'variant': 'secondary'};
        }
      },
      numberToOrdinalString(number) {
        if (number % 10 == 1) {
          return number + 'st';
        } else if (number % 10 == 2) {
          return number + 'nd';
        } else if (number % 10 == 3) {
          return number + 'rd';
        } else {
          return number + 'th';
        }
      },
      addFund: function () {
        this.$router.push({name: 'new-fund', params: {content_id: this.content_id}})
      },
      showContent: function () {
        this.$router.push({name: 'episodes', params: {content_id: this.content_id}})
      },
      addEpisode: function () {
        this.$router.push({name: 'new-episode', params: {content_id: this.content_id}})
      },
      release: async function () {
        this.$loading('loading...');
        try {
          await this.$contract.depositPool.release(this.content_id);
        } catch (e) {
          alert('완료되지 않은 신고내역이 있습니다.')
        }
        window.location.reload();
      }
    },
    async created() {
      await this.$contract.contentInterface.getRecord(this.content_id)
        .then(r => this.record = JSON.parse(r));

      let funds = await this.$contract.fundManager.getFunds(this.content_id);
      funds.forEach(async (fund, index) => {
        let fundRecord = await this.$contract.fund.getInfo(fund);
        let obj = {}
        obj.fund_id = fund;
        obj.ordinal = this.numberToOrdinalString(index + 1);
        obj.startTime = Number(fundRecord[0]);
        obj.endTime = Number(fundRecord[1]);
        obj.fundRise = Number(fundRecord[2]);
        obj.distributionRate = Number(fundRecord[5]);
        obj.state = this.getState(obj);
        this.funds.push(obj);
        if (obj.endTime > new Date().getTime()) {
          this.fundDisable = true;
        }
      });
      this.deposit = this.$utils.toPXL(await this.$contract.depositPool.getDeposit(this.content_id));
    }
  }
</script>

<style scoped>
  .thumbnail {
    width: 100%;
    border-radius: 0.5rem;
    background-position: center;
    background-size: cover;
    background-color: #e8e8e8;
  }

  a {
    color: inherit;
  }

  a:hover {
    text-decoration: inherit;
  }
</style>
