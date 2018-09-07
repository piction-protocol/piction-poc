<template>
  <div>
    <b-row style="margin-bottom: 8px">
      <b-col cols="3">
        <img :src="episode.thumbnail" class="thumbnail"/>
      </b-col>
      <b-col style="padding: 15px">
        <h5>{{episode.title}}</h5>
        <b-button size="sm" @click="episode.purchased ? view() : purchase()"
                  :variant="episode.purchased ? 'outline-primary' : 'primary'"
                  style="width: 200px; float: right">
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
        return this.episode.purchased ? '소장중' : `${this.$utils.toPXL(this.episode.price)} PXL 소장하기`;
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
  .thumbnail {
    width: 100%;
    max-height: 140px;
    border-radius: 0.5rem;
    background-position: center;
    background-size: cover;
    background-color: #e8e8e8;
  }
</style>
