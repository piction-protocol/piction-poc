<template>
  <div>
    <img v-for="cut in cuts" :src="cut"/>
    <router-link class="back" :to="{ name: 'episodes', params: { content_id: content_id }}">목록으로</router-link>
  </div>
</template>

<script>
  export default {
    props: ['content_id', 'episode_id'],
    data() {
      return {
        cuts: [],
      }
    },
    methods: {},
    async created() {
      let cuts = await this.$contract.contentInterface.getEpisodeCuts(this.content_id, this.episode_id);
      this.cuts = JSON.parse(cuts);
    }
  }
</script>

<style scoped>
  div {
    text-align: center;
  }

  .back {
    background: black;
    color: white;
    margin: 0;
    padding: 0;
    position: fixed;
    left: 0;
    right: 0;
    height: 3rem;
    line-height: 3rem;
    bottom: 0;
  }
</style>
