<template>
  <div>
    <h1>My</h1>
    <div>{{userName}}</div>
  </div>
</template>

<script>
  import source from '../../build/contracts/Account.json'

  export default {
    name: 'My',
    data() {
      return {
        userName: null
      }
    },
    async created() {
      const contract = new web3.eth.Contract(source.abi, source.networks['3'].address);
      this.userName = await contract.methods.getUserName(this.$root.account).call();
    }
  }
</script>

<style scoped>

</style>
