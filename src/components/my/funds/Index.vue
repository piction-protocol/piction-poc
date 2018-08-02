<template>
  <div>
    <FundItem v-for="content in contents"
                 :content="content"
                 :key="content.id"/>
  </div>
</template>

<script>
  import FundItem from './FundItem'

  export default {
    components: {FundItem},
    data() {
      return {
        contents: [],
      }
    },
    methods: {},
    async created() {
      let contents = await this.$contract.contentsManager.getWriterContentsAddress(this.$root.account);
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
