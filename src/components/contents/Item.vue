<template>
  <router-link :to="{ name: 'episodes', params: { content_id: content.id }}">
    <b-row style="margin-bottom: 8px">
      <b-col cols="3">
        <img :src="content.thumbnail" class="thumbnail"/>
      </b-col>
      <b-col class="p-3">
        <div>
          <h5 class="font-weight-bold">{{content.title}}</h5>
          <h5 class="mb-3">
            <b-badge variant="success">{{content.genres}}</b-badge>
          </h5>
          <div class="text-secondary font-italic">{{content.writerName}}</div>
        </div>
      </b-col>
    </b-row>
    <hr>
  </router-link>
</template>

<script>
  export default {
    props: ['content'],
    data() {
      return {}
    },
    methods: {}
  }
</script>

<style scoped>
  .thumbnail {
    width: 100%;
    border-radius: 0.5rem;
    background-position: center;
    background-size: cover;
    background-color: #e8e8e8;
  }

  a {
    color: inherit;
  }

  a:hover {
    text-decoration: inherit;
  }
</style>
