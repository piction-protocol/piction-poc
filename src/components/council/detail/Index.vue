<template>
  <div>
    <div class="row">
      <div class="col-auto mr-auto page-title">{{comic.title}}</div>
      <div class="col-auto">
        <b-button variant="outline-secondary" :to="{name: 'episodes', params:{comic_id:comic_id}}" class="ml-2">작품 보기</b-button>      
      </div>
    </div>
    <br/>
    <div class="p-1" style="font-size:24px; font-weight:bold;">작품 등록 예치금</div>
    <div class="p-1">
      <span class="font-size-28"><b>{{deposit}}</b></span>
      <span class="font-size-14 text-secondary"> PXL</span>
    </div>
    <div v-if="!releaseHistory && deposit > 0" 
      class="p-1" style="font-size:14px; color:#9b9b9b">예치금 회수 권한 지급 날짜 : {{$utils.dateFmt(releaseDate)}}</div>
    <div v-if="!releaseHistory && deposit == 0"
      class="p-1" style="font-size:14px; color:#9b9b9b">반환될 예치금이 없습니다.</div>
    <div v-if="releaseHistory" class="p-1" style="font-size:14px; color:#9b9b9b">예치금이 반환되었습니다. ({{$utils.dateFmt(releaseHistory.date)}})</div>
    <br/>
    <div class="p-1" style="font-size:20px; font-weight:bold;">처리 대기중</div>
    <div>
      <b-table 
          :items="waitingList" 
          :fields="waitingFields" 
          show-empty 
          empty-text="처리 대기 중인 신고 내역이 없습니다.">
          <template slot="date" slot-scope="row">{{$utils.dateFmt(row.item.date)}}</template>
          <template slot="userName" slot-scope="row">{{row.item.userName}}</template>
          <template slot="detail" slot-scope="row">{{row.item.detail}}</template>
          <template slot="result" slot-scope="row">
            <b-button variant="link" @click.stop="row.toggleDetails"  style="font-size:14px; color:#000000">
              설정 {{ row.detailsShowing ? '▲' : '▼' }}
            </b-button>
          </template>
          <template slot="row-details" slot-scope="row">
            <b-card>
              <b-row class="mb-2" style="font-size:14px; font-weight:bold;">
                <b-col sm="3" class="text-sm-left">
                  <div class="p-1">종류</div>
                </b-col>
                <b-col>
                  <div class="p-1">제재 사유 입력</div>
                </b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-left">
                  <div><b-form-select size="md" v-model="row.item.selected" :options="options" class="mb-2" style="width: 134px"></b-form-select></div>                  
                </b-col>
                <b-col>
                  <div><b-form-input v-model="row.item.completeDetail" type="text" style="width: 561px" ></b-form-input></div>                 
                </b-col>
                <b-col>
                  <div><b-button variant="outline-secondary" style="width: 76px" @click="setCompleteReport(row.index)">등록</b-button></div>
                </b-col>
              </b-row>
              <b-row>
                <b-col style="font-size:14px;">
                  <div v-if="deposit == 0">
                    <div class="p-1">작품 등록 예치금이 0 PXL으로 차감 및 리워드 지급 없음.</div>
                  </div>
                  <div v-else>
                    <div class="p-1">작품 차단 : 작품 등록 예치금이 {{deposit}} PXL 차감되며, {{row.item.userName}}님에게 1 PXL이 리워드로 지급됩니다.</div>
                    <div class="p-1">작품 경고 : 작품 등록 예치금이 1 PXL 차감되며, {{row.item.userName}}님에게 1 PXL이 리워드로 지급됩니다.</div>
                    <div class="p-1">신고 내용 무효 : 예치금 차감/지급 없음.</div>
                    <div class="p-1">중복된 신고 내용 : 예치금 차감/지급 없음.</div>
                    <div class="p-1">허위 신고 : {{row.item.userName}}님의 신고 예치금에서 1 PXL이 차감됩니다.</div>
                  </div>
                </b-col>
              </b-row>
            </b-card>
          </template>
      </b-table>
    </div>
    <br/>
    <div class="p-1" style="font-size:20px; font-weight:bold;">처리 완료</div>
    <div>
      <b-table 
          :items="completedList" 
          :fields="completedFields"
          :current-page="currentPage"
          :per-page="perPage"
          show-empty 
          empty-text="처리 완료 내역이 없습니다.">
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
          {key: 'date', label: '신고 일시'},
          {key: 'userName', label: '신고자'},
          {key: 'detail', label: '신고 내용'},
          {key: 'result', label: '처리'}          
        ],
        waitingList: [],
        completedFields: [
          {key: 'date', label: '처리 일시'},
          {key: 'userName', label: '신고자'},
          {key: 'detail', label: '신고 내용'},
          {key: 'result', label: '처리'}
        ],
        completedList: [],
        perPage: 5,
        limit: 7,
        currentPage: 1,
        options: [
          { value: null, text: '선택' },
          { value: 1, text: '작품 차단' },
          { value: 2, text: '작품 경고' },
          { value: 3, text: '신고 내용 무효' },
          { value: 4, text: '중복된 신고 내용' },
          { value: 5, text: '허위 신고' }
        ],
      }
    },
    computed: {
    },
    methods: {
      async setComicInfo() {
        this.comic = await this.$contract.apiContents.getComic(this.comic_id);
        this.deposit = await this.$contract.depositPool.getDeposit(this.comic_id);
        this.releaseDate = await this.$contract.depositPool.getReleaseDate(this.comic_id);
        this.releaseHistory = (await this.$contract.depositPool.getDepositHistory(this.comic_id)).find(h => h.type == 6);
      },
      async setTableList() {
        var results = await this.$contract.report.getComicReportList(this, this.comic_id);
        if(results.length == 2){
          this.waitingList = results[0];
          this.completedList = results[1];
        }
        this.completedList = this.completedList.reverse();
      },
      async setCompleteReport(idx) {
        if(this.waitingList[idx].selected == null) {
          alert('처리 종류를 선택하세요.');
          return;
        }

        if(!this.waitingList[idx].completeDetail || 0 === this.waitingList[idx].completeDetail.length) {
          alert('제재 사유를 입력하세요.');
          return;
        }

        let loader = this.$loading.show();

        await this.$contract.apiReport.reportDisposal(this.waitingList[idx].index, this.waitingList[idx].content, this.waitingList[idx].from, this.waitingList[idx].selected, this.waitingList[idx].completeDetail);

        this.$toasted.show('처리되었습니다.', {position: "top-center"});
        await this.setComicInfo();
        await this.setTableList();
        loader.hide();
      },
      getResult(typeNumber, amount) {
        var result = '';

        var toPXL = this.web3.utils.fromWei(new this.web3.utils.BN(amount));
        if(typeNumber == 1 || typeNumber == 2 || typeNumber == 5) {
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
