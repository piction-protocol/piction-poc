<template>
  <div>
    <b-table striped hover
             :fields="fields"
             :items="funds"
             @row-clicked="detail"
             :small="true">
      <template slot="title" slot-scope="row">{{row.item.title}}</template>
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
  import FundItem from './FundItem'

  export default {
    components: {FundItem},
    data() {
      return {
        fields: [
          {key: 'title', label: '작품명'},
          {key: 'ordinal', label: '기수'},
          {key: 'fundTime', label: '모집기간'},
          {key: 'distributionRate', label: '분배비율'},
          {key: 'fundRise', label: '모집금액'},
          {key: 'state', label: '진행상태'},
        ],
        funds: [],
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
      }
    },
    async created() {
      let contents = await this.$contract.contentsManager.getContents();
      contents.reverse().asyncForEach(async content => {
        let contentRecord = await this.$contract.contentInterface.getRecord(content);
        let funds = await this.$contract.fundManager.getFunds(content);
        funds.forEach(async (fund, index) => {
          let fundRecord = await this.$contract.fund.getInfo(fund);
          let obj = {}
          obj.content_id = content;
          obj.fund_id = fund;
          obj.title = JSON.parse(contentRecord).title;
          obj.ordinal = this.numberToOrdinalString(index + 1);
          obj.startTime = Number(fundRecord[0]);
          obj.endTime = Number(fundRecord[1]);
          obj.fundRise = Number(fundRecord[2]);
          obj.distributionRate = Number(fundRecord[5]);
          obj.state = this.getState(obj);
          this.funds.push(obj);
        })
      })
    }
  }
</script>

<style scoped>
  div {
    text-align: center;
  }
</style>
