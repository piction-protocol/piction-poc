<template>
  <div>
    <b-breadcrumb :items="items"/>
    <EpisodeItem v-for="episode in episodes"
                 :episode="episode"
                 :content_id="content_id"
                 :key="episode.id"/>
  </div>
</template>

<script>
  import EpisodeItem from './EpisodeItem'

  export default {
    props: ['content_id'],
    components: {EpisodeItem},
    data() {
      return {
        episodes: [],
        items: [{
          text: 'Comics',
          to: {name: 'contents'}
        }, {
          text: `Comic ${this.content_id}`,
          active: true
        }]
      }
    },
    methods: {},
    async created() {
      let length = await this.$contract.contentInterface.getEpisodeLength(this.content_id);
      Array(Number(length)).fill().forEach(async (i, index) => {
        let result = await this.$contract.contentInterface.getEpisodeDetail(this.content_id, index);
        let episodeRecord = JSON.parse(result[0])
        let price = Number(result[1]);
        let purchased = Number(result[3]);
        let episode = {
          id: index + 1,
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
