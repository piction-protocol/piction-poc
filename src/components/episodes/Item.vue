<template>
  <div @click="purchase">
    <b-row>
      <b-col cols="3">
        <img :src="episode.thumbnail" class="thumbnail"/>
      </b-col>
      <b-col cols="1" class="d-flex align-items-center">
        <span class="font-weight-bold" style="font-size: 32px;">{{episode.number + 1}}</span>
      </b-col>
      <b-col class="d-flex align-items-center">
        <div>
          <h5 class="mb-2">{{episode.title}}</h5>
          <div v-if="episode.purchased" class="font-weight-bold">구매한 회차입니다.</div>
          <h5 v-if="!episode.purchased && episode.price > 0">
            <b-badge variant="dark">{{$utils.toPXL(episode.price)}} PXL</b-badge>
          </h5>
        </div>
      </b-col>
    </b-row>
    <hr>
  </div>
</template>

<script>
  import index from "../../store/index";

  export default {
    props: ['content_id', 'episode'],
    data() {
      return {}
    },
    methods: {
      show() {
        this.$router.push({name: 'viewer', params: {content_id: this.content_id, episode_id: this.episode.number}});
      },
      async purchase() {
        this.$loading('loading...');
        if (this.episode.purchased || this.episode.price == 0) {
          this.show()
        } else if (confirm(`소장하시겠습니까? (${this.$utils.toPXL(this.episode.price)}PXL)`)) {
          try {
            const content = this.content_id
            const marketer = this.$utils.toHexString(0).substr(2)
            const index = this.$utils.toHexString(this.episode.number, 64).substr(2);
            await this.$contract.pxl.approveAndCall(
              this.pictionConfig.pictionAddress.pixelDistributor,
              this.episode.price,
              `${content}${marketer}${index}`
            );
            this.show();
          } catch (e) {
            alert(e);
          }
        }
        this.$loading.close();
      }
    }
  }
</script>

<style scoped>
  .thumbnail {
    width: 100%;
    max-height: 140px;
    background-position: center;
    background-size: cover;
    background-color: #e8e8e8;
  }
</style>
