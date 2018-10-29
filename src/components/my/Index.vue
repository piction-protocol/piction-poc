<template>
  <div>
    <b-nav tabs>
      <router-link active-class="active" class="nav-link" :to="{name: 'account'}" exact>내 정보</router-link>
      <router-link active-class="active" class="nav-link" :to="{name: 'payback-pool'}" exact>작품 구매 보상</router-link>
      <router-link active-class="active" class="nav-link" :to="{name: 'my-reports'}" exact>신고 처리 내역</router-link>
      <router-link active-class="active" class="nav-link" :to="{name: 'my-contents'}">내 작품</router-link>
    </b-nav>
    <br>
    <router-view/>
  </div>
</template>

<script>
  export default {
    data() {
      return {}
    },
    methods: {},
    created() {
    }
  }
</script>

<style scoped>

</style>
