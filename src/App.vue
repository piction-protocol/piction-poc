<template>
  <div id="app">
    <Navi/>
    <transition>
      <router-view class="container" :key="$route.fullPath"/>
    </transition>
  </div>
</template>

<script>
  import Navi from './components/Navi'

  export default {
    name: 'App',
    components: {Navi},
    methods: {
      setEpisodeCreationEvent() {
        this.$contract.apiContents.getContract().events.EpisodeCreation({fromBlock: 'latest'}, async (error, event) => {
          if (event.returnValues._writer.toLowerCase() == this.pictionConfig.account) return;
          let content = await this.$contract.apiContents.getContentsDetail(event.returnValues._contentAddress);
          let title = content.record.title
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
      },
    },
    created() {
      this.setEpisodeCreationEvent();
    }
  }
</script>

<style>
  @import url(https://use.fontawesome.com/releases/v5.4.1/css/all.css);
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

  .pxl-change {
    animation-name: example;
    animation-duration: 5s;
  }

  .page-title {

    font-size: 36px;
    font-weight: bold;
  }

  /* Chrome, Safari, Opera */
  @-webkit-keyframes example {
    0% {
      text-shadow: rgb(255, 255, 255) 0px 0px 30px;
    }
    50% {
      text-shadow: rgb(255, 0, 0) 0px 0px 30px;
    }
    100% {
      text-shadow: rgb(255, 255, 255) 0px 0px 30px;
    }
  }

  /* Standard syntax */
  @keyframes example {
    0% {
      text-shadow: rgb(255, 255, 255) 0px 0px 30px;
    }
    50% {
      text-shadow: rgb(255, 0, 0) 0px 0px 30px;
    }
    100% {
      text-shadow: rgb(255, 255, 255) 0px 0px 30px;
    }
  }

  a {
    color: inherit !important;
  }

  a:hover {
    text-decoration: inherit !important;
  }
</style>
