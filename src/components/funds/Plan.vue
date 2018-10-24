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
          {key: 'field', label: '항목'},
          {key: 'value', label: '내용'},
        ],
        plan: [
          {field: '목표 모집 금액', value: `${this.$utils.toPXL(this.fund.maxcap)} PXL`},
          {field: '최소 모집 금액', value: `${this.$utils.toPXL(this.fund.softcap)} PXL`},
          {field: '1인당 최소 모금액', value: `${this.$utils.toPXL(this.fund.min)} PXL`},
          {field: '1인당 최대 모금액', value: `${this.$utils.toPXL(this.fund.max)} PXL`},
          {field: '모집 기간', value: `${this.$utils.dateFmt(this.fund.startTime)}<br>~${this.$utils.dateFmt(this.fund.endTime)}`},
          {field: '모금액 작가 수령', value: `${this.fund.poolSize}회 분할, ${this.fund.interval} 간격<br>(1회차: ${this.$utils.dateFmt(this.fund.firstDistributionTime)})`},
          {field: '수익 분배', value: `${this.$utils.toPXL(this.fund.distributionRate) * 100}% / 1PXL<br>(모금액 100% 회수 후)`},
        ]
      }
    }
  }
</script>

<style scoped>
</style>
