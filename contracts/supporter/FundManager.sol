pragma solidity ^0.4.24;

import "contracts/interface/IContent.sol";
import "contracts/interface/IFundManager.sol";
import "contracts/interface/ICouncil.sol";

import "contracts/supporter/Fund.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";

contract FundManager is IFundManager, ExtendsOwnable, ValidValue {
    using TimeLib for *;

    mapping(address => address) funds;
    address council;

    constructor(address _council) public validAddress(_council){
        council = _council;
    }

    /**
    * @dev 작품의 투자를 생성함
    * @param _content 생성할 작품의 주소
    * @param _startTime 투자를 시작할 시간
    * @param _endTime 투자를 종료하는 시간
    * @param _limit 0:maxcap(투자 총 모집금액), 1:softcap(투자 총 모집금액 하한), 2:minimum(1인당 투자 최소금액), 3:maximum(1인당 투자 최대금액)
    * @param _poolSize 몇회에 걸쳐 후원 받을것인가
    * @param _releaseInterval 후원 받을 간격
    * @param _supportFirstTime 첫 후원을 받을 수 있는 시간
    * @param _distributionRate 서포터가 분배 받을 비율
    * @param _detail 투자의 기타 상세 정보
    */
    function createFund(
        address _content,
        uint256 _startTime,
        uint256 _endTime,
        uint256[] _limit,
        uint256 _poolSize,
        uint256 _releaseInterval,
        uint256 _supportFirstTime,
        uint256 _distributionRate,
        string _detail)
    external returns (address fund_) {
        require(ICouncil(council).getApiFund() == msg.sender, "msg sender is not ApiFund");
        require(funds[_content] == address(0), "already fund");

        fund_ = new Fund(
            council,
            _content,
            _startTime,
            _endTime,
            _limit[0],
            _limit[1],
            _limit[2],
            _limit[3],
            _poolSize,
            _releaseInterval,
            _supportFirstTime,
            _distributionRate,
            _detail);
        
        funds[_content] = fund_;

        emit CreateFund(
            fund_,
            _content,
            _startTime,
            _endTime,
            _limit,
            _poolSize,
            _releaseInterval,
            _supportFirstTime,
            _distributionRate,
            _detail);
    }

    event CreateFund(
        address indexed _fund,
        address indexed _content,
        uint256 _startTime,
        uint256 _endTime,
        uint256[] _limit,
        uint256 _poolSize,
        uint256 _releaseInterval,
        uint256 _supportFirstTime,
        uint256 _distributionRate,
        string _detail
    );

    /**
    * @dev 작품의 투자 목록을 가져옴
    * @param _content 작품의 주소
    * @return fund_ 작품의 투자 주소
    */
    function getFund(address _content) external view returns (address fund_) {
        return funds[_content];
    }

    /**
    * @dev 작품의 판매금 정산을 위해 호출함
    * @param _fund 투자의 주소
    * @param _total 정산해야할 금액
    * @return supporter_ 정산해야하는 투자자 주소
    * @return amount_ 정산해야하는 금액
    */
    function distribution(address _fund, uint256 _total) external returns (address[] supporter_, uint256[] amount_) {
        require(msg.sender == ICouncil(council).getPixelDistributor(), "msg sender is not PixelDistributor");

        return Fund(_fund).distribution(_total);
    }
}
