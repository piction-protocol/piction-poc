<template>
  <div>
    <h1>My</h1>
    <div>{{userName}}</div>
  </div>
</template>

<script>
  export default {
    name: 'My',
    data() {
      return {
        userName: null
      }
    },
    async created() {
      this.userName = await this.$contract.account.getUserName(this.$root.account);
    }
  }
</script>

<style scoped>

</style>
