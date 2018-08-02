pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/council/CouncilInterface.sol";
import "contracts/deposit/DepositPoolInterface.sol";
import "contracts/report/ReportInterface.sol";
//import "contracts/council/FundManagerInterface.sol";
//import "contracts/council/Fund.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/ParseLib.sol";
import "contracts/utils/ValidValue.sol";

/**
 * @title DepositPool
 * @dev 작품 초기 업로드 시 필요한 보증금의 적립과 판매금의 특정비율을 적립.
 *      신고자에 대한 보상으로 특정 금액을 전송.
 *      작품 완결 시 서포터 정산 후 작가에게 잔액 전송.
 */
contract DepositPool is ExtendsOwnable, ValidValue, ContractReceiver, DepositPoolInterface {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using ParseLib for string;

    CouncilInterface council;
    mapping (address => uint256) contentDeposit;

    /**
    * @dev 생성자
    * @param _councilAddress 위원회 주소
    */
    constructor(address _councilAddress) public {
        council = CouncilInterface(_councilAddress);
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
        string _data)
        public
        validAddress(_from)
        validAddress(_token)
    {
        addDeposit(_from, _value, _token, _data);
    }

    /**
    * @dev receiveApproval의 구현, token을 전송 받고 Content 별로 잔액을 기록함
    */
    function addDeposit(address _from, uint256 _value, address _token, string _data) private {
        ERC20 token = ERC20(council.getToken());
        require(address(token) == _token);

        address content = _data.parseAddr();
        contentDeposit[content] = contentDeposit[content].add(_value);
        token.safeTransferFrom(_from, address(this), _value);

        emit AddDeposit(_from, _value, _token, _data);
    }

    /**
    * @dev 위원회가 호출하는 보상지급 처리
    * @param _content 신고한 작품 주소
    * @param _reporter 신고자 주소
    */
    function reportReward(address _content, address _reporter)
        validAddress(_content)
        validAddress(_reporter)
        external
    {
        require(address(council) == msg.sender);

        uint256 amount;
        if (contentDeposit[_content] > 0) {
            ERC20 token = ERC20(council.getToken());
            amount = contentDeposit[_content].mul(council.getReportRewardRate()).div(100);

            require(token.balanceOf(address(this)) >= amount);
            contentDeposit[_content] = contentDeposit[_content].sub(amount);
            token.safeTransfer(_reporter, amount);
        } else {
            amount = 0;
        }
        emit ReportReward(_content, _reporter, amount);
    }

    /**
    * @dev 작품 완결 시 호출하는 정산 구현
    * @param _content 정산을 원하는 작품 주소
    */
    function release(address _content) validAddress(_content) external {

        //신고 건이 있으면 완결처리되지 않음
        require(ReportInterface(council.getReport()).getReportCount(_content) == 0);

        //작품 완결 시 서포터 비율 가져오고 정산 후 작가에게 정산
        // 누가 실행 시켜야 하는가??

        //ref pixelDistributor
        //call FundManager -> return fund[]

        //for(fund) fund.비율(contentDeposit[_content]) -> return (address[], amount[])
        // local(address[], amount[]) add (address[], amount[])
        //safeTransfer (address[](supporter), amount[])
        // emit Release

        // if(contentDeposit[_content] > 0)
        //safeTransfer writerAddress contentDeposit[_content]
        // emit Release
    }

    event AddDeposit(address _from, uint256 _value, address _token, string _data);
    event ReportReward(address _content, address _reporter, uint256 _amount);
    event Release(address _to, uint256 _amount);
}
