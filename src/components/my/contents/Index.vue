<template>
  <div>
    <b-nav pills>
      <router-link v-for="content in contents"
                   :key="content.id"
                   active-class="active" class="nav-link"
                   :to="{name: 'show-my-content', params:{content_id: content.id}}"
                   exact>
        {{content.title}}
      </router-link>
    </b-nav>
    <hr>
    <router-view/>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        contents: [],
      }
    },
    methods: {},
    async created() {
      let contents = await this.$contract.apiContents.getWriterContentsList(this.pictionConfig.account);
      this.contents = JSON.parse(web3.utils.hexToUtf8(contents.records_));
      this.contents.forEach((content, i) => {
        content.id = contents.writerContentsAddress_[i];
      });
      if (this.contents.length > 0 && !this.$route.params.content_id) {
        this.$router.replace({name: 'show-my-content', params: {content_id: this.contents[0].id}})
      }
    }
  }
</script>

<style scoped>
</style>
