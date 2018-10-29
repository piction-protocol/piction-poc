pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IContent.sol";
import "contracts/interface/IContentsManager.sol";
import "contracts/interface/IFundManager.sol";
import "contracts/interface/IAccountManager.sol";
import "contracts/token/CustomToken.sol";

import "contracts/utils/ValidValue.sol";
import "contracts/utils/BytesLib.sol";

contract AccountManager is IAccountManager, ValidValue {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using BytesLib for bytes;

    struct Account {
        string userName;
        string password;
        string privateKey;
        address wallet;
        mapping(address => bool) addressToFavorite;
    }

    mapping(string => uint256) userNameToIndex;
    mapping(address => uint256) addressToIndex;

    ICouncil council;
    IERC20 token;
    Account[] account;
    uint256 airdropAmount;

    constructor (address _council, uint256 _amount) public {
        council = ICouncil(_council);
        token = IERC20(council.getToken());
        airdropAmount = _amount;
    }

    /**
    * @dev 신규 계정 생성
    * @param _userName 계정 이름(ID)
    * @param _password 비밀번호
    * @param _privateKey 신규로 발급 된 private key
    * @param _wallet 신규로 발급 된 public address
    */
    function createNewAccount(
        string _userName,
        string _password,
        string _privateKey,
        address _wallet
    )
        external
        validAddress(_wallet) validString(_userName)
        validString(_password) validString(_privateKey)
    {
        require(!isRegistered(_userName), "Create new account failed: Registered user name.");

        account.push(Account(_userName, _password, _privateKey, _wallet));
        userNameToIndex[_userName] = account.length.sub(1);
        addressToIndex[_wallet] = account.length.sub(1);

        if (airdropAmount > 0 && token.balanceOf(address(this)) >= airdropAmount) {
            CustomToken(address(token)).transferPxl(msg.sender, airdropAmount, "에어드롭 픽셀 입금");
        }

        emit RegisterNewAccount(account.length.sub(1), _wallet, _userName);
    }

    /**
    * @dev 로그인 처리
    * @param _userName 계정 이름(ID)
    * @param _password 비밀번호
    * @return key_ 로그인 성공 시 private key 전달, 실패시 에러 메시지 전달
    * @return result_ 로그인 성공 여부
    */
    function login(
        string _userName,
        string _password
    )
        external
        view
        validString(_userName) validString(_userName)
        returns (string key_, bool result_)
    {
        if(account.length == 0 || !isRegistered(_userName)) {
            key_ = "Login failed: Please register account.";
            result_ = false;
            return;
        }

        if(!_compareString(account[userNameToIndex[_userName]].password, _password)) {
            key_ = "Login failed: check register account.";
            result_ = false;
            return;
        }

        key_ = account[userNameToIndex[_userName]].privateKey;
        result_ = true;
    }

    /**
    * @dev 구매 내역 이벤트 처리
    * @param _buyer 구매자 주소
    * @param _contentsAddress 구매한 컨텐츠 컨트랙트 주소
    * @param _episodeIndex 구매한 컨텐츠 컨트랙트 주소
    * @param _episodePrice 구매한 컨텐츠 컨트랙트 주소
    */
    function setPurchaseHistory(
        address _buyer,
        address _contentsAddress,
        uint256 _episodeIndex,
        uint256 _episodePrice
    )
        external
        validAddress(_contentsAddress) validAddress(_buyer)
    {
        require(council.getPixelDistributor() == msg.sender, "Purchase failed: Access denied.");
        require(isRegistered(account[addressToIndex[_buyer]].userName), "Purchase failed: Please register account.");

        emit PurchaseHistory(_buyer, _contentsAddress, _episodeIndex, _episodePrice);
    }

    /**
    * @dev 사용자 비밀번호 변경
    * @param _newPassword 변경할 비밀번호
    * @param _passwordValidation 비밀번호 문자열 확인
    */
    function setNewPassword(
        string _newPassword,
        string _passwordValidation
    )
        external
        validString(_newPassword) validString(_passwordValidation)
    {
        require(isRegistered(account[addressToIndex[msg.sender]].userName), "Set new password falid : Please register account.");
        require(_compareString(_newPassword, _passwordValidation), "Set new password falid : Check password string.");

        account[addressToIndex[msg.sender]].password = _newPassword;
    }

    /** 
    * @dev 투자 내역 저장
    * @param _supporter 투자자 주소
    * @param _contentsAddress 투자한 작품 주소
    * @param _fundAddress fund contract 주소
    * @param _investedAmount 투자 금액
    * @param _refund 환불 여부
    */
    function setSupportHistory(
        address _supporter, 
        address _contentsAddress,
        address _fundAddress,
        uint256 _investedAmount,
        bool _refund
    )
        external
        validAddress(_supporter) validAddress(_fundAddress) validAddress(_contentsAddress)
    {
        require(_isFundContract(_fundAddress, _contentsAddress), "Support history failed: Invalid address.");
        require(isRegistered(account[addressToIndex[_supporter]].userName), "Support history failed: Please register account.");

        emit SupportHistory(_supporter, _contentsAddress, _fundAddress, _investedAmount, _refund);
    }

    function changeFavoriteContent(
        address _user,
        address _contentAddress
    )
        external
        validAddress(_contentAddress) validAddress(_user)
    {
        require(_isContentContract(_contentAddress), "Change favorite content failed: Invalid content address.");
        require(isRegistered(account[addressToIndex[_user]].userName), "Change favorite content failed: Please register account.");

        if(account[addressToIndex[_user]].addressToFavorite[_contentAddress]) {
            account[addressToIndex[_user]].addressToFavorite[_contentAddress] = false;
        } else {
            account[addressToIndex[_user]].addressToFavorite[_contentAddress] = true;
        }
    }

    function getFavoriteContent(
        address _user,
        address _contentAddress
    )
        external
        view
        returns (bool isFavoriteContent_)
    {
        isFavoriteContent_ = account[addressToIndex[_user]].addressToFavorite[_contentAddress];
    }

    /**
    * @dev 등록 된 ID인지 확인
    * @param _userName 유저 ID
    * @return isRegistered_ 등록 여부
    */
    function isRegistered(
        string _userName
    )
        public
        view
        validString(_userName)
        returns (bool isRegistered_)
    {
        if(userNameToIndex[_userName] > 0) {
            isRegistered_ = true;
            return;
        }

        if(account.length > 0 && userNameToIndex[_userName] == 0 && _compareString(account[userNameToIndex[_userName]].userName, _userName)) {
            isRegistered_ = true;
            return;
        }

    }

    /**
    * @dev ID 조회
    * @param _wallet 계정의 지갑 주소
    * @return userName_ ID
    * @return result_ 조회 결과
    */
    function getUserName(
        address _wallet
    )
        external
        view
        validAddress(_wallet)
        returns (string memory userName_, bool result_)
    {
        if(account.length > 0 && account[addressToIndex[_wallet]].wallet == _wallet) {
            userName_ = account[addressToIndex[_wallet]].userName;
            result_ = true;
        }
    }

    /**
    * @dev ID 조회
    * @param _wallet 계정의 지갑 주소 배열
    * @return writer_ 유저 주소
    * @return writerName_ bytes로 변환한 유저 이름
    * @return spos_ bytes로 변환 된 writerName_의 start index
    * @return epos_ bytes로 변환 된 writerName_의 end index
    */
    function getUserNames(
        address[] _wallet
    )
        external
        view
        returns (address[] memory writer_, bytes memory writerName_, uint256[] memory spos_, uint256[] memory epos_)
    {
        uint256 writerNameLength = _wallet.length;

        writer_ = _wallet;
        spos_ = new uint256[](writerNameLength);
        epos_ = new uint256[](writerNameLength);

        uint256 tempLength;
        for(uint256 i = 0 ; i < writerNameLength ; i++) {
            bytes memory str = bytes(account[addressToIndex[writer_[i]]].userName);
            spos_[i] = tempLength;
            writerName_ = writerName_.concat(str);
            tempLength = (tempLength == 0)? tempLength.add((str.length).mul(2).add(2)) : tempLength.add((str.length).mul(2));
            epos_[i] = tempLength;
        }
    }

    function _isFundContract(
        address _fundAddress,
        address _contentsAddress
    )
        private
        view
        returns (bool isFundContract_)
    {
        address fundAddress = IFundManager(council.getFundManager()).getFund(_contentsAddress);
        
        isFundContract_ = (fundAddress == _fundAddress);
    }

    function _isContentContract(
        address _contentsAddress
    )
        private
        view
        returns (bool isContentContract_)
    {
        address[] memory contentsAddress = IContentsManager(council.getContentsManager()).getContentsAddress();
        
        if(contentsAddress.length == 0) {
            return;
        }

        for(uint256 i = 0 ; i < contentsAddress.length ; i++){
            if(contentsAddress[i] == _contentsAddress) {
                isContentContract_ = true;
                break;
            }
        }
    }

    function _compareString(
        string _a,
        string _b
    )
        private
        pure
        returns (bool)
    {
        return keccak256(_a) == keccak256(_b);
    }
}
