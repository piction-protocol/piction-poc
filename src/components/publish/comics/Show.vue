<template>
  <div>
    <div class="page-title">{{comic.title}}</div>
    <br>
    <b-nav tabs>
      <router-link active-class="active" class="nav-link" :to="{name: 'publish-episodes'}" replace>Episodes
      </router-link>
      <router-link active-class="active" class="nav-link" :to="{name: 'publish-info'}" replace>Info</router-link>
      <router-link active-class="active" class="nav-link" :to="{name: 'publish-supporter'}" replace>Supporter
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
        comic: new Comic()
      }
    },
    methods: {},
    async created() {
      this.comic = await this.$contract.apiContents.getComic(this.comic_id);
    }
  }
</script>

<style scoped>
</style>