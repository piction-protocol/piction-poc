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
    <router-view :key="$route.path"/>
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
      let contents = await this.$contract.contentsManager.getWriterContentsAddress(this.pictionConfig.account);
      contents[0].reverse().asyncForEach(async address => {
        let record = await this.$contract.contentInterface.getRecord(address);
        let content = JSON.parse(record);
        content.id = address;
        await this.contents.push(content);
      });
      if (contents[0].length > 0) {
        this.$router.push({name: 'show-my-content', params: {content_id: contents[0][0]}})
      }
    }
  }
</script>

<style scoped>
</style>
