<template>
  <div>
    <div>{{title}}</div>
    <img class="preview form-control"
         v-if="thumbnail"
         :src="thumbnail">
    <div>{{synopsis}}</div>
    <div>{{genres}}</div>
    <b-button variant="outline-success" class="my-2 my-sm-0"
              :to="{name:'edit-content', params: { content_id: content_id }}">Edit
    </b-button>
  </div>
</template>

<script>
  export default {
    props: ['content_id'],
    data() {
      return {
        title: null,
        thumbnail: null,
        synopsis: null,
        genres: null,
        thumbnail: null,
      }
    },
    methods: {},
    async created() {
      this.title = await this.$contract.content.getTitle(this.content_id);
      this.thumbnail = await this.$contract.content.getThumbnail(this.content_id);
      this.synopsis = await this.$contract.content.getSynopsis(this.content_id);
      this.genres = await this.$contract.content.getGenres(this.content_id);
    }
  }
</script>

<style scoped>
  .preview {
    width: 240px;
    margin-bottom: 4px;
  }
</style>
