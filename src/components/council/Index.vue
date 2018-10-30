<template>
  <div>
    <div class="row">
      <div class="col-6 col-md-4">
        <div class="page-title">위원회</div>
      </div>
      <div class="col-12 col-sm-6 col-md-8">
        <div class="radio">
          <b-form-radio-group v-model="selected" :options="options"/>
        </div>
      </div>
    </div>
    <br>
    <br>
    <b-row>
      <b-col cols="12" sm="6" md="4" lg="3"
             v-for="comic in filteredComics"
             :key="comic.address">
        <Item :comic="comic"/>
      </b-col>
    </b-row>
  </div>
</template>

<script>
  import Item from './Item'
  import Comic from '@models/CouncilComic'
  import Web3Utils from '@utils/Web3Utils'

  export default {
    components: {Item},
    computed: {
      filteredComics() {
        //todo 아래 미처리 숫자 및 최근 리포트 타임별 정렬처리
        if (this.selected == 'first') {
          return this.comics.sort((a, b) => a.createdAt - b.createdAt);
        } else {
          return this.comics.sort((a, b) => b.createdAt - a.createdAt);
        }
      }
    },
    data() {
      return {
        comics: [],
        selected: 'first',
        options: [
        { text: '최근 신고 순', value: 'first' },
        { text: '대기 중인 신고수 순', value: 'second' }
      ]
      }
    },
    methods: {
      async setComics() {
        let comics = await this.$contract.apiContents.getComics(this);
        //todo getCouncilCoimcs 만들고 미처리 숫자 및 최근 리포트 타임을 넣는다
        this.comics = comics.reverse();
      },
    },
    async created() {
      this.setComics();
    }
  }
</script>

<style scoped>
  .radio {
    text-align: right;
  }
</style>