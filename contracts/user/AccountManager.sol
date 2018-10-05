pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IContent.sol";
import "contracts/interface/IAccountManager.sol";

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
    }

    struct Purchase {
        mapping (address => bool) isPurchasedContent;
        address[] contentsAddress;
    }

    mapping(string => uint256) userNameToIndex;
    mapping(address => uint256) addressToIndex;
    mapping(address => Purchase) addressToPurchase;

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
            token.safeTransfer(msg.sender, airdropAmount);
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
    * @dev 구매 내역 저장
    * @param _contentAddress 구매한 컨텐츠 컨트랙트 주소
    * @param _buyer 구매자 주소
    */
    function setPurchaseContentsAddress(
        address _contentAddress,
        address _buyer
    )
        external
        validAddress(_contentAddress) validAddress(_buyer)
    {
        require(council.getPixelDistributor() == msg.sender, "Purchase failed: Access denied.");

        require(isRegistered(account[addressToIndex[_buyer]].userName),
            "Purchase failed: Please register account.");

        Purchase storage purchase = addressToPurchase[_buyer];
        if(purchase.isPurchasedContent[_contentAddress]) {
            return;
        }

        purchase.isPurchasedContent[_contentAddress] = true;
        purchase.contentsAddress.push(_contentAddress);

        emit PurchaseContentsAddress(_buyer, _contentAddress);
    }

    /**
    * @dev 내 구매 내역 조회
    * @return contentsAddress_ 구매한 컨텐츠 컨트랙트 주소 배열
    */
    function getPurcahsedContents()
        external
        view
        returns (address[] memory contentsAddress_)
    {
        contentsAddress_ = addressToPurchase[msg.sender].contentsAddress;
    }

    /**
    * @dev 작품의 회차별 구매 상세 내역 조회
    * @param _contentsAddress 구매한 작품 주소 목록
    * @return contentsAddress_ 구매한 컨텐츠 컨트랙트 주소 배열
    * @return price_ 판매 가격
    * @return isPurchased_ 구매 여부
    */
    function getPurchasedContentEpisodes(
        address _contentsAddress
    )
        external
        view
        returns (address contentsAddress_, uint256[] price_, bool[] isPurchased_)
    {
        contentsAddress_ = _contentsAddress;

        IContent content = IContent(contentsAddress_);
        uint256 episodeLength = content.getEpisodeLength();

        if(episodeLength == 0) {
            return;
        }

        price_ = new uint256[](episodeLength);
        isPurchased_ = new bool[](episodeLength);

        for(uint256 i = 0 ; i < episodeLength ; i++) {
            ( , price_[i], , isPurchased_[i])= content.getEpisodeDetail(i, msg.sender);
        }
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
