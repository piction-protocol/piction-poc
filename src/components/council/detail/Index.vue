<template>
  <div>
    <div class="row">
      <div class="col-auto mr-auto page-title">{{comic.title}}</div>
      <div class="col-auto">
        <b-button variant="outline-secondary" :to="{name: 'episodes', params:{comic_id:comic_id}}" class="ml-2">
          {{$t('작품보기')}}
        </b-button>
      </div>
    </div>
    <br/>
    <div class="p-1" style="font-size:24px; font-weight:bold;">{{$t('작품등록예치금')}}</div>
    <div class="p-1">
      <span class="font-size-28"><b>{{deposit}}</b></span>
      <span class="font-size-14 text-secondary"> PXL</span>
    </div>
    <div v-if="!releaseHistory && deposit > 0"
         class="p-1" style="font-size:14px; color:#9b9b9b">
      {{$t('council.detail.deposit.paymentDate')}} : {{$utils.dateFmt(releaseDate)}}
    </div>
    <div v-if="!releaseHistory && deposit == 0"
         class="p-1" style="font-size:14px; color:#9b9b9b">{{$t('council.detail.deposit.emptyDeposit')}}
    </div>
    <div v-if="releaseHistory" class="p-1" style="font-size:14px; color:#9b9b9b">
      {{$t('council.detail.deposit.returnedDeposit')}} ({{$utils.dateFmt(releaseHistory.date)}})
    </div>
    <br/>
    <div class="p-1" style="font-size:20px; font-weight:bold;">{{$t('council.detail.form.waiting.title')}}</div>
    <div>
      <b-table
        :items="waitingList"
        :fields="waitingFields"
        show-empty
        :empty-text="$t('council.detail.form.waiting.emptyText')">
        <template slot="date" slot-scope="row">{{$utils.dateFmt(row.item.date)}}</template>
        <template slot="userName" slot-scope="row">{{row.item.userName}}</template>
        <template slot="detail" slot-scope="row">{{row.item.detail}}</template>
        <template slot="result" slot-scope="row">
          <b-button variant="link" @click.stop="row.toggleDetails" style="font-size:14px; color:#000000">
            {{$t('council.detail.form.waiting.setText')}} {{ row.detailsShowing ? '▲' : '▼' }}
          </b-button>
        </template>
        <template slot="row-details" slot-scope="row">
          <b-card>
            <b-row class="mb-2" style="font-size:14px; font-weight:bold;">
              <b-col sm="3" class="text-sm-left">
                <div class="p-1">{{$t('council.detail.form.waiting.type')}}</div>
              </b-col>
              <b-col>
                <div class="p-1">{{$t('council.detail.form.waiting.Sanctions')}}</div>
              </b-col>
            </b-row>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-left">
                <div>
                  <b-form-select size="md" v-model="row.item.selected" :options="options" class="mb-2"
                                 style="width: 134px"></b-form-select>
                </div>
              </b-col>
              <b-col>
                <div>
                  <b-form-input v-model="row.item.completeDetail" type="text" style="width: 561px"></b-form-input>
                </div>
              </b-col>
              <b-col>
                <div>
                  <b-button variant="outline-secondary" @click="setCompleteReport(row.index)">
                    {{$t('council.detail.form.waiting.completeButton')}}
                  </b-button>
                </div>
              </b-col>
            </b-row>
            <b-row>
              <b-col style="font-size:14px;">
                <div v-if="deposit == 0">
                  <div class="p-1">{{$t('council.detail.form.waiting.emptyDepositText')}}</div>
                </div>
                <div v-else>
                  <div class="p-1">{{$t('council.detail.form.waiting.type1', {
                    deposit: deposit,
                    nickName: row.item.userName
                  })}}
                  </div>
                  <div class="p-1">{{$t('council.detail.form.waiting.type2', {nickName: row.item.userName})}}</div>
                  <div class="p-1">{{$t('council.detail.form.waiting.type3')}}</div>
                  <div class="p-1">{{$t('council.detail.form.waiting.type4')}}</div>
                  <div class="p-1">{{$t('council.detail.form.waiting.type5', {nickName: row.item.userName})}}</div>
                </div>
              </b-col>
            </b-row>
          </b-card>
        </template>
      </b-table>
    </div>
    <br/>
    <div class="p-1" style="font-size:20px; font-weight:bold;">{{$t('council.detail.form.completed.title')}}</div>
    <div>
      <b-table
        :items="completedList"
        :fields="completedFields"
        :current-page="currentPage"
        :per-page="perPage"
        show-empty
        :empty-text="$t('council.detail.form.completed.emptyText')">
        <template slot="date" slot-scope="row">{{$utils.dateFmt(row.item.date)}}</template>
        <template slot="userName" slot-scope="row">{{row.item.userName}}</template>
        <template slot="detail" slot-scope="row">{{row.item.detail}}</template>
        <template slot="result" slot-scope="row">{{getResult(row.item.type, row.item.deductionAmount)}}</template>
      </b-table>
      <b-pagination class="d-flex justify-content-center" size="md"
                    :total-rows="completedList.length"
                    v-model="currentPage"
                    :per-page="perPage"
                    :limit="limit">
      </b-pagination>
    </div>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';
  import Web3Utils from '@utils/Web3Utils'
  import Comic from '@models/Comic'

  export default {
    props: ['comic_id'],
    data() {
      return {
        title: '',
        comic: new Comic(),
        deposit: 0,
        releaseDate: 0,
        releaseHistory: null,
        waitingFields: [
          {key: 'date', label: this.$t('council.detail.form.waiting.reportDate')},
          {key: 'userName', label: this.$t('council.detail.form.waiting.reporter')},
          {key: 'detail', label: this.$t('council.detail.form.waiting.reportContents')},
          {key: 'result', label: this.$t('council.detail.form.waiting.method')}
        ],
        waitingList: [],
        completedFields: [
          {key: 'date', label: this.$t('council.detail.form.completed.reportDate')},
          {key: 'userName', label: this.$t('council.detail.form.completed.reporter')},
          {key: 'detail', label: this.$t('council.detail.form.completed.reportContents')},
          {key: 'result', label: this.$t('council.detail.form.completed.method')}
        ],
        completedList: [],
        perPage: 5,
        limit: 7,
        currentPage: 1,
        options: [
          {value: null, text: this.$t('council.detail.form.waiting.options.type0')},
          {value: 1, text: this.$t('council.detail.form.waiting.options.type1')},
          {value: 2, text: this.$t('council.detail.form.waiting.options.type2')},
          {value: 3, text: this.$t('council.detail.form.waiting.options.type3')},
          {value: 4, text: this.$t('council.detail.form.waiting.options.type4')},
          {value: 5, text: this.$t('council.detail.form.waiting.options.type5')}
        ],
      }
    },
    computed: {},
    methods: {
      async setComicInfo() {
        this.comic = await this.$contract.apiContents.getComic(this.comic_id);
        this.deposit = await this.$contract.depositPool.getDeposit(this.comic_id);
        this.releaseDate = await this.$contract.depositPool.getReleaseDate(this.comic_id);
        this.releaseHistory = (await this.$contract.depositPool.getDepositHistory(this.comic_id)).find(h => h.type == 6);
      },
      async setTableList() {
        var results = await this.$contract.report.getComicReportList(this, this.comic_id);
        if (results.length == 2) {
          this.waitingList = results[0];
          this.completedList = results[1];
          this.waitingList.filter(r => r.detail.indexOf('reports.reason') != -1).forEach(r => r.detail = this.$t(r.detail));
          this.completedList.filter(r => r.detail.indexOf('reports.reason') != -1).forEach(r => r.detail = this.$t(r.detail));
        }
        this.completedList = this.completedList.reverse();
      },
      async setCompleteReport(idx) {
        if (this.waitingList[idx].selected == null) {
          alert(this.$t('council.detail.form.waiting.alert.type'));
          return;
        }

        if (!this.waitingList[idx].completeDetail || 0 === this.waitingList[idx].completeDetail.length) {
          alert(this.$t('council.detail.form.waiting.alert.sanctionText'));
          return;
        }

        let loader = this.$loading.show();

        try {
          await this.$contract.apiReport.reportDisposal(this.waitingList[idx].index, this.waitingList[idx].content, this.waitingList[idx].from, this.waitingList[idx].selected, this.waitingList[idx].completeDetail);
        } catch (e) {
          alert(this.$t('council.detail.form.waiting.alert.accessDenied'));
          loader.hide();
          return;
        }

        this.$toasted.show(this.$t('council.detail.completedMessage'), {position: "top-center"});
        await this.setComicInfo();
        await this.setTableList();
        loader.hide();
      },
      getResult(typeNumber, amount) {
        var result = '';

        var toPXL = this.web3.utils.fromWei(new this.web3.utils.BN(amount));
        if (typeNumber == 1 || typeNumber == 2 || typeNumber == 5) {
          result = this.options[typeNumber].text + ' (- ' + toPXL + ' PXL)';
        } else {
          result = this.options[typeNumber].text;
        }
        return result;
      }
    },
    async created() {
      await this.setComicInfo();
      await this.setTableList();
    },
  }
</script>

<style scoped>
</style>
