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
      let contents = await this.$contract.contentsManager.getWriterContentsAddress(this.pictionAddress.account);
      contents[0].forEach(async address => {
        await this.$contract.contentInterface.getRecord(address).then(record => {
          let content = JSON.parse(record);
          content.id = address;
          this.contents.push(content);
        });
      });
    }
  }
</script>

<style scoped>
</style>
