<template>
  <div>
    <b-alert show variant="danger" class="font-weight-bold">해당 기능은 위원회만 실행 가능합니다.</b-alert>
    <h5>작품 신고 목록</h5>
    <!--<b-alert show variant="secondary">
      <div>정상적인 신고의 경우 가중치를 0으로 설정합니다. 신고자에게 보상이 주어집니다.</div>
      <div>허위 신고의 경우 가중치를 설정해서 신고 예치금을 위원회로 회수합니다.</div>
      <div class="text-danger font-weight-bold">* 가중치 50 이상을 설정하면 신고자는 일시적으로 신고 활동을 할 수 없습니다.</div>
    </b-alert>-->
    <b-table striped hover
             :fields="fields"
             :current-page="currentPage"
             :per-page="perPage"
             :items="list"
             :small="true">
      <template slot="id" slot-scope="row">{{row.item.id}}</template>
      <template slot="title" slot-scope="row">
        <router-link size="x-sm" :to="{name: 'episodes', params:{content_id: row.item.content_id}}">
          {{row.item.title}}
        </router-link>
      </template>
      <template slot="detail" slot-scope="row">{{row.item.detail}}</template>
      <template slot="user" slot-scope="row">{{row.item.user}}</template>
      <template slot="result" slot-scope="row">{{result(row.item)}}</template>
      <template slot="action" slot-scope="row">
        <b-button :disabled="row.item.complete" size="sm" variant="primary" class="form-control"
                  @click="judge(row.item)">처리
        </b-button>
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
    data() {
      return {
        fields: [
          {key: 'id', label: 'ID'},
          {key: 'title', label: '작품명'},
          {key: 'user', label: '신고자'},
          {key: 'detail', label: '신고사유'},
          {key: 'result', label: '처리결과'},
          {key: 'action', label: '처리'},
        ],
        currentPage: 0,
        perPage: 7,
        list: [],
        regFee: {},
      }
    },
    methods: {
      async judge(item) {
        let rate = prompt('신고 가중치를 입력하세요. (0 ~ 100)', '0');
        rate = parseInt(rate)
        if (rate < 0 || rate > 100) {
          alert('신고 가중치는 0 ~ 100 까지만 허용합니다.')
        }
        this.$loading('loading...');
        try {
          await this.$contract.council.judge(item.index, item.content, item.reporter, BigNumber(rate / 100).multipliedBy(Math.pow(10, 18)));
        } catch (e) {
          alert(e)
        }
        window.location.reload();
      },
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
    },
    async created() {
      this.$contract.report.setCallback((error, event) => {
        this.list.splice(0, 0, {
          id: event.returnValues.id,
          content_id: event.returnValues._content,
          user: event.returnValues._from,
          title: event.returnValues._content,
          detail: event.returnValues._detail,
          result: '',
          action: ''
        });
        console.log(event);
      })

      this.$contract.report.getContract().getPastEvents('SendReport', {
        fromBlock: 0,
        toBlock: 'latest'
      }, (error, events) => {
        events.forEach(event => {
          this.list.push({
            id: event.returnValues.id,
            content_id: event.returnValues._content,
            user: event.returnValues._from,
            title: event.returnValues._content,
            detail: event.returnValues._detail,
            result: '',
            action: ''
          });
        })
        this.list.reverse();
      })

//      let length = await this.$contract.report.getReportsLength();
//      for (var i = 0; i < length; i++) {
//        let report = await this.$contract.report.getReport(i);
//        report.title = JSON.parse(await this.$contract.contentInterface.getRecord(report.content)).title;
//        report.index = i;
//        this.list.push(report);
//      }
    },
    beforeDestroy() {
    }
  }
</script>

<style scoped>

</style>
