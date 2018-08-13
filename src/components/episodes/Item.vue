<template>
  <div class="episode">
    <b-row class="text-left" align-v="center">
      <b-col cols="3"><img :src="episode.thumbnail"/></b-col>
      <b-col>
        <div>{{episode.title}}</div>
        <b-button @click="episode.purchased ? view() : purchase()" variant="primary" class="float-right">
          {{buttonText}}
        </b-button>
      </b-col>
    </b-row>
    <hr>
  </div>
</template>

<script>
  export default {
    props: ['content_id', 'episode', 'index'],
    computed: {
      buttonText() {
        return this.episode.purchased ? 'view' : `${this.$utils.toPXL(this.episode.price)} PXL`;
      }
    },
    data() {
      return {}
    },
    methods: {
      view() {
        this.$router.push({name: 'viewer', params: {content_id: this.content_id, episode_id: this.index}});
      },
      async purchase() {
        this.$loading('loading...');
        try {
          await this.$contract.pxl.purchase(
            this.pictionAddress.pixelDistributor,
            this.episode.price,
            [this.pictionAddress.account, this.content_id, 0],
            this.index
          );
        } catch (e) {
          alert(e);
        }
        this.$router.go(this.$router.path)
      }
    }
  }
</script>

<style scoped>
  img {
    width: 100%;
  }

  .episode {
    display: block;
    padding: 2px;
  }
</style>
