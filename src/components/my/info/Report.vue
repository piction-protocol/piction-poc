<template>
  <div role="group">
    <h5>작품 신고 처리 결과</h5>
    <b-alert show variant="secondary">
      <div>정상적인 신고의 경우 보상으로 일정 PXL이 지급됩니다.</div>
      <div>허위 신고의 경우 신고 예치금이 차감 되거나, 신고 활동이 일시 중단될 수 있습니다.</div>
      <div>신고의 처리는 위원회에서 수시로 확인하여 처리합니다.</div>
      <div class="text-danger font-weight-bold">* 검수 대기중인 신고가 있으면 환급 신청이 불가능합니다.</div>
    </b-alert>
    <b-table striped hover
             :fields="fields"
             :items="list"
             :small="true">
      <template slot="title" slot-scope="row">
        <router-link size="sm" :to="{name: 'episodes', params:{content_id: row.item.content}}">
          {{row.item.title}}
        </router-link>
      </template>
      <template slot="detail" slot-scope="row">{{row.item.detail}}</template>
      <template slot="result" slot-scope="row">{{result(row.item)}}</template>
    </b-table>
    <b-button size="sm" variant="primary" class="form-control" @click="returnRegFee"
              :disabled="isLock">{{buttonText}}
    </b-button>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';

  export default {
    computed: {
      isLock() {
        return this.list.find(o => !o.complete) != undefined ||
          Number(this.regFee[1]) > new Date().getTime() ||
          Number(this.regFee[0]) == 0;
      },
      buttonText() {
        if (!this.regFee[1]) {
          return '0 PXL 신고 예치금 환급 신청';
        } else if (Number(this.regFee[1]) > new Date().getTime()) {
          return `${this.$utils.dateFmt(this.regFee[1])} 이후 ${this.$utils.toPXL(this.regFee[0])} PXL 출금 신청 가능`;
        } else {
          return `${this.$utils.toPXL(this.regFee[0])} PXL 신고 예치금 환급 신청`;
        }
      }
    },
    data() {
      return {
        fields: [
          {key: 'title', label: '작품명'},
          {key: 'detail', label: '신고사유'},
          {key: 'result', label: '처리결과'},
        ],
        list: [],
        regFee: {},
      }
    },
    methods: {
      result(item) {
        if (item.complete) {
          if (item.completeValid) {
            return `보상 ${this.$utils.toPXL(item.completeAmount)} PXL 지급`
          } else {
            return `예치금 ${this.$utils.toPXL(item.completeAmount)} PXL 차감`
          }
        } else {
          return '검수대기'
        }
      },
      async returnRegFee() {
        this.$loading('loading...');
        try {
          await this.$contract.report.returnRegFee();
        } catch (e) {
          alert(e)
        }
        window.location.reload();
      },
    },
    async created() {
      let indexes = await this.$contract.report.getUserReport();
      indexes.forEach(async index => {
        let report = await this.$contract.report.getReport(index);
        report.title = JSON.parse(await this.$contract.contentInterface.getRecord(report.content)).title;
        this.list.push(report);
      });
      this.regFee = await this.$contract.report.getRegFee();
    }
  }
</script>

<style scoped>

</style>