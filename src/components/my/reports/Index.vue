<template>
  <div v-if="loaded">
    <div align="right">
      <b-form-select class="mb-2 w-25" :value="filter" @change="setFilter">
        <option :value="undefined">전체</option>
        <option :value="`pending`">대기</option>
        <option :value="`completed`">완료</option>
      </b-form-select>
    </div>
    <b-table striped hover
             stacked
             show-empty
             empty-text="조회된 목록이 없습니다"
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
      <template slot="detail" slot-scope="row">
        <div style="white-space: pre-line">{{row.item.detail}}</div>
      </template>
      <template slot="complete" slot-scope="row">
        <span :class="'badge badge-' + result(row.item).variant">{{result(row.item).text}}</span>
      </template>
    </b-table>
    <b-pagination class="d-flex justify-content-center" size="md"
                  :total-rows="filteredList.length"
                  :value="page"
                  :per-page="perPage"
                  :limit="limit"
                  @change="changePage">
    </b-pagination>
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
          {key: 'detail', label: '신고사유'},
          {key: 'complete', label: '처리결과'},
        ],
        currentPage: 0,
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
      getEventJsonObj(event) {
        return {
          id: event.returnValues.id,
          content_id: event.returnValues._content,
          user: event.returnValues._from,
          title: event.returnValues._content,
          detail: event.returnValues._detail,
          complete: false,
          rewardAmount: 0,
          action: ''
        }
      },
      async loadList() {
        const events = await this.$contract.report.getContract().getPastEvents('SendReport', {
          filter: {_from: this.pictionConfig.account},
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
        this.$contract.council.setCallback(async (error, event) => {
          let findObj = this.list.find(o => o.id == event.returnValues._index);
          findObj.complete = true;
          findObj.rewardAmount = this.$utils.toPXL(event.returnValues._rewordAmount);

          var contents = await this.$contract.apiContents.getContentsRecord([findObj.content_id]);
          contents = JSON.parse(web3.utils.hexToUtf8(contents.records_))
          findObj.title = contents[0].title;
        });
      },
      result(item) {
        if (item.complete) {
          if (item.rewardAmount == 0) {
            return {text: `반려`, variant: 'danger'}
          } else {
            return {text: `보상 ${item.rewardAmount} PXL 지급`, variant: 'primary'}
          }
        } else {
          return {text: `처리 대기중`, variant: 'secondary'}
        }
      },
    },
    async created() {
      await this.setEvent();
      await this.loadList();
    }
  }
</script>

<style scoped>

</style>