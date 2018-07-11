<template>
  <div id="app">
    <Navi/>
    <transition name="fade">
      <router-view class="container" />
    </transition>
  </div>
</template>

<script>
  import Navi from './components/Navi'

  export default {
    name: 'App',
    components: {Navi},
  }
</script>

<style>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    color: #2c3e50;
    margin: 0px auto;
  }

  .container {
    margin: 80px auto 40px auto;
  }
</style>
