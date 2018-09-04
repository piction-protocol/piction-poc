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
  import index from "../../store/index";

  export default {
    props: ['content_id', 'episode'],
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
        this.$router.push({name: 'viewer', params: {content_id: this.content_id, episode_id: this.episode.number}});
      },
      async purchase() {
        this.$loading('loading...');
        try {
          const cd = this.pictionAddress.account;
          const content = this.content_id.substr(2)
          const marketer = this.$utils.toHexString(0).substr(2)
          const index = this.$utils.toHexString(this.episode.number, 64).substr(2);
          await this.$contract.pxl.approveAndCall(
            this.pictionAddress.pixelDistributor,
            this.episode.price,
            `${cd}${content}${marketer}${index}`
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
