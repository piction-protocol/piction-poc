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
             show-empty
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
             :items="funds"
             @row-clicked="detail"
             thead-class="text-center"
             tbody-class="text-center"
             :small="true">
      <template slot="fundTime" slot-scope="row">
        {{$utils.dateFmt(row.item.startTime)}} ~ {{$utils.dateFmt(row.item.endTime)}}
      </template>
      <template slot="distributionRate" slot-scope="row">{{$utils.toPXL(row.item.distributionRate) * 100}}%</template>
      <template slot="rise" slot-scope="row">{{$utils.toPXL(row.item.rise)}} PXL</template>
      <template slot="softcap" slot-scope="row">{{$utils.toPXL(row.item.softcap)}} PXL</template>
      <template slot="maxcap" slot-scope="row">{{$utils.toPXL(row.item.maxcap)}} PXL</template>
      <template slot="state" slot-scope="row">
        <b-badge :variant="getState(row.item).variant">{{getState(row.item).label}}</b-badge>
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
          {key: 'fundTime', label: '모집기간'},
          {key: 'distributionRate', label: '분배비율'},
          {key: 'rise', label: '모집금액'},
          {key: 'softcap', label: 'softcap'},
          {key: 'maxcap', label: 'maxcap'},
          {key: 'state', label: '진행상태'},
        ],
        record: {},
        deposit: 0,
        funds: [],
        fundDisable: false,
        events: []
      }
    },
    methods: {
      async init() {
        const content = await this.$contract.apiContents.getContentsDetail(this.content_id);
        this.record = content.record;
        const funds = await this.$contract.apiFund.getFunds(this.content_id);
        const rise = await this.$contract.apiFund.getFundRise(funds.map(fund => fund.fund));
        funds.forEach((fund, i) => {
          fund.rise = rise[i]
        });
        this.funds = funds.reverse();
        this.deposit = this.$utils.toPXL(await this.$contract.depositPool.getDeposit(this.content_id));
      },
      async setEvent() {
        this.funds.forEach(fund => {
          const supportEvent = this.$contract.fund.getContract(fund.fund).events
            .Support({fromBlock: 'latest'}, () => this.init());
          this.events.push(supportEvent);
        });
      },
      detail(fund) {
        this.$router.push({name: 'show-fund', params: {content_id: fund.content, fund_id: fund.fund}})
      },
      getState(fund) {
        if (fund.startTime > this.$root.now) {
          return {'label': '대기', 'variant': 'warning'};
        } else if (fund.endTime > this.$root.now && Number(fund.rise) < Number(fund.maxcap)) {
          return {'label': '진행중', 'variant': 'success'};
        } else {
          return {'label': '완료', 'variant': 'secondary'};
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
          this.init();
        } catch (e) {
          alert('완료되지 않은 신고내역이 있습니다.')
        }
        this.$loading.close();
      }
    },
    async created() {
      await this.init();
      await this.setEvent();
    },
    async destroyed() {
      this.events.forEach(async event => await event.unsubscribe());
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
