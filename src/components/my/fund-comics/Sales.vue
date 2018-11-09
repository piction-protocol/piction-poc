<template>
  <div>
    <div class="font-size-20 font-weight-bold mb-2">{{$t('매출정보')}}</div>
    <div class="d-flex mb-2">
      <div>
        <div>
          <span class="font-size-24 font-weight-bold">{{sales.totalPurchasedAmount}}</span>
          <span class="font-size-14 text-secondary">PXL</span>
        </div>
        <div class="font-size-14 text-secondary">{{$t('누적총매출')}}</div>
      </div>
      <div class="ml-5">
        <div>
          <span class="font-size-24 font-weight-bold">{{sales.totalPurchasedUserCount}}</span>
          <span class="font-size-14 text-secondary">{{$t('명')}}</span>
        </div>
        <div class="font-size-14 text-secondary">{{$t('구매한독자수')}}</div>
      </div>
    </div>
  </div>
</template>

<script>
  import Sales from '@models/Sales'

  export default {
    props: ['comic_id'],
    data() {
      return {
        sales: new Sales(),
      }
    },
    methods: {},
    async created() {
      this.sales = await this.$contract.apiContents.getComicSales(this.comic_id);
    }
  }
</script>

<style scoped>
</style>