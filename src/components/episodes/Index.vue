<template>
  <div>
    <b-breadcrumb :items="items"/>
    <Item v-for="(episode, index) in episodes"
          :episode="episode"
          :content_id="content_id"
          :index="index"
          :key="index"/>
  </div>
</template>

<script>
  import Item from './Item'

  export default {
    props: ['content_id'],
    components: {Item},
    data() {
      return {
        content: null,
        episodes: [],
        items: [{
          text: 'Comics',
          to: {name: 'contents'}
        }]
      }
    },
    methods: {},
    async created() {
      await this.$contract.contentInterface.getRecord(this.content_id).then(record => {
        this.content = JSON.parse(record);
      });
      this.items.push({text: `${this.content.title}`, active: true});

      let length = await this.$contract.contentInterface.getEpisodeLength(this.content_id);
      Array(Number(length)).fill().forEach(async (i, index) => {
        let result = await this.$contract.contentInterface.getEpisodeDetail(this.content_id, index);
        let episodeRecord = JSON.parse(result[0])
        let price = Number(result[1]);
        let purchased = Number(result[3]);
        let episode = {
          title: episodeRecord.title,
          thumbnail: episodeRecord.thumbnail,
          price: price,
          purchased: purchased,
        }
        this.episodes.push(episode);
      });
    }
  }
</script>

<style scoped>

</style>
