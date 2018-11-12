<template>
  <div id="app">
    <Navi/>
    <transition name="fade"
                mode="out-in">
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
      // TODO: 회차 등록 이벤트 처리
//      setEpisodeCreationEvent() {
//        this.$contract.apiContents.getContract().events.EpisodeCreation({fromBlock: 'latest'}, async (error, event) => {
//          if (event.returnValues._writer.toLowerCase() == this.pictionConfig.account) return;
//          let content = await this.$contract.apiContents.getContentsDetail(event.returnValues._contentAddress);
//          let title = content.record.title
//          this.$toasted.show(`"${title}" 작품의 신규 회차가 등록되었습니다`, {
//            action: {
//              text: '이동',
//              onClick: (e, toastObject) => {
//                toastObject.goAway(0);
//                this.$router.push({'name': 'episodes', params: {'content_id': event.returnValues._contentAddress}});
//              }
//            }
//          });
//        })
//      },
    },
    async created() {
      if (this.$store.getters.isLoggedIn) {
        const result = await this.$contract.accountManager.getUserName(this.pictionConfig.account);
        if (!result.result_) {
          this.$store.dispatch('LOGOUT');
          window.location.reload();
        }
      }
//      this.setEpisodeCreationEvent();
    }
  }
</script>

<style lang="sass">
  @import "https://use.fontawesome.com/releases/v5.4.1/css/all.css"
  @import "http://fonts.googleapis.com/earlyaccess/nanumgothic.css"

  #app
    font-family: 'Nanum Gothic', Helvetica, Arial, sans-serif
    -webkit-font-smoothing: antialiased
    -moz-osx-font-smoothing: grayscale
    color: #2c3e50
    margin: 0px auto

  .container
    margin: 80px auto 40px auto

  .pxl-change
    animation-name: example
    animation-duration: 5s

  .page-title
    font-size: 36px
    font-weight: bold

  .overflow-hidden
    overflow: hidden

  .vld-overlay
    z-index: 9999 !important

  @for $i from 10 through 40
    .font-size-#{$i}
      font-size: #{$i}px

  /* Chrome, Safari, Opera */
  @-webkit-keyframes example
    0%
      text-shadow: rgb(255, 255, 255) 0px 0px 30px
    50%
      text-shadow: rgb(255, 0, 0) 0px 0px 30px
    100%
      text-shadow: rgb(255, 255, 255) 0px 0px 30px

  /* Standard syntax */
  @keyframes example
    0%
      text-shadow: rgb(255, 255, 255) 0px 0px 30px
    50%
      text-shadow: rgb(255, 0, 0) 0px 0px 30px
    100%
      text-shadow: rgb(255, 255, 255) 0px 0px 30px

  a
    color: inherit !important

  a:hover
    text-decoration: inherit !important

  .fade-enter-active,
  .fade-leave-active
    transition-duration: 0.2s
    transition-property: opacity
    transition-timing-function: ease

  .fade-enter, .fade-leave-active
    opacity: 0
</style>
