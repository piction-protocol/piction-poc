<template>
  <div>
    <div v-if="comics.length > 0" class="page-title">{{$t('만화작품관리')}}</div>
    <br>
    <b-row v-for="comic in comics"
           :key="comic.address">
      <b-col>
        <Item :comic="comic"/>
      </b-col>
    </b-row>
    <div align="center">
      <div v-if="myDeposit == 0">
        <div class="title" v-html="$t('publishInitialDepositText')"></div>
        <b-button variant="outline-secondary mt-2" @click="deposit">{{$t('publishInitialDepositButton', {amount: web3.utils.fromWei(initialDeposit)})}}</b-button>
      </div>
      <div v-else>
        <div v-if="comics.length == 0" class="title">{{$t('publishEmptyContentsText')}}</div>
        <b-button variant="outline-secondary mt-2" @click="newComic">{{$t('publishEmptyContentsButton')}}</b-button>
      </div>
    </div>
  </div>
</template>

<script>
  import Item from './Item'

  export default {
    components: {Item},
    data() {
      return {
        comics: [],
        myDeposit: new web3.utils.BN('0'),
        initialDeposit: new web3.utils.BN('0'),
        pxl: new web3.utils.BN('0')
      }
    },
    methods: {
      async setDeposit() {
        this.myDeposit = new web3.utils.BN(await this.$contract.apiContents.getInitialDeposit(this.pictionConfig.account));
        this.initialDeposit = new web3.utils.BN(String(this.pictionConfig.pictionValue.initialDeposit));
        this.pxl = new web3.utils.BN(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
      },
      newComic() {
        this.$router.push({name: 'publish-new-comic'});
      },
      async deposit() {
        let loader = this.$loading.show();
        if (this.initialDeposit > this.pxl) {
          alert(this.$t('checkInitialDeposit', {amount: this.web3.utils.fromWei(this.initialDeposit)}));
          loader.hide();
          return;
        }
        try {
          await this.$contract.pxl.approveAndCall(this.pictionConfig.managerAddress.contentsManager, this.pictionConfig.pictionValue.initialDeposit);
          this.setDeposit();
        } catch (e) {
          alert(e)
        }
        loader.hide();
      }
    },
    async created() {
      this.comics = (await this.$contract.apiContents.getMyComics(this)).reverse();
      this.setDeposit();
    }
  }
</script>

<style scoped>
  .title {
    font-size: 24px;
  }
</style>