<template>
  <div role="group">
    <Account/>
    <hr>
    <UserPaybackPool/>
    <hr>
    <Report/>
  </div>
</template>

<script>
  import Account from './Account'
  import UserPaybackPool from './UserPaybackPool'
  import Report from './Report'

  export default {
    components: {Account, UserPaybackPool, Report},
    data() {
      return {}
    },
    methods: {},
    created() {
    }
  }
</script>

<style scoped>

</style>
