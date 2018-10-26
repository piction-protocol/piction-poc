<template>
  <div>
    <div class="page-title">{{comic.title}}</div>
    <br>
    <b-nav tabs>
      <router-link active-class="active" class="nav-link" :to="{name: 'publish-episodes'}" replace>Episodes
      </router-link>
      <router-link active-class="active" class="nav-link" :to="{name: 'publish-info'}" replace>Info</router-link>
      <router-link active-class="active" class="nav-link" :to="supporterUrl" replace>Supporter
      </router-link>
    </b-nav>
    <br>
    <router-view/>
  </div>
</template>

<script>
  import Comic from '@models/Comic'

  export default {
    props: ['comic_id'],
    data() {
      return {
        comic: new Comic(),
        supporterUrl: {},
      }
    },
    methods: {
      async setLink() {
        const address = await this.$contract.apiFund.getFundAddress(this.comic_id);
        if (address) {
          this.supporterUrl = {name: 'publish-show-supporter', params: {fund_id: address}};
        } else {
          this.supporterUrl = {name: 'publish-new-supporter'};
        }
      }
    },
    async created() {
      this.comic = await this.$contract.apiContents.getComic(this.comic_id);
      await this.setLink();
    }
  }
</script>

<style scoped>
</style>