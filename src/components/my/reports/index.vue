<template>
  <div>
    <div class="page-title">{{$t('신고처리내역')}}</div>
    <br>
    <div v-if="reporterRegistrationAmount == 0 && !reporterReporterBlock">
      <div align="center">
        <div class="title" v-html="$t('reportGuide')"></div>
        <b-button variant="outline-secondary mt-2" @click="transferFee">
          {{$t('publishInitialDepositButton', {amount: web3.utils.fromWei(reportRegistrationFee)})}}
          </b-button>
      </div>
    </div>
    <div v-else="">
      <div class="font-size-20 font-weight-bold mt-5 mb-2">{{$t('예치금')}}</div>
      <b-row>
        <b-col cols="2" sm="8" md="4" lg="2">
          <div>
            <span class="font-size-24">{{web3.utils.fromWei(reporterRegistrationAmount)}}</span>
            <span class="font-size-14 text-secondary">PXL</span>
          </div>
          <div class="font-size-12">{{$t('신고예치금')}}</div>
        </b-col>
        <b-col cols="2" sm="8" md="4" lg="2">
          <div>
            <span class="font-size-24">{{reporterReporterBlock ? "-" : reporterRegistrationLockTimeText.number}}</span>
            <span class="font-size-14 text-secondary">{{reporterRegistrationLockTimeText.text}}</span>
          </div>
          <div class="font-size-12">{{$t('신고권한종료까지남은시간')}}</div>
        </b-col>
      </b-row>
      <b-row class="pt-2 pb-2">
        <b-col cols="4">
          <b-progress :max="1"
                      height="12px" variant="primary">
            <b-progress-bar
              :value="progressValue"></b-progress-bar>
          </b-progress>
        </b-col>
      </b-row>
      <b-row>
        <b-col cols="4">
          <b-button
            v-if="reporterRegistrationLockTime < $root.now && reporterRegistrationAmount > 0"
            type="submit" size="sm" variant="outline-secondary" block @click="withdrawRegistration">{{$t('예치금반환')}}
          </b-button>
          <div v-if="reporterReporterBlock">
            {{$t('reportBlockMessage')}}
          </div>
          <div v-if="reporterRegistrationLockTime >= $root.now && reporterRegistrationAmount > 0">
            {{$t('reportDepositGuide')}}
          </div>
        </b-col>
      </b-row>
    </div>
    <br>
    <br>
    <br>
    <b-table striped hover
             show-empty
             :empty-text="$t('emptyList')"
             :fields="fields"
             :items="reports"
             :current-page="currentPage"
             :per-page="perPage"
             :small="true">
      <template slot="reportDate" slot-scope="row">{{$utils.dateFmt(row.item.reportDate)}}</template>
      <template slot="completeDate" slot-scope="row">{{$utils.dateFmt(row.item.completeDate)}}</template>
      <template slot="contentTitle" slot-scope="row">{{row.item.contentTitle}}</template>
      <template slot="reportDetail" slot-scope="row">{{row.item.reportDetail}}</template>
      <template slot="completeType" slot-scope="row">{{row.item.completeType}}</template>
    </b-table>
    <b-pagination class="d-flex justify-content-center" size="md"
                  :total-rows="reports.length"
                  v-model="currentPage"
                  :per-page="perPage"
                  :limit="limit">
    </b-pagination>
  </div>
</template>

<script>
  import ReportHistory from '@models/ReportHistory';
  import Web3Utils from '@utils/Web3Utils';

  export default {
    computed: {
      progressValue() {
        if (this.reporterRegistrationLockTime == 0) {
          return 0;
        } else {
          return 1 - (this.reporterRegistrationLockTime - this.$root.now) / this.interval;
        }
      },
      reporterRegistrationLockTimeText() {
        let time = Web3Utils.remainTimeToStr(this, this.reporterRegistrationLockTime)
        return time ? time : {number: '0', text: '초'};
      }
    },
    data() {
      return {
        fields: [
          {key: 'reportDate', label: this.$t('신고일시')},
          {key: 'completeDate', label: this.$t('처리일시')},
          {key: 'contentTitle', label: this.$t('작품명')},
          {key: 'reportDetail', label: this.$t('신고내용')},
          {key: 'completeType', label: this.$t('처리')},
        ],
        reporterRegistrationAmount: new web3.utils.BN('0'),
        reporterRegistrationLockTime: 0,
        reporterReporterBlock: false,
        reportRegistrationFee: new web3.utils.BN('0'),
        interval: 0,
        pxl: new web3.utils.BN('0'),
        reports: [],
        perPage: 10,
        limit: 7,
        currentPage: 1,
      }
    },
    methods: {
      async init() {
        this.reportRegistrationFee = new web3.utils.BN(String(this.pictionConfig.pictionValue.reportRegistrationFee));
        this.pxl = new web3.utils.BN(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
        let reagistration = await this.$contract.apiReport.getRegistrationAmount();
        this.reporterRegistrationAmount = new web3.utils.BN(reagistration[0]);
        this.reporterRegistrationLockTime = reagistration[1];
        this.reporterReporterBlock = reagistration[2];
        this.interval = 30 * 60 * 1000; //test 30 min
      },
      async setTable() {
        let contentIds = [];
        let list = [];
        //신고 이벤트 조회
        let events = await this.$contract.report.getMyReportList();
        events.forEach(event => {
          event = Web3Utils.prettyJSON(event.returnValues);
          let history = new ReportHistory();
          history.index = event.index;
          history.reportDate = event.date;
          if(event.detail.indexOf('reports.reason') != -1) {
            history.reportDetail = this.$t(event.detail);
          } else {
            history.reportDetail = event.detail;
          }
          list.push(history);

          contentIds.push(event.content);
        });

        //작품 명 조회
        let comics = await this.$contract.apiContents.getComics(this, contentIds);
        list.forEach((history, i) => history.contentTitle = comics[i].title);

        //신고처리 완료 조회
        events = await this.$contract.report.getMyCompleteReportList();
        events.forEach(event => {
          event = Web3Utils.prettyJSON(event.returnValues);
          let findObj = list.find(o => o.index == event.index);
          findObj.completeDate = event.completeDate;
          switch (event.type) {
            case "1":
              findObj.completeType = this.$t('resultReportCase1', {amount: this.web3.utils.fromWei(event.deductionAmount)})
              break;
            case "2":
              findObj.completeType = this.$t('resultReportCase2', {amount: this.web3.utils.fromWei(event.deductionAmount)})
              break;
            case "3":
              findObj.completeType = this.$t('resultReportCase3')
              break;
            case "4":
              findObj.completeType = this.$t('resultReportCase4')
              break;
            case "5":
              findObj.completeType = this.$t('resultReportCase5', {amount: this.web3.utils.fromWei(event.deductionAmount)})
              break;
            default:
              findObj.completeType = "";
          }
        });

        this.reports = list.reverse();
      },
      async transferFee() {
        let loader = this.$loading.show();
        if (this.reportRegistrationFee > this.pxl) {
          alert(this.$t('notEnoughPXL', {amount: this.web3.utils.fromWei(this.reportRegistrationFee)}));
          loader.hide();
          return;
        }
        try {
          await this.$contract.pxl.approveAndCall(this.pictionConfig.pictionAddress.report, this.reportRegistrationFee);
          this.init();
        } catch (e) {
          alert(e)
        }
        loader.hide();
      },
      async withdrawRegistration() {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiReport.withdrawRegistration();
          this.init();
        } catch (e) {
          alert(e)
        }
        loader.hide();
      }
    },
    async created() {
      this.init();
      this.setTable();
    }
  }
</script>

<style scoped>
  .title {
    font-size: 24px;
  }
</style>