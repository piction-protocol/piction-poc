<template>
  <div>
    <b-table hover
             :fields="fields"
             :items="plan"
             :small="true">
      <template slot="field" slot-scope="row">
        <div class="font-weight-bold" v-html="row.item.field"></div>
      </template>
      <template slot="value" slot-scope="row">
        <div v-html="row.item.value"></div>
      </template>
    </b-table>
  </div>
</template>

<script>
  export default {
    props: ['fund'],
    data() {
      return {
        fields: [
          {key: 'field', label: this.$t('항목')},
          {key: 'value', label: this.$t('내용')},
        ],
        plan: [
          {field: this.$t('목표모집금액'), value: `${this.fund.maxcap} PXL`},
          {field: this.$t('최소모집금액'), value: `${this.fund.softcap} PXL`},
          {field: this.$t('1인당최소모금액'), value: `${this.fund.min} PXL`},
          {field: this.$t('1인당최대모금액'), value: `${this.fund.max} PXL`},
          {
            field: this.$t('모집기간'),
            value: `${this.$utils.dateFmt(this.fund.startTime)}<br>~${this.$utils.dateFmt(this.fund.endTime)}`
          },
          {
            field: this.$t('모금액작가수령'),
            value: `${this.fund.poolSize}${this.$t('회분할')}, ${this.fund.interval / (1000 * 60 * 60)}${this.$t('시간간격')}<br>(${this.$t('1회차')}: ${this.$utils.dateFmt(this.fund.firstDistributionTime)})`
          },
          {field: this.$t('수익분배'), value: `${web3.utils.fromWei((web3.utils.toWei((this.fund.distributionRate).toString()) * 100).toString())}% / 1PXL<br>${this.$t('distributionOfProfits')}`},
        ]
      }
    }
  }
</script>

<style scoped>
</style>
