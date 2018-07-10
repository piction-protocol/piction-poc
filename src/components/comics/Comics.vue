<template>
  <div>
    <Comic v-for="comic in comics"
           :comic="comic"
           :key="comic.id"/>
  </div>
</template>

<script>
  import Comic from './Comic'

  export default {
    name: 'Comics',
    components: {Comic},
    data() {
      return {
        comics: [],
      }
    },
    methods: {},
    created() {
      Array(20).fill().forEach((obj, index) => {
        let id = index + 1;
        let comic = {
          id: id,
          title: `Comic ${id}`,
          thumbnail: `http://images.battlecomics.co.kr/webtoon/677/image/image-webtoonid_677-w_720-h_360-t_20171108144640.jpg`,
          description: `Description ${id}`,
          writer: `skkwon`
        }
        this.comics.push(comic);
      });
    }
  }
</script>

<style scoped>

</style>
