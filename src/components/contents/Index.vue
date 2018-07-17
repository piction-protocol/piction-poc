<template>
  <div>
    <ContentItem v-for="content in contents"
           :content="content"
           :key="content.id"/>
  </div>
</template>

<script>
  import ContentItem from './ContentItem'

  export default {
    components: {ContentItem},
    data() {
      return {
        contents: [],
      }
    },
    methods: {},
    created() {
      Array(20).fill().forEach((obj, index) => {
        let id = index + 1;
        let content = {
          id: id,
          title: `Comic ${id}`,
          thumbnail: `http://images.battlecomics.co.kr/webtoon/677/image/image-webtoonid_677-w_720-h_360-t_20171108144640.jpg`,
          description: `Description ${id}`,
          writer: `skkwon`
        }
        this.contents.push(content);
      });
    }
  }
</script>

<style scoped>
  div {
    text-align: center;
  }
</style>
