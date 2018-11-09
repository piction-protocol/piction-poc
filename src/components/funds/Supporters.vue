<template>
  <div>
    <b-table hover
             show-empty
             :empty-text="$t('emptyList')"
             :fields="fields"
             :items="supporters"
             :small="true">
      <template slot="user" slot-scope="row">{{row.item.writer.name}}</template>
      <template slot="investment" slot-scope="row">{{row.item.investment}} PXL</template>
      <template slot="collection" slot-scope="row">{{row.item.collection}} PXL</template>
      <template slot="refund" slot-scope="row">{{row.item.refund ? $t('workd.환불') : $t('workd.미환불')}}</template>
      <template slot="distributionRate" slot-scope="row">
        <div v-b-popover.hover="row.item.distributionRate">
          <div v-if="row.item.distributionRate / parseInt(row.item.distributionRate) > 1">
            {{parseFloat(row.item.distributionRate).toFixed(2)}} %
          </div>
          <div v-else> {{row.item.distributionRate}} % </div>
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
          {key: 'user', label: this.$t('서포터')},
          {key: 'investment', label: this.$t('모금액')},
          {key: 'distributionRate', label: this.$t('수익분배율')},
        ],
      }
    }
  }
</script>

<style scoped>
</style>
