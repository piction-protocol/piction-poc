<template>
  <div>
    <b-table hover
             show-empty
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
             :items="supporters"
             :small="true">
      <template slot="user" slot-scope="row">{{row.item.writer.name}}</template>
      <template slot="investment" slot-scope="row">{{row.item.investment}} PXL</template>
      <template slot="collection" slot-scope="row">{{row.item.collection}} PXL</template>
      <template slot="refund" slot-scope="row">{{row.item.refund ? '환불' : '미환불'}}</template>
      <template slot="distributionRate" slot-scope="row">
        <div v-b-popover.hover="row.item.distributionRate">
          <div v-if="row.item.distributionRate / parseInt(row.item.distributionRate) > 1" > {{parseFloat(row.item.distributionRate).toFixed(2)}} % </div>
          <div v-else > {{row.item.distributionRate}} % </div>
        </div>
      </template>
    </b-table>
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
          {key: 'investment', label: '모금액'},
          {key: 'distributionRate', label: '수익 분배율'},
        ],
      }
    }
  }
</script>

<style scoped>
</style>
