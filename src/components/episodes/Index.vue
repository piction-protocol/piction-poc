<template>
  <div>
    <b-breadcrumb :items="items"/>
    <b-button variant="danger" @click="report" size="sm" style="float: right">신고</b-button>
    <div class="clearfix"/>
    <hr>
    <Item v-for="episode in episodes"
          :episode="episode"
          :content_id="content_id"
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
        content: null,
        episodes: [],
        items: [{
          text: '작품목록',
          to: {name: 'contents'}
        }]
      }
    },
    methods: {
      async report() {
        this.$loading('loading...');
        let registrationInfo = await this.$contract.apiReport.getRegistrationAmount();
        let deposit = BigNumber(registrationInfo.amount_);
        let initialDeposit = BigNumber(this.pictionConfig.pictionValue.reportRegistrationFee);
        let pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
        let message = `신고를 하려면 예치금 ${this.$utils.toPXL(initialDeposit)} PXL 이 필요합니다.`;
        if (deposit.gt(BigNumber(0))) {
          let reason = prompt("신고 사유를 입력하세요.", "");
          if(reason) {
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
      }
    },
    async created() {
      await this.$contract.contentInterface.getRecord(this.content_id).then(record => {
        this.content = JSON.parse(record);
      });
      this.items.push({text: `${this.content.title}`, active: true});

      let length = await this.$contract.contentInterface.getEpisodeLength(this.content_id);
      Array(Number(length)).fill().reverse().asyncForEach(async (i, index) => {
        let result = await this.$contract.contentInterface.getEpisodeDetail(this.content_id, index);
        let episodeRecord = JSON.parse(result[0])
        let price = Number(result[1]);
        let purchased = Number(result[3]);
        let episode = {
          number: index,
          title: episodeRecord.title,
          thumbnail: episodeRecord.thumbnail,
          price: price,
          purchased: purchased,
        }
        this.episodes.push(episode);
      });
    }
  }
</script>

<style scoped>

</style>
