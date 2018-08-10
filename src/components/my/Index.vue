<template>
  <div>
    <b-nav tabs>
      <router-link active-class="active" class="nav-link" to="/my" exact>Info</router-link>
      <router-link active-class="active" class="nav-link" to="/my/contents" exact>Contents</router-link>
    </b-nav>
    <br>
    <router-view/>
  </div>
</template>

<script>
  export default {
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
