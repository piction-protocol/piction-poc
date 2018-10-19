<template>
  <div @click="purchase" class="item">
    <div class="d-flex">
      <img :src="episode.thumbnail" class="thumbnail"/>
      <div class="d-flex align-items flex-column p-3 overflow-hidden">
        <div class="title-text h-50">{{episode.title}}</div>
        <div class="purchase-info-text h-50">
          {{!my && episode.isPurchased ? '구매완료' : $utils.toPXL(episode.price) + 'PXL'}}
        </div>
      </div>
      <div class="ml-auto p-2 d-flex align-items-end flex-column">
        <div class="h-75">
          <i v-if="my" class="ml-2 fas fa-edit"
             v-on:click.stop="updateEpisode"
             v-b-tooltip.hover :title="`회차수정`"></i></div>
        <div class="h-25">#{{episode.number}}</div>
      </div>
    </div>
  </div>
</template>

<script>
  import index from "../../store/index";

  export default {
    props: ['comic', 'episode', 'my'],
    data() {
      return {}
    },
    methods: {
      show() {
        this.$router.push({
          name: 'show-episode',
          params: {comic_id: this.comic.address, episode_id: this.episode.key}
        });
      },
      updateEpisode(evt) {
        evt.preventDefault();
        this.$router.push({
          name: 'edit-episode',
          params: {comic_id: this.comic.address, episode_id: this.episode.key}
        });
      },
      async purchase() {
        let loader = this.$loading.show();
        if (this.episode.purchased) {
          this.show()
        } else if (confirm(`소장하시겠습니까? (${this.$utils.toPXL(this.episode.price)}PXL)`)) {
          try {
            const comic = this.comic.address;
            const key = this.$utils.toHexString(this.episode.key, 64).substr(2);
            await this.$contract.pxl.approveAndCall(
              this.pictionConfig.pictionAddress.pixelDistributor,
              this.episode.price,
              `${comic}${key}`
            );
            this.show();
          } catch (e) {
            alert(e);
          }
        }
        loader.hide();
      }
    }
  }
</script>

<style scoped>
  .title-text {
    font-size: 16px;
    font-weight: bold;
    line-height: 200%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .purchase-info-text {
    font-size: 14px;
    color: #4a4a4a;
    line-height: 200%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .number-text {
    font-size: 14px;
    color: #9b9b9b;
  }

  .thumbnail {
    width: 100px;
    height: 100px;
    background-position: center;
    background-size: cover;
    background-color: #e8e8e8;
  }

  .item {
    padding: 0px;
    border: 1px dotted #979797;
  }
</style>
