<template>
  <div v-if="loaded">
    <b-alert show variant="danger" class="font-weight-bold">해당 기능은 위원회만 실행 가능합니다.</b-alert>
    <div align="right">
      <b-form-select class="mb-2 w-25" :value="filter" @change="setFilter">
        <option :value="undefined">전체</option>
        <option :value="`pending`">대기</option>
        <option :value="`completed`">완료</option>
      </b-form-select>
    </div>
    <b-table striped hover
             show-empty
             empty-text="조회된 목록이 없습니다"
             stacked
             :fields="fields"
             :current-page="page"
             :per-page="perPage"
             :items="filteredList"
             :small="true">
      <template slot="title" slot-scope="row">
        <router-link size="x-sm" :to="{name: 'episodes', params:{content_id: row.item.content_id}}">
          {{row.item.title}}
        </router-link>
      </template>
      <template slot="user" slot-scope="row">
        {{row.item.user}}
      </template>
      <template slot="detail" slot-scope="row">
        <div style="white-space: pre-line">{{row.item.detail}}</div>
      </template>
      <template slot="complete" slot-scope="row">
        <b-button :disabled="row.item.complete" size="sm" :variant="result(row.item).variant" class="form-control"
                  @click="showModal(row.item)">{{result(row.item).text}}
        </b-button>
      </template>
    </b-table>
    <b-pagination class="d-flex justify-content-center" size="md"
                  :total-rows="filteredList.length"
                  :value="page"
                  :per-page="perPage"
                  :limit="limit"
                  @change="changePage">
    </b-pagination>
    <b-modal ref="reportModal" hide-footer title="신고처리">
      <b-btn class="mt-3" variant="outline-primary" block @click="reportProcess(true)">보상지급</b-btn>
      <b-btn class="mt-3" variant="outline-primary" block @click="reportProcess(false)">반려</b-btn>
      <b-btn class="mt-3" variant="secondary" block @click="hideModal">취소</b-btn>
    </b-modal>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';

  export default {
    props: ['page', 'filter'],
    computed: {
      filteredList() {
        if (this.filter == 'pending') {
          return this.list.filter(o => o.complete == false);
        } else if (this.filter == 'completed') {
          return this.list.filter(o => o.complete == true);
        } else {
          return this.list;
        }
      }
    },
    data() {
      return {
        loaded: false,
        fields: [
          {key: 'title', label: '작품명'},
          {key: 'user', label: '신고자'},
          {key: 'detail', label: '신고사유'},
          {key: 'complete', label: '처리결과'},
        ],
        perPage: 3,
        limit: 7,
        list: [],
      }
    },
    methods: {
      setFilter(value) {
        this.$router.push({query: {page: 1, filter: value}})
      },
      changePage(value) {
        this.$router.push({query: {page: value, filter: this.filter}})
      },
      showModal(item) {
        this.$refs.reportModal.$data.selectedReport = item;
        this.$refs.reportModal.show()
      },
      hideModal() {
        this.$refs.reportModal.hide()
      },
      async reportProcess(success) {
        const report = this.$refs.reportModal.$data.selectedReport;
        let loader = this.$loading.show();
        try {
          await this.$contract.apiReport.reportProcess(report.id, report.content_id, report.user, success);
        } catch (e) {
          alert(e)
        }
        this.hideModal();
        loader.hide();
      },
      result(item) {
        if (item.complete) {
          if (item.rewardAmount == 0) {
            return {text: `반려`, variant: 'danger'}
          } else {
            return {text: `보상 ${item.rewardAmount} PXL 지급`, variant: 'primary'}
          }
        } else {
          return {text: `처리`, variant: 'primary'}
        }
      },
      getEventJsonObj(event) {
        return {
          id: event.returnValues.id,
          content_id: event.returnValues._content,
          user: event.returnValues._from,
          title: '',
          detail: event.returnValues._detail,
          complete: false,
          rewardAmount: 0,
          action: ''
        }
      },
      async loadList() {
        const events = await this.$contract.report.getContract().getPastEvents('SendReport', {
          fromBlock: 0,
          toBlock: 'latest'
        });
        var list = [];
        events.forEach(event => list.push(this.getEventJsonObj(event)));
        const ids = list.map(o => o.id);
        const contentIds = list.map(o => o.content_id);
        if (ids.length > 0) {
          var result = await this.$contract.apiReport.getReportResult(ids);
          var contents = await this.$contract.apiContents.getContentsRecord(contentIds);
          contents = JSON.parse(web3.utils.hexToUtf8(contents.records_))
          result.complete_.forEach((o, i) => list[i].complete = o);
          result.completeAmount_.forEach((o, i) => list[i].rewardAmount = this.$utils.toPXL(o));
          result.completeAmount_.forEach((o, i) => list[i].title = contents[i].title);
          this.list = list.reverse();
          this.loaded = true;
        }
      },
      setEvent() {
        this.$contract.report.setCallback(async (error, event) => {
          const obj = this.getEventJsonObj(event);
          var contents = await this.$contract.apiContents.getContentsRecord([obj.content_id]);
          contents = JSON.parse(web3.utils.hexToUtf8(contents.records_))
          obj.title = contents[0].title;
          this.list.splice(0, 0, obj);
        });
        this.$contract.council.setCallback(async (error, event) => {
          let findObj = this.list.find(o => o.id == event.returnValues._index);
          findObj.complete = true;
          findObj.rewardAmount = this.$utils.toPXL(event.returnValues._rewordAmount);
        });
      }
    },
    async created() {
      this.setEvent();
      this.loadList();
    },
  }
</script>

<style scoped>

</style>
