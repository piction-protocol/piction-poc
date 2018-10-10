<template>
  <div>
    <b-table striped hover
             show-empty
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
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
      <template slot="state" slot-scope="row">
        <b-badge :variant="row.item.state.variant">{{row.item.state.label}}</b-badge>
      </template>
    </b-table>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        fields: [
          {key: 'title', label: '작품명'},
          {key: 'fundTime', label: '모집기간'},
          {key: 'distributionRate', label: '분배비율'},
          {key: 'rise', label: '모집금액'},
          {key: 'state', label: '진행상태'},
        ],
        funds: [],
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
          fund.state = this.getState(fund);
        });
        this.funds = funds.reverse();
      },
      detail(fund) {
        this.$router.push({name: 'show-fund', params: {content_id: fund.content, fund_id: fund.fund}})
      },
      getState(fund) {
        if (fund.startTime > new Date().getTime()) {
          return {'label': '대기', 'variant': 'warning'};
        } else if (fund.endTime > new Date().getTime()) {
          return {'label': '진행중', 'variant': 'success'};
        } else {
          return {'label': '완료', 'variant': 'secondary'};
        }
      },
    },
    async created() {
      this.init();
    }
  }
</script>

<style scoped>
</style>
