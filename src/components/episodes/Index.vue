<template>
  <div>
    <b-breadcrumb :items="items"/>
    <b-button variant="danger" size="sm" @click="report">report</b-button>
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
          text: 'Comics',
          to: {name: 'contents'}
        }]
      }
    },
    methods: {
      updatePXL: async function () {
        let pxl = await this.$contract.pxl.balanceOf(this.pictionAddress.account);
        this.pxl = this.$utils.toPXL(pxl);
      },
      async report() {
        this.$loading('loading...');
        let regFee = await this.$contract.report.getRegFee();
        console.log(regFee)
        let deposit = BigNumber(regFee[0]);
        let initialDeposit = BigNumber(this.pictionValue.reportRegistrationFee);
        let pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionAddress.account));
        let message = `Initial deposit ${this.$utils.toPXL(initialDeposit)} PXL is required to report content.`;
        if (deposit.gt(BigNumber(0))) {
          let reason = prompt("What is the reason for your report?", "");
          await this.$contract.report.sendReport(this.content_id, reason);
        } else if (pxl.lt(initialDeposit)) {
          alert(message)
        } else if (confirm(`${message}\nWould you like to register?`)) {
          await this.$contract.pxl.approveAndCall(this.pictionAddress.report, initialDeposit);
          this.updatePXL();
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
      Array(Number(length)).fill().forEach(async (i, index) => {
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
