<template>
  <div class="episode">
    <b-row class="text-left" align-v="center">
      <b-col cols="3"><img :src="episode.thumbnail"/></b-col>
      <b-col>
        <div>{{episode.title}}</div>
        <hr>
        <b-button v-if="!episode.purchased" @click="action" type="submit" variant="primary" class="float-right">
          {{buttonText}}
        </b-button>
      </b-col>
    </b-row>
  </div>
</template>

<script>
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
      action() {
        if (this.episode.purchased) {
          this.$router.push({name: 'viewer', params: {content_id: this.content_id, episode_id: episode.id}});
        } else {
          this.$contract.pxl.approveAndCall(this.content_id, this.$utils.toPXL(this.episode.price), 0);
        }
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
