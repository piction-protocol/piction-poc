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
          {key: 'title', label: 'Title'},
          {key: 'ordinal', label: 'Ordinal'},
          {key: 'fundTime', label: 'Fund TIme'},
          {key: 'distributionRate', label: 'Distribution Rate'},
          {key: 'fundRise', label: 'Fund Rise'},
          {key: 'state', label: 'State'},
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
          return {'label': 'READY', 'variant': 'warning'};
        } else if (obj.endTime > new Date().getTime()) {
          return {'label': 'FUNDING', 'variant': 'success'};
        } else {
          return {'label': 'FUNDED', 'variant': 'secondary'};
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
      contents.forEach(async content => {
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
