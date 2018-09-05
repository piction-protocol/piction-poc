<template>
  <div role="group">
    <Account/>
    <hr>
    <UserPaybackPool/>
  </div>
</template>

<script>
  import Account from './Account'
  import UserPaybackPool from './UserPaybackPool'

  export default {
    components: {Account, UserPaybackPool},
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
