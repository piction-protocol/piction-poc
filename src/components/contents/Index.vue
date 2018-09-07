<template>
  <div>
    <Item v-for="content in contents"
          :content="content"
          :key="content.id"/>
  </div>
</template>

<script>
  import Item from './Item'

  export default {
    components: {Item},
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
  }
</style>
