pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "contracts/interface/ICouncil.sol";

import "contracts/token/CustomToken.sol";
import "contracts/token/ContractReceiver.sol";
import "contracts/utils/ValidValue.sol";
import "contracts/utils/TimeLib.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/BytesLib.sol";


/**
 * @title UserPaybackPool contract
 *
 * @author Junghoon Seo - <jh.seo@battleent.com>
 */

contract UserPaybackPool is ExtendsOwnable, ContractReceiver, ValidValue {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using TimeLib for *;
    using BytesLib for bytes;

    mapping(address => uint256) userPaybackPxl;
    mapping(address => uint256) userReleasedTime;

    ICouncil council;

    uint256 releaseInterval;

    constructor(
        address _councilAddress
    )
        public
        validAddress(_councilAddress)
    {
        council = ICouncil(_councilAddress);
        releaseInterval = 10 minutes * 1000; 
    }

    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes _data)
        public
        validAddress(_from)
        validAddress(_token)
    {
        addPayback(_from, _value, _token, _data);
    }

    function addPayback(
        address _from, 
        uint256 _value, 
        address _token, 
        bytes _data
    )
        private 
    {
        require(council.getPixelDistributor() == _from, "Add payback failed: access denied.");

        ERC20 token = ERC20(council.getToken());
        require(address(token) == _token, "Add payback failed: check pixel address");

        CustomToken(address(token)).transferFromPxl(_from, address(this), _value, "에피소드 구매 리워드 예치");

        address user = _data.toAddress(0);
        userPaybackPxl[user] = userPaybackPxl[user].add(_value);

        if(userReleasedTime[user] == 0) {
            userReleasedTime[user] = TimeLib.currentTime();
        }

        emit AddPayback(user, TimeLib.currentTime(), _data.toAddress(20), _data.toUint(40), _value);
    }
 
    function release() public {
        ERC20 token = ERC20(council.getToken());
        require(TimeLib.currentTime() >= userReleasedTime[msg.sender].add(releaseInterval), "Release failed: Check release interval");

        if(userPaybackPxl[msg.sender] > 0) {
            userReleasedTime[msg.sender] = TimeLib.currentTime();
            
            uint256 rewardPxl = userPaybackPxl[msg.sender];
            userPaybackPxl[msg.sender] = 0;
            
            CustomToken(address(token)).transferPxl(msg.sender, rewardPxl, "에피소드 구매 리워드 지급");

            emit Release(msg.sender, userReleasedTime[msg.sender], rewardPxl);
        }
    }

    function getPaybackInfo()
        public
        view
        returns(
            uint256 paybackPxlAmount_,
            uint256 releasedTime_,
            uint256 nextReleaseTime_
        )
    {
        paybackPxlAmount_ = userPaybackPxl[msg.sender];
        releasedTime_ = userReleasedTime[msg.sender];
        nextReleaseTime_ = userReleasedTime[msg.sender].add(releaseInterval);
    }

    function getUserPaybackPxl() public view returns (uint256 paybackPxlAmount_) {
        paybackPxlAmount_ = userPaybackPxl[msg.sender];
    }

    function getUserReleasedTime() public view returns (uint256 userReleasedTime_) {
        userReleasedTime_ = userReleasedTime[msg.sender];
    }

    function getReleaseInterval() public view returns (uint256 releaseInterval_) {
        releaseInterval_ = releaseInterval;
    }
    
    event AddPayback(address indexed _userAddress, uint256 _accumulationTime, address _contentAddress, uint256 _episodeIndex, uint256 _value);
    event Release(address indexed _user, uint256 releasedTime, uint256 _amount);
}
