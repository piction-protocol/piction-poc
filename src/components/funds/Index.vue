<template>
  <div v-if="loaded">
    <b-table striped hover
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
             :current-page="page"
             :per-page="perPage"
             :items="funds"
             @row-clicked="detail"
             thead-class="text-center"
             tbody-class="text-center"
             :small="true">
      <template slot="title" slot-scope="row">{{row.item.title}}</template>
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
    <b-pagination class="d-flex justify-content-center" size="md"
                  :total-rows="funds.length"
                  :value="page"
                  :per-page="perPage"
                  :limit="limit"
                  @change="changePage">
    </b-pagination>
  </div>
</template>

<script>
  import Web3Utils from '../../utils/Web3Utils.js'

  export default {
    props: ['page'],
    data() {
      return {
        fields: [
          {key: 'title', label: '작품명'},
          {key: 'fundTime', label: '모집기간'},
          {key: 'distributionRate', label: '분배비율'},
          {key: 'rise', label: '모집금액'},
          {key: 'softcap', label: 'softcap'},
          {key: 'maxcap', label: 'maxcap'},
          {key: 'state', label: '진행상태'},
        ],
        loaded: false,
        funds: [],
        perPage: 15,
        limit: 7,
        events: []
      }
    },
    methods: {
      async init() {
        const funds = await this.$contract.apiFund.getFunds();
        const titles = (await this.$contract.apiContents.getRecords(funds.map(fund => fund.content))).map(record => record.title);
        const rise = await this.$contract.apiFund.getFundRise(funds.map(fund => fund.fund));
        funds.forEach((fund, i) => {
          fund.title = titles[i]
          fund.rise = rise[i]
        });
        this.funds = funds.reverse();
        this.loaded = true;
      },
      async setEvent() {
        const event = this.$contract.apiFund.getContract().events.AddFund({fromBlock: 'latest'}, async (error, event) => {
          this.init();
        });
        this.events.push(event);
      },
      changePage(value) {
        this.$router.push({query: {page: value}})
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
    },
    async created() {
      this.setEvent();
      this.init();
    },
    async destroyed() {
      this.events.forEach(async event => await event.unsubscribe());
    }
  }
</script>

<style scoped>
</style>
