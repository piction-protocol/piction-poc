pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/interface/IContent.sol";
import "contracts/interface/ICouncil.sol";
import "contracts/interface/IDepositPool.sol";
import "contracts/interface/IReport.sol";
import "contracts/interface/IFundManager.sol";

import "contracts/token/CustomToken.sol";
import "contracts/token/ContractReceiver.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/BytesLib.sol";

/**
 * @title DepositPool
 * @dev 작품 초기 업로드 시 필요한 보증금의 적립과 판매금의 특정비율을 적립.
 *      신고자에 대한 보상으로 특정 금액을 전송.
 *      작품 완결 시 서포터 정산 후 작가에게 잔액 전송.
 */
contract DepositPool is ExtendsOwnable, ValidValue, ContractReceiver, IDepositPool {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using BytesLib for bytes;


    uint256 DECIMALS = 10 ** 18;

    ICouncil council;
    mapping (address => uint256) contentDeposit;

    /**
    * @dev 생성자
    * @param _councilAddress 위원회 주소
    */
    constructor(address _councilAddress) public validAddress(_councilAddress) {
        council = ICouncil(_councilAddress);
    }

    /**
    * @dev Token의 ApproveAndCall이 호출하는 Contract의 함수
    * @param _from 허가자
    * @param _value 전송량
    * @param _token 실행되는 토큰 주소
    * @param _data 전송된 데이터
    */
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes _data)
        public
        validAddress(_from)
        validAddress(_token)
    {
        addDeposit(_from, _value, _token, _data);
    }

    /**
    * @dev receiveApproval의 구현, token을 전송 받고 Content 별로 잔액을 기록함
    */
    function addDeposit(address _from, uint256 _value, address _token, bytes _data) private {
        require(_data.length > 0);
        ERC20 token = ERC20(council.getToken());
        require(address(token) == _token);

        string memory message = (_from == council.getPixelDistributor())? "에피소드 판매 적립금" : "작품 초기 보증금 예치";

        address content = _data.toAddress(0);
        contentDeposit[content] = contentDeposit[content].add(_value);
        CustomToken(address(token)).transferFromPxl(_from, address(this), _value, message);

        emit AddDeposit(_from, _value, _token);
    }

    /**
    * @dev Content 별 쌓여있는 Deposit의 양을 반환함
    * @param _content 작품의 주소
    */
    function getDeposit(address _content) external view returns(uint256) {
        return contentDeposit[_content];
    }

    /**
    * @dev 위원회가 호출하는 보상지급 처리
    * @param _content 신고한 작품 주소
    * @param _reporter 신고자 주소
    */
    function reportReward(address _content, address _reporter)
        external
        validAddress(_content)
        validAddress(_reporter)
        returns(uint256)
    {
        require(address(council) == msg.sender);

        uint256 amount;
        if (contentDeposit[_content] > 0) {
            ERC20 token = ERC20(council.getToken());
            amount = contentDeposit[_content].mul(council.getReportRewardRate()).div(DECIMALS);

            require(token.balanceOf(address(this)) >= amount);
            contentDeposit[_content] = contentDeposit[_content].sub(amount);
            CustomToken(address(token)).transferPxl(_reporter, amount, "신고 활동 보상금");
        } else {
            amount = 0;
        }
        emit ReportReward(_content, _reporter, amount);

        return amount;
    }

    function getReportRate(address _content) external view returns(uint256) {
        return contentDeposit[_content].mul(council.getReportRewardRate()).div(DECIMALS);
    }

    /**
    * @dev 작품 완결 시 호출하는 정산 구현
    * @param _content 정산을 원하는 작품 주소
    */
    function release(address _content) external validAddress(_content) {
        //신고 건이 있으면 완결처리되지 않음
        require(IReport(council.getReport()).getUncompletedReport(_content) == 0, "UncompletedReport");
        require(contentDeposit[_content] > 0, "contentDeposit is zero");
        address writer = IContent(_content).getWriter();
        require(writer == msg.sender, "msg sender is not writer");
        ERC20 token = ERC20(council.getToken());
        require(token.balanceOf(address(this)) >= contentDeposit[_content], "token balance abnormal");

        IFundManager fund = IFundManager(council.getFundManager());

        address fundAddress = fund.getFund(_content);

        uint256 compareAmount;
        uint256 amount = contentDeposit[_content];

        (address[] memory supporterAddress, uint256[] memory supporterAmount) = fund.distribution(fundAddress, amount);

        CustomToken customToken = CustomToken(address(token));

        //supporter 크기가 커질 경우 Gas Limit 우려됨 개선 필요
        for(uint256 j = 0 ; j < supporterAddress.length ; j++) {
            compareAmount = compareAmount.add(supporterAmount[j]);
            contentDeposit[_content] = contentDeposit[_content].sub(supporterAmount[j]);

            customToken.transferPxl(supporterAddress[j], supporterAmount[j], "작품 초기 보증금 분배");
            emit Release(_content, supporterAddress[j], supporterAmount[j]);
        }
        amount = amount.sub(compareAmount);

        if (amount > 0) {
            contentDeposit[_content] = contentDeposit[_content].sub(amount);

            customToken.transferPxl(writer, amount, "작품 초기 보증금 분배");
            emit Release(_content, writer, amount);
        }

        require(contentDeposit[_content] == 0, "release deposit abnormal");
    }

    event AddDeposit(address _from, uint256 _value, address _token);
    event ReportReward(address _content, address _reporter, uint256 _amount);
    event Release(address _content, address _to, uint256 _amount);
}
