<template>
  <div>
    <b-row style="margin-bottom: 8px">
      <b-col cols="6">
        <img :src="content.thumbnail" class="thumbnail"/>
      </b-col>
      <b-col cols="6">
        <div class="d-flex align-items flex-column">
          <h2 class="font-weight-bold mb-1">{{content.title}}</h2>
          <div class="text-secondary font-italic mb-4">{{writerName}}</div>
          <p>{{content.synopsis}}</p>
          <div class="mt-auto align-items-end">
            <b-button v-if="!my" variant="danger" @click="report" size="sm" class="float-right ml-2">신고하기</b-button>
            <b-button v-if="my" variant="primary" @click="updateContent" size="sm" class="float-right ml-2">작품수정
            </b-button>
            <b-button v-if="my" variant="primary" @click="addEpisode" size="sm" class="float-right ml-2">회차등록</b-button>
          </div>
        </div>
      </b-col>
    </b-row>
    <div class="clearfix"/>
    <hr>
    <b-row>
      <b-col cols="6">
        <div>총 {{episodes.length}}화</div>
      </b-col>
      <b-col cols="6" align="right">
        <b-button variant="outline-primary" @click="sort" size="sm">정렬변경</b-button>
      </b-col>
    </b-row>
    <hr>
    <Item v-for="episode in episodes"
          :episode="episode"
          :content_id="content_id"
          :my="my"
          :key="episode.number"/>
  </div>
</template>

<script>
  import Item from './Item'
  import {BigNumber} from 'bignumber.js';

  export default {
    props: ['content_id'],
    components: {Item},
    data() {
      return {
        content: {},
        writer: '',
        writerName: '',
        episodes: [],
      }
    },
    computed: {
      my: function () {
        return this.writer.toLocaleLowerCase() == this.pictionConfig.account;
      }
    },
    methods: {
      updateContent() {
        this.$router.push({name: 'edit-content', params: {'content_id': this.content_id}});
      },
      setEvent() {
        this.$contract.apiContents.setEpisodeCreation((error, event) => {
          if (this.content_id.toLocaleLowerCase() != event.returnValues._contentAddress.toLocaleLowerCase()) return;
          var record = JSON.parse(event.returnValues._record);
          record.number = event.returnValues._episodeIndexId;
          record.buyCount = 0;
          record.purchased = false;
          record.price = event.returnValues._price;
          this.episodes.sort((a, b) => b.number - a.number);
          this.episodes.splice(0, 0, record);
        });
      },
      sort() {
        this.episodes = this.episodes.reverse();
      },
      addEpisode() {
        this.$router.push({name: 'new-episode', params: {content_id: this.content_id}})
      },
      async report() {
        this.$loading('loading...');
        let registrationInfo = await this.$contract.apiReport.getRegistrationAmount();
        let deposit = BigNumber(registrationInfo.amount_);
        let initialDeposit = BigNumber(this.pictionConfig.pictionValue.reportRegistrationFee);
        let pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
        let message = `신고를 하려면 예치금 ${this.$utils.toPXL(initialDeposit)} PXL 이 필요합니다.`;
        if (deposit.gt(BigNumber(0))) {
          let reason = prompt("신고 사유를 입력하세요.", "");
          if (reason) {
            await this.$contract.apiReport.sendReport(this.content_id, reason);
          } else {
            alert("신고 사유가 입력되지 않았습니다.")
          }
        } else if (pxl.lt(initialDeposit)) {
          alert(message)
        } else if (confirm(`${message}\n등록하시겠습니까?`)) {
          await this.$contract.pxl.approveAndCall(this.pictionConfig.pictionAddress.report, initialDeposit);
          this.report();
        }
        this.$loading.close();
      },
      async setContentDetail() {
        const contentDetail = await this.$contract.apiContents.getContentsDetail(this.content_id);
        this.content = JSON.parse(contentDetail.record_);
        this.writer = contentDetail.writer_;
        this.writerName = contentDetail.writerName_;
      },
      async loadList() {
        const result = await this.$contract.apiContents.getEpisodeFullList(this.content_id);
        if (!result.episodeRecords_) return;
        let records = JSON.parse(web3.utils.hexToUtf8(result.episodeRecords_));
        records.forEach((record, i) => {
          record.number = i;
          record.buyCount = result.buyCount_[i];
          record.purchased = result.isPurchased_[i];
          record.price = result.price_[i];
        });
        this.episodes = records.reverse();
      }
    },
    async created() {
      this.setEvent();
      this.setContentDetail();
      this.loadList();
    }
  }
</script>

<style scoped>
  .thumbnail {
    width: 100%;
    border-radius: 0.5rem;
    background-position: center;
    background-size: cover;
    background-color: #e8e8e8;
  }
</style>
