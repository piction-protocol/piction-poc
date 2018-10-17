<template>
  <div @click="purchase" class="item">
    <div class="d-flex">
      <img :src="episode.thumbnail" class="thumbnail"/>
      <div class="d-flex align-items flex-column p-3 overflow-hidden">
        <div class="title-text h-50">{{episode.title}}</div>
        <div class="purchase-info-text h-50">
          {{!my && episode.purchased ? '구매완료' : $utils.toPXL(episode.price) + 'PXL'}}
        </div>
      </div>
      <div class="ml-auto p-2 d-flex align-items-end flex-column">
        <div class="h-75">
          <i v-if="my" class="ml-2 fas fa-edit"
             v-on:click.stop="updateEpisode"
             v-b-tooltip.hover :title="`회차수정`"></i></div>
        <div class="h-25">#{{Number(episode.number) + 1}}</div>
      </div>
    </div>
  </div>
</template>

<script>
  import index from "../../store/index";

  export default {
    props: ['content_id', 'episode', 'my'],
    data() {
      return {}
    },
    methods: {
      show() {
        this.$router.push({
          name: 'show-episode',
          params: {content_id: this.content_id, episode_id: this.episode.number}
        });
      },
      updateEpisode(evt) {
        console.log(evt)
        evt.preventDefault();
        this.$router.push({
          name: 'edit-episode',
          params: {content_id: this.content_id, episode_id: this.episode.number}
        });
      },
      async purchase() {
        this.$loading('loading...');
        if (this.episode.purchased) {
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
