<template>
  <div>
    <b-table striped
             hover
             show-empty
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
             :items="supporters"
             thead-class="text-center"
             tbody-class="text-center"
             :small="true">
      <template slot="user" slot-scope="row">{{row.item.userName}}</template>
      <template slot="investment" slot-scope="row">{{$utils.toPXL(row.item.investment)}} PXL</template>
      <template slot="collection" slot-scope="row">{{$utils.toPXL(row.item.collection)}} PXL</template>
      <template slot="refund" slot-scope="row">{{row.item.refund ? '환불' : '미환불'}}</template>
      <template slot="distributionRate" slot-scope="row">{{$utils.toPXL(row.item.distributionRate) * 100}} %</template>
    </b-table>
    <b-pagination class="d-flex justify-content-center" size="md"
                  :total-rows="supporters.length"
                  v-model="currentPage"
                  :per-page="perPage"
                  :limit="limit">
    </b-pagination>
  </div>
</template>

<script>
  import BigNumber from 'bignumber.js'

  export default {
    props: ['supporters'],
    data() {
      return {
        fields: [
          {key: 'user', label: '참여자'},
          {key: 'investment', label: '투자금액'},
          {key: 'collection', label: '회수금액'},
          {key: 'refund', label: '환불'},
          {key: 'distributionRate', label: '분배비율'},
        ],
        currentPage: 1,
        perPage: 3,
        limit: 7,
      }
    },
    methods: {
    },
    async created() {
    }
  }
</script>

<style scoped>
</style>
