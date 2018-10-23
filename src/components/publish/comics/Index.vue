<template>
  <div>
    <div v-if="comics.length > 0" class="page-title">만화 작품 관리</div>
    <br>
    <b-row v-for="comic in comics"
           :key="comic.address">
      <b-col>
        <Item :comic="comic"/>
      </b-col>
    </b-row>
    <div align="center">
      <div v-if="myDeposit == 0">
        <div class="title">작품을 등록하기 위해서는 <b>작품 등록 예치금</b>이 필요합니다.</div>
        <div class="title">정상적인 작품이 확인되는 경우 예치금은 환급받을 수 있습니다.</div>
        <b-button variant="outline-secondary mt-2" @click="deposit">{{$utils.toPXL(initialDeposit)}} PXL 예치하기</b-button>
      </div>
      <div v-else>
        <div v-if="comics.length == 0" class="title">등록된 작품이 없습니다. 새 작품을 등록해주세요.</div>
        <b-button variant="outline-secondary mt-2" @click="newComic">새 만화 작품 등록하기</b-button>
      </div>
    </div>
  </div>
</template>

<script>
  import Item from './Item'
  import BigNumber from 'bignumber.js'

  export default {
    components: {Item},
    data() {
      return {
        comics: [],
        myDeposit: 0,
        initialDeposit: 0,
        pxl: 0
      }
    },
    methods: {
      async setDeposit() {
        this.myDeposit = BigNumber(await this.$contract.apiContents.getInitialDeposit(this.pictionConfig.account));
        this.initialDeposit = BigNumber(this.pictionConfig.pictionValue.initialDeposit);
        this.pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
      },
      newComic() {
        this.$router.push({name: 'publish-new-comic'});
      },
      async deposit() {
        let loader = this.$loading.show();
        if (this.initialDeposit > this.pxl) {
          alert(`예치금 ${this.initialDeposit} PXL 이 필요합니다.`)
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
      this.comics = await this.$contract.apiContents.getMyComics(this);
      this.setDeposit();
    }
  }
</script>

<style scoped>
  .title {
    font-size: 24px;
  }
</style>