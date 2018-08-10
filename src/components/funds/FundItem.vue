<template>
  <router-link :to="{ name: 'episodes', params: { content_id: fund.fund_id }}" class="comic">
    <b-card :title="fund.contentRecord.title"
            :img-src="fund.contentRecord.thumbnail"
            img-alt="Image"
            img-top
            tag="article"
            style="max-width: 20rem;"
            class="mb-2">
      <p class="card-text">
        {{fund.contentRecord.synopsis}}
      </p>
    </b-card>
  </router-link>
</template>

<script>
  export default {
    props: ['fund'],
    data() {
      return {}
    },
    methods: {},
    async created() {
    }
  }
</script>

<style scoped>
  .comic {
    display: inline-block;
    margin: 7px;
  }
</style>
