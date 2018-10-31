<template>
    <div>
        <div class="page-title">신고 처리 내역</div>
        <br>
        <div v-if="reporterRegistrationAmount == 0 && !reporterReporterBlock">
            <div align="center">
                <div class="title">신고 권한을 획득하시려면 <b>신고 예치금</b>이 필요합니다.</div>
                <div class="title">신고 예치금 예치 후 30일 간 신고 권한이 부여되며,</div>
                <div class="title">30일 후 신고 예치금은 반환됩니다.(임시 30분)</div>
                <b-button variant="outline-secondary mt-2" @click="transferFee">{{web3.utils.fromWei(reportRegistrationFee)}} PXL 예치하기</b-button>
            </div>
        </div>
        <div v-else="">
            <div class="font-size-20 font-weight-bold mt-5 mb-2">예치금</div>
            <b-row>
            <b-col cols="2" sm="8" md="4" lg="2">
                <div>
                <span class="font-size-24">{{web3.utils.fromWei(reporterRegistrationAmount)}}</span>
                <span class="font-size-14 text-secondary">PXL</span>
                </div>
                <div class="font-size-12">신고 예치금</div>
            </b-col>
            <b-col cols="2" sm="8" md="4" lg="2">
                <div>
                <span class="font-size-24">{{reporterReporterBlock ? "-" : reporterRegistrationLockTimeText.number}}</span>
                <span class="font-size-14 text-secondary">{{reporterRegistrationLockTimeText.text}}</span>
                </div>
                <div class="font-size-12">신고권한 종료까지 남은 시간</div>
            </b-col>
            </b-row>
            <b-row class="pt-2 pb-2">
            <b-col cols="4">
                <b-progress :max="1"
                            height="12px" variant="primary">
                <b-progress-bar
                    :value="progressValue"></b-progress-bar>
                </b-progress>
            </b-col>
            </b-row>
            <b-row>
            <b-col cols="4">
                <b-button
                v-if="reporterRegistrationLockTime < $root.now && reporterRegistrationAmount > 0"
                type="submit" size="sm" variant="outline-secondary" block @click="withdrawRegistration">예치금 반환
                </b-button>
                <div v-if="reporterReporterBlock">
                돌려받을 예치금이 없으며 신고 권한을 신청하실 수 없습니다.
                </div>
                <div v-if="reporterRegistrationLockTime >= $root.now && reporterRegistrationAmount > 0">
                신고 권한이 만료되면 예치금을 돌려받을 수 있습니다. 신고 예치금이 0 PXL이 되는 경우 신고 권한이 박탈됩니다.
                </div>
            </b-col>
            </b-row>
        </div>
        <br>
        <br>
        <br>
        <b-table striped hover
                show-empty
                empty-text="조회된 목록이 없습니다"
                :fields="fields"
                :items="reports"
                :current-page="currentPage"
                :per-page="perPage"
                :small="true">
        <template slot="reportDate" slot-scope="row">{{$utils.dateFmt(row.item.reportDate)}}</template>
        <template slot="completeDate" slot-scope="row">{{$utils.dateFmt(row.item.completeDate)}}</template>
        <template slot="contentTitle" slot-scope="row">{{row.item.contentTitle}}</template>
        <template slot="reportDetail" slot-scope="row">{{row.item.reportDetail}}</template>
        <template slot="completeType" slot-scope="row">{{row.item.completeType}}</template>
        </b-table>
        <b-pagination class="d-flex justify-content-center" size="md"
                :total-rows="reports.length"
                v-model="currentPage"
                :per-page="perPage"
                :limit="limit">
        </b-pagination>
    </div>
</template>

<script>
    import ReportHistory from '@models/ReportHistory';
    import Web3Utils from '@utils/Web3Utils';

    export default {
        computed: {
            progressValue() {
                if (this.reporterRegistrationLockTime == 0) {
                    return 0;
                } else {
                    return 1 - (this.reporterRegistrationLockTime - this.$root.now) / this.interval;
                }
            },
            reporterRegistrationLockTimeText() {
                let time = Web3Utils.remainTimeToStr(this, this.reporterRegistrationLockTime)
                return time ? time : {number: '0', text: '초'};
            }
        },
        data() {
            return {
                fields: [
                    {key: 'reportDate', label: '신고 일시'},
                    {key: 'completeDate', label: '처리 일시'},
                    {key: 'contentTitle', label: '작품 명'},
                    {key: 'reportDetail', label: '신고 내용'},
                    {key: 'completeType', label: '처리'},
                ],
                reporterRegistrationAmount: new web3.utils.BN('0'),
                reporterRegistrationLockTime: 0,
                reporterReporterBlock: false,
                reportRegistrationFee: new web3.utils.BN('0'),
                interval: 0,
                pxl: new web3.utils.BN('0'),
                reports: [],
                perPage: 10,
                limit: 7,
                currentPage: 1,
            }
        },
        methods: {
            async init() {
                this.reportRegistrationFee = new web3.utils.BN(String(this.pictionConfig.pictionValue.reportRegistrationFee));
                this.pxl = new web3.utils.BN(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
                let reagistration = await this.$contract.apiReport.getRegistrationAmount();
                this.reporterRegistrationAmount = new web3.utils.BN(reagistration[0]);
                this.reporterRegistrationLockTime = reagistration[1];
                this.reporterReporterBlock = reagistration[2];
                this.interval = 30 * 60 * 1000; //test 30 min
            },
            async setTable() {
                let contentIds = [];
                let list = [];
                //신고 이벤트 조회
                let events = await this.$contract.report.getMyReportList();
                events.forEach(event => {
                    event = Web3Utils.prettyJSON(event.returnValues);
                    let history = new ReportHistory();
                    history.index = event.index;
                    history.reportDate = event.date;
                    history.reportDetail = event.detail;
                    list.push(history);

                    contentIds.push(event.content);
                });

                //작품 명 조회
                let comics = await this.$contract.apiContents.getComics(this, contentIds);
                list.forEach((history, i) => history.contentTitle = comics[i].title);
                
                //신고처리 완료 조회
                events = await this.$contract.report.getMyCompleteReportList();
                events.forEach(event => {
                    event = Web3Utils.prettyJSON(event.returnValues);
                    let findObj = list.find(o => o.index == event.index);
                    findObj.completeDate = event.completeDate;
                    switch(event.type) {
                        case 1: findObj.completeType = "작품 차단 (작가 -"+this.web3.utils.fromWei(event.deductionAmount)+"PXL)";
                        case 2: findObj.completeType = "작품 경고 (작가 -"+this.web3.utils.fromWei(event.deductionAmount)+"PXL)";
                        case 3: findObj.completeType = "신고 무효";
                        case 4: findObj.completeType = "중복 신고";
                        case 5: findObj.completeType = "잘못된 신고 (신고자 -"+this.web3.utils.fromWei(event.deductionAmount)+"PXL)";
                        default: findObj.completeType = "";
                    }
                });

                this.reports = list.reverse();
            },
            async transferFee() {
                let loader = this.$loading.show();
                console.log(this.reportRegistrationFee.toString(), this.pxl.toString())
                if (this.reportRegistrationFee > this.pxl) {
                    alert(`예치금 ${this.web3.utils.fromWei(this.reportRegistrationFee)} PXL 이 필요합니다.`)
                    loader.hide();
                    return;
                }
                try {
                    await this.$contract.pxl.approveAndCall(this.pictionConfig.pictionAddress.report, this.reportRegistrationFee);
                    this.init();
                } catch (e) {
                    alert(e)
                }
                loader.hide();
            },
            async withdrawRegistration() {
                let loader = this.$loading.show();
                try {
                    await this.$contract.apiReport.withdrawRegistration();
                    this.init();
                } catch (e) {
                    alert(e)
                }
                loader.hide();
            }
        },
        async created() {
            this.init();
            this.setTable();
        }
    }
</script>

<style scoped>
    .title {
        font-size: 24px;
    }
</style>