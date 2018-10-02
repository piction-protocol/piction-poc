<template>
  <div id="app">
    <Navi/>
    <transition name="fade">
      <router-view class="container" :key="$route.name + JSON.stringify($route.params)"/>
    </transition>
  </div>
</template>

<script>
  import Navi from './components/Navi'

  export default {
    name: 'App',
    components: {Navi},
    created() {
      this.$contract.apiContents.getContract().events.EpisodeCreation({fromBlock: 'latest'}, async (error, event) => {
        if (event.returnValues._writer.toLowerCase() == this.pictionConfig.account) return;
        let content = await this.$contract.apiContents.getContentsDetail(event.returnValues._contentAddress);
        let title = JSON.parse(content.record_).title
        this.$toasted.show(`"${title}" 작품의 신규 회차가 등록되었습니다`, {
          action: {
            text: '이동',
            onClick: (e, toastObject) => {
              toastObject.goAway(0);
              this.$router.push({'name': 'episodes', params: {'content_id': event.returnValues._contentAddress}});
            }
          }
        });
      })
    }
  }
</script>

<style>
  @import url(http://fonts.googleapis.com/earlyaccess/nanumgothic.css);

  #app {
    font-family: 'Nanum Gothic', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    color: #2c3e50;
    margin: 0px auto;
  }

  .container {
    margin: 80px auto 40px auto;
  }
</style>
