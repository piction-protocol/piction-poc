<template>
  <div>
    <div align="right">
      <b-form-select v-model="selected" class="mb-2 w-25">
        <option :value="null">전체</option>
        <option :value="false">대기</option>
        <option :value="true">완료</option>
      </b-form-select>
    </div>
    <b-table striped hover
             stacked
             show-empty
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
             :current-page="currentPage"
             :per-page="perPage"
             :items="filteredList"
             :small="true">
      <template slot="title" slot-scope="row">
        <router-link size="x-sm" :to="{name: 'episodes', params:{content_id: row.item.content_id}}">
          {{row.item.title}}
        </router-link>
      </template>
      <template slot="detail" slot-scope="row">{{row.item.detail}}</template>
      <template slot="complete" slot-scope="row">
        <span :class="'badge badge-' + result(row.item).variant">{{result(row.item).text}}</span>
      </template>
    </b-table>
    <b-pagination class="d-flex justify-content-center" size="md" :total-rows="this.list.length" v-model="currentPage"
                  :per-page="perPage">
    </b-pagination>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';

  export default {
    computed: {
      filteredList() {
        if (this.selected == null) {
          return this.list;
        } else {
          return this.list.filter(o => o.complete == this.selected);
        }
      }
    },
    data() {
      return {
        selected: null,
        fields: [
          {key: 'title', label: '작품명'},
          {key: 'detail', label: '신고사유'},
          {key: 'complete', label: '처리결과'},
        ],
        currentPage: 0,
        perPage: 3,
        list: [],
      }
    },
    methods: {
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
        await this.$contract.report.getContract().getPastEvents('SendReport', {
          filter: {_from: this.pictionConfig.account},
          fromBlock: 0,
          toBlock: 'latest'
        }, async (error, events) => {
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
          }
        });
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