<template>
  <div>
    세부정보
  </div>
</template>

<script>
  import Comic from '@models/Comic'

  export default {
    data() {
      return {
        comic: new Comic()
      }
    },
    methods: {},
    async created() {
      this.comic = this.$parent.comic;
    }
  }
</script>

<style scoped>

</style>
