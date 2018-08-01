<template>
  <div>
    <ContentItem v-for="content in contents"
                 :content="content"
                 :key="content.id"/>
  </div>
</template>

<script>
  import ContentItem from './ContentItem'

  export default {
    components: {ContentItem},
    data() {
      return {
        contents: [],
      }
    },
    methods: {},
    async created() {
      let contents = await this.$contract.contentsManager.getContents();
      contents.forEach(async address => {
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
  div {
    text-align: center;
  }
</style>
