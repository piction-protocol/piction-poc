<template>
  <div>
    <div class="page-title">{{$t('투자관리')}}</div>
    <br>
    <b-row v-for="comic in comics"
           :key="comic.address">
      <b-col>
        <Item :comic="comic"/>
      </b-col>
    </b-row>
  </div>
</template>

<script>
  import Item from './Item'

  export default {
    components: {Item},
    data() {
      return {
        comics: [],
      }
    },
    methods: {},
    async created() {
      const addrs = await this.$contract.accountManager.getSupportComicsAddress(this.pictionConfig.account);
      this.comics = (await this.$contract.apiContents.getComics(this, addrs)).reverse();
    }
  }
</script>

<style scoped>
</style>