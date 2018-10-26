<template>
    <div>
        <div class="page-title">신고 처리 내역</div>
        <br>
        <div align="center">
            <div v-if="true">
                <div class="title">신고 권한을 획득하시려면 <b>신고 예치금</b>이 필요합니다.</div>
                <div class="title">신고 예치금 예치 후 30일 간 신고 권한이 부여되며,</div>
                <div class="title">30일 후 신고 예치금은 반환됩니다.</div>
                <b-button variant="outline-secondary mt-2" @click="transferFee">{{$utils.toPXL(reportRegistrationFee)}} PXL 예치하기</b-button>
            </div>
            <!-- <div v-else>
                
            </div> -->
        </div>
    </div>
</template>

<script>
    import {BigNumber} from 'bignumber.js';

    export default {
        props: ['page', 'filter'],

        data() {
            return {
                reporterRegistrationAmount: 0,
                reporterRegistrationLockTime: 0,
                reportRegistrationFee: 0,
                pxl: 0
            }
        },
        methods: {
            async getRegistrationAmount() {
                let reagistration = await this.$contract.apiReport.getRegistrationAmount();
                this.reporterRegistrationAmount = BigNumber(reagistration[0]);
                this.reporterRegistrationLockTime = reagistration[1];
                this.reporterReporterBlock = reagistration[2];
                console.log("amount "+this.reporterRegistrationAmount);
                console.log("time "+this.reporterRegistrationLockTime);
                console.log("block "+this.reporterReporterBlock);
            },
            async setReportDeposit() {
                this.reportRegistrationFee = BigNumber(this.pictionConfig.pictionValue.reportRegistrationFee);
                this.pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
            },
            async transferFee() {
                let loader = this.$loading.show();
                if (this.reportRegistrationFee > this.pxl) {
                    alert(`예치금 ${$utils.toPXL(this.reportRegistrationFee)} PXL 이 필요합니다.`)
                    loader.hide();
                    return;
                }
                try {
                    await this.$contract.pxl.approveAndCall(this.pictionConfig.pictionAddress.report, this.reportRegistrationFee);
                    this.setReportDeposit();
                } catch (e) {
                    alert(e)
                }
                loader.hide();
            }
        },
        async created() {
            this.getRegistrationAmount();
            this.setReportDeposit();
        }
    }
</script>

<style scoped>
    .title {
        font-size: 24px;
    }
</style>