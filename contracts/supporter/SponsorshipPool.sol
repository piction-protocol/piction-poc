pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/utils/BlockTimeMs.sol";

contract SponsorshipPool {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using BlockTimeMs for uint256;

    struct Supporter {
        address user;
        uint256 investment;
        uint256 collection;
        bool refund;
        mapping (uint256 => bool) voteResult;
    }

    //작가주소
    address writerAddress;
    //픽셀주소
    ERC20 pxlToken;
    //참여한 서포터 목록
    Supporter[] supports;
    //모집된 금액
    uint256 fundRise;
    //변경될 수 있는 지급해야할 횟수
    uint256 countOfRelease;
    //처음 지정한 지급해야할 횟수
    uint256 originCountOfRelease;
    //지급된 횟수
    uint256 releasedCount;
    //지급 간격
    uint256 releaseInterval;
    //이전에 지급된 시간
    uint256 lastReleaseTime;
    //자금모집이 종료된 시간
    uint256 fundEndTime;
    //전송될 토큰
    ERC20 pxlToken;

    constructor(address _writerAddress, address _tokenAddress, uint256 _countOfRelease, _fundEndTime) {
        writerAddress = _writerAddress;
        pxlToken = ERC20(_tokenAddress);
        countOfRelease = _countOfRelease;
        originCountOfRelease = _countOfRelease;
        lastReleaseTime = _fundEndTime;

        releaseInterval = 600000; //for test 10min
    }

    function voting(bool _interrupt) external returns (bool) {
        bool success = false;
        for(uint i = 0; i < supports.length; i++) {
            if (supports[i].user == msg.sender) {
                supports[i].voteResult[releasedCount] = _interrupt;
                success = true;
            }
        }

        return success;
    }

    function getInterruptVoteRate() private view returns (uint256) {
        uint256 interruptCount;
        for(uint i = 0; i < supports.length; i++) {
            if(supports[i].voteResult[releasedCount]) {
                interruptCount = interruptCount.add(1);
            }
        }

        if (interruptCount == 0) {
            return 0;
        }

        return interruptCount.div(supports.length).mul(100);
    }

    function releaseMonthly() external {
        require(block.timestamp.getMs() >= lastReleaseTime.add(releaseInterval));
        require(countOfRelease >= releasedCount);
        uint256 releaseAmount = fundRise.div(originCountOfRelease);
        require(token.balanceOf(address(this)) >= releaseAmount);

        if (getInterruptVoteRate() >= 50) {
            countOfRelease = countOfRelease.add(1);
        } else {
            token.safeTransfer(writerAddress, releaseAmount);
        }
        releasedCount = releasedCount.add(1);
        lastReleaseTime = lastReleaseTime.add(releaseInterval);
    }

    function getSupports()
        external
        view
        returns (address[], uint256[], bool[])
    {
        address[] memory user = new address[](supports.length.sub(1));
        uint256[] memory investment = new uint256[](supports.length.sub(1));
        bool[] memory supportRefund = new bool[](supports.length.sub(1));

        uint256 supportsIndex = 0;
        for(uint i = 0; i < supports.length; i++) {
            user[supportsIndex] = supports[i].user;
            investment[supportsIndex] = supports[i].investment;
            supportRefund[supportsIndex] = supports[i].refund;

            supportsIndex = supportsIndex.add(1);
        }
        return (user, investment, supportRefund);
    }
}
