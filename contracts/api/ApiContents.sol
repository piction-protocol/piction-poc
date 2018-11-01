pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

import "contracts/token/ContractReceiver.sol";
import "contracts/token/CustomToken.sol";

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IContent.sol";
import "contracts/interface/IContentsManager.sol";
import "contracts/interface/IAccountManager.sol";

import "contracts/utils/ValidValue.sol";
import "contracts/utils/BytesLib.sol";

contract ApiContents is ValidValue {
    using BytesLib for bytes;
    using SafeMath for uint256;

    ICouncil public council;
    IContentsManager public contentsManager;

    constructor (
        address _council,
        address _contentsManager
    )
        public
        validAddress(_council) validAddress(_contentsManager)
    {
        council = ICouncil(_council);
        contentsManager = IContentsManager(_contentsManager);
    }

    /**
    * @dev contents 등록
    *
    * @notice 메뉴 publish의 새 작품 등록
    * @param _record Json string 타입의 작품 세부 정보
    */
    function createComic (
        string _record
    )
        external
        validString(_record)
    {
        require(getInitialDeposit(msg.sender) == council.getInitialDeposit(), "Content creation failed: check contents initial deposit amount.");

        require(council.getDepositPool() != address(0), "Content creation failed: Piction network error. check council config.");

        string memory writerName;
        bool result;
        (writerName, result) = IAccountManager(council.getAccountManager()).getUserName(msg.sender);

        require(result, "Content creation failed: Please register account.");
        contentsManager.addContents(msg.sender, writerName, _record);
    }

    /**
    * @dev contents 수정
    *
    * @notice 메뉴 publish의 등록 된 작품 수정
    * @param _comicAddress 수정하고자 하는 컨텐츠 주소
    * @param _record Json string 타입의 작품 세부 정보
    */
    function updateComic(
        address _comicAddress,
        string _record
    )
        external
        validAddress(_comicAddress) validString(_record)
    {
        require(_checkWriterContents(_comicAddress), "Update contents failed: Unregistered contents address.");

        IContent content = IContent(_comicAddress);
        require(_checkAccessRole(content), "Update contents failed: Access denied.");

        content.updateContent(_record);
    }

    /**
    * @dev episode 등록
    *
    * @notice 메뉴 publish의 episode 등록
    * @param _record Json string 타입의 작품 세부 정보
    * @param _isPublished 작품 공개 여부
    * @param _publishDate 작품 공개 시간
    */
    function createEpisode(
        address _comicAddress,
        string _record,
        string _cuts,
        uint256 _price,
        bool _isPublished,
        uint256 _publishDate
    )
        external
        validAddress(_comicAddress) validString(_record) validString(_cuts)
    {
        require(_checkWriterContents(_comicAddress), "Add episode failed: Unregistered contents address.");

        IContent content = IContent(_comicAddress);
        require(_checkAccessRole(content), "Add episode failed: Access denied.");

        content.addEpisode(_record, _cuts, _price, _isPublished, _publishDate);
    }

    /**
    * @dev episode 수정
    *
    * @notice 메뉴 publish의 episode 수정
    * @param _record Json string 타입의 작품 세부 정보
    * @param _isPublished 작품 공개 여부
    * @param _publishDate 작품 공개 시간
    */
    function updateEpisode(
        address _comicAddress,
        uint256 _index,
        string _record,
        string _cuts,
        uint256 _price,
        bool _isPublished,
        uint256 _publishDate
    )
        external
        validAddress(_comicAddress) validString(_record) validString(_cuts)
    {
        require(_checkWriterContents(_comicAddress), "Update episode failed: Unregistered contents address.");

        IContent content = IContent(_comicAddress);
        require(_checkAccessRole(content), "Update episode failed: Access denied.");
        require(getEpisodeLength(_comicAddress) > _index, "Update episode failed: episode index out of range");

        content.updateEpisode(_index, _record, _cuts, _price, _isPublished, _publishDate);
    }

    /**
    * @dev favorite 설정 및 취소
    *
    * @notice 메뉴 comics-detail의 작품 즐겨 찾기 설정
    * @param _comicAddress 작품 주소
    */
    function updateFavorite(
        address _comicAddress
    )
        external
        validAddress(_comicAddress)
    {
        bool status = getFavorite(_comicAddress);
        IContent(_comicAddress).updateFavoriteCount(status);
        IAccountManager(council.getAccountManager()).changeFavoriteContent(msg.sender, _comicAddress);
    }

    /**
    * @dev 컨텐츠 favorite 조회
    *
    * @notice 메뉴 comics-detail의 작품 즐겨 찾기 조회
    * @param _comicAddress 작품 주소
    * @return isFavoriteContent_ on/off 결과
    */
    function getFavorite (
        address _comicAddress
    )
        public
        view
        returns (bool isFavoriteContent_)
    {
        isFavoriteContent_ = IAccountManager(council.getAccountManager()).getFavoriteContent(msg.sender, _comicAddress);
    }

    /**
    * @dev 작품 정보 조회
    *
    * @notice 메뉴 comics의 작품 전시 화면
    * @return comicAddress_ 공개가 가능한 컨텐츠 주소 목록
    * @return records_ Json string 타입의 작품 세부 정보
    * @return writer_ 작가 주소
    * @return totalPurchasedCount_ 작품 판매 수
    * @return contentCreationTime_ 컨텐츠 등록 시간
    * @return episodeLastUpdatedTime_ 마지막 등록 된 에피소드 등록 시간
    */
    function getComics()
        external
        view
        returns (
            address[] memory comicAddress_,
            bytes memory records_,
            address[] memory writer_,
            uint256[] memory totalPurchasedCount_,
            uint256[] memory totalPurchasedAmount_,
            uint256[] memory contentCreationTime_,
            uint256[] memory episodeLastUpdatedTime_
        )
    {
        comicAddress_ = contentsManager.getPublishContentsAddress();

        if(comicAddress_.length == 0) {
            return;
        }

        records_ = _getComicRecords(comicAddress_);

        writer_ = new address[](comicAddress_.length);
        totalPurchasedCount_ = new uint256[](comicAddress_.length);
        totalPurchasedAmount_ = new uint256[](comicAddress_.length);
        contentCreationTime_ = new uint256[](comicAddress_.length);
        episodeLastUpdatedTime_ = new uint256[](comicAddress_.length);

        for(uint256 i = 0 ; i < comicAddress_.length ; i++) {
            (, writer_[i], , totalPurchasedCount_[i], totalPurchasedAmount_[i], contentCreationTime_[i],
                episodeLastUpdatedTime_[i]) = IContent(comicAddress_[i]).getComicsInfo();
        }
    }

    /**
    * @dev 작품 주소를 이용하여 정보 조회
    *
    * @return comicAddress_ 공개가 가능한 컨텐츠 주소 목록
    * @return records_ Json string 타입의 작품 세부 정보
    * @return writer_ 작가 주소
    * @return totalPurchasedCount_ 작품 판매 수
    * @return contentCreationTime_ 컨텐츠 등록 시간
    * @return episodeLastUpdatedTime_ 마지막 등록 된 에피소드 등록 시간
    */
    function getComicsByAddress(
        address[] _comicAddress
    )
        external
        view
        returns(
            address[] memory comicAddress_,
            bytes memory records_,
            address[] memory writer_,
            uint256[] memory totalPurchasedCount_,
            uint256[] memory totalPurchasedAmount_,
            uint256[] memory contentCreationTime_,
            uint256[] memory episodeLastUpdatedTime_
        )
    {
        if(_comicAddress.length == 0) {
            return;
        }

        records_ = _getComicRecords(_comicAddress);

        comicAddress_ = _comicAddress;
        writer_ = new address[](_comicAddress.length);
        totalPurchasedCount_ = new uint256[](_comicAddress.length);
        totalPurchasedAmount_ = new uint256[](_comicAddress.length);
        contentCreationTime_ = new uint256[](_comicAddress.length);
        episodeLastUpdatedTime_ = new uint256[](_comicAddress.length);

        for(uint256 i = 0 ; i < _comicAddress.length ; i++) {
            (, writer_[i], , totalPurchasedCount_[i], totalPurchasedAmount_[i], contentCreationTime_[i],
                episodeLastUpdatedTime_[i]) = IContent(_comicAddress[i]).getComicsInfo();
        }
    }

    /**
    * @dev 작품 세부 정보 조회
    *
    * @notice 메뉴 comics-detail의 작품의 세부 정보
    * @param _comicAddress 작품 주소
    * @return records_ Json string 타입의 작품 세부 정보
    * @return writer_ 작가 주소
    * @return writerName_ 작가 이름
    * @return isFavorite 유저의 즐겨 찾기 설정 여부
    */
    function getComic(
        address _comicAddress
    )
        external
        view
        returns (
            string records_,
            address writer_,
            string writerName_,
            bool isFavorite
        )
    {
        if(IContent(_comicAddress).getIsBlocked()) {
            return;
        }

        (records_, writer_, writerName_, , , ,) = IContent(_comicAddress).getComicsInfo();
        isFavorite = getFavorite(_comicAddress);
    }

    /**
    * @dev 작품 에피소드 정보 조회
    *
    * @notice 메뉴 comics-detail의 작품의 에피소드 정보
    * @param _comicAddress 작품 주소
    * @return records_ Json string 타입의 episode 정보
    * @return price_ 판매 가격
    * @return isPurchased_ 구매 유무
    * @return episodeCreationTime_ episode 등록 시간 정보
    * @return episodeIndex_ episode 회차
    */
    function getEpisodes(
        address _comicAddress
    )
        external
        view
        returns (
            bytes records_,
            uint256[] memory price_,
            bool[] memory isPurchased_,
            uint256[] memory episodeCreationTime_,
            uint256[] memory episodeIndex_
        )
    {
        if(IContent(_comicAddress).getIsBlocked()) {
            return;
        }

        episodeIndex_ = IContent(_comicAddress).getPublishEpisodeIndex();

        if(episodeIndex_.length == 0) {
            return;
        }

        price_ = new uint256[](episodeIndex_.length);
        isPurchased_ = new bool[](episodeIndex_.length);
        episodeCreationTime_ = new uint256[](episodeIndex_.length);

        bytes memory start = "[";
        bytes memory end = "]";
        bytes memory separator = ",";
        records_ = records_.concat(start);

        string memory strRecord;
        for(uint256 i = 0 ; i < episodeIndex_.length ; i++) {
            (strRecord, price_[i], , , isPurchased_[i], , , episodeCreationTime_[i]) = IContent(_comicAddress).getEpisodeDetail(episodeIndex_[i], msg.sender);

            records_ = records_.concat(bytes(strRecord));
            if(i != episodeIndex_.length - 1) {
                records_ = records_.concat(separator);
            }
        }
        records_ = records_.concat(end);
    }

    /**
    * @dev 작품 에피소드 정보 조회
    *
    * @param _comicAddress 작품 주소
    * @param _index episode 회차
    * @return records_ Json string 타입의 작품 정보
    * @return price_ 총 판매 pxl
    * @return buyCount_ 공개한 episode 수
    * @return isPurchased_ episode 구매 여부
    * @return isPublished_ episode 공개 여부
    * @return publishDate_ episode 공개 일자
    * @return episodeCreationTime_ episode 등록 일자
    */
    function getEpisode(
        address _comicAddress,
        uint256 _index
    )
        external
        view
        returns(
            string records_,
            uint256 price_,
            uint256 buyCount_,
            bool isPurchased_,
            bool isPublished_,
            uint256 publishDate_,
            uint256 episodeCreationTime_
        )
    {
        if(!isPurchasedEpisode(_comicAddress, _index, msg.sender)) {
            return;
        }

        (records_, price_, buyCount_, , isPurchased_, isPublished_, publishDate_,
            episodeCreationTime_) = IContent(_comicAddress).getEpisodeDetail(_index, msg.sender);
    }

    /**
    * @dev 작가의 작품 관리
    *
    * @notice 메뉴 publish의 만화 작품 관리
    * @return comicAddress_ 내 작품 주소
    * @return isBlockComic_ 작품 차단 여부
    * @return records_ Json string 타입의 작품 정보
    * @return totalPurchasedAmount_ 총 판매 pxl
    * @return publishedEpisode_ 공개한 episode 수
    * @return privateEpisode_ 비 공개 episode 수
    */
    function getMyComics()
        external
        view
        returns (
            address[] comicAddress_,
            bool[] isBlockComic_,
            bytes records_,
            uint256[] totalPurchasedAmount_,
            uint256[] publishedEpisode_,
            uint256[] privateEpisode_
        )
    {
        comicAddress_ = contentsManager.getWriterContentsAddress(msg.sender);

        if(comicAddress_.length == 0) {
            return;
        }

        isBlockComic_ = new bool[](comicAddress_.length);
        totalPurchasedAmount_ = new uint256[](comicAddress_.length);
        publishedEpisode_ = new uint256[](comicAddress_.length);
        privateEpisode_ = new uint256[](comicAddress_.length);

        records_ = _getComicRecords(comicAddress_);

        uint256 episodeLength;
        for(uint256 i = 0 ; i < comicAddress_.length ; i++) {
            if(IContent(comicAddress_[i]).getWriter() == msg.sender){
                isBlockComic_[i] = IContent(comicAddress_[i]).getIsBlocked();
                totalPurchasedAmount_[i] = IContent(comicAddress_[i]).getTotalPurchasedAmount();

                episodeLength = IContent(comicAddress_[i]).getEpisodeLength();
                publishedEpisode_[i] = IContent(comicAddress_[i]).getPublishEpisodeIndex().length;
                privateEpisode_[i] = episodeLength.sub(publishedEpisode_[i]);
            }
        }
    }

    /**
    * @dev 작가의 작품 에피소드 관리
    *
    * @notice 메뉴 publish의 작품의 에피소드 정보
    * @param _comicAddress 작품 주소
    * @return records_ Json string 타입의 episode 정보
    * @return price_ 판매 가격
    * @return purchasedAmount_ 에피소드 별 매출
    * @return buyCount_ 구매한 독자 수
    * @return isPublished 공개 여부
    * @return publishDate_ episode 공개 시간
    * @return episodeIndex_ episode 회차
    */
    function getMyEpisodes(
        address _comicAddress
    )
        external
        view
        returns (
            bytes records_,
            uint256[] memory price_,
            uint256[] memory purchasedAmount_,
            bool[] memory isPublished_,
            uint256[] memory publishDate_,
            uint256[] memory episodeIndex_
        )
    {
        if(IContent(_comicAddress).getWriter() != msg.sender) {
            return;
        }

        uint256 episodeLength = IContent(_comicAddress).getEpisodeLength();
        if(episodeLength == 0){
            return;
        }

        price_ = new uint256[](episodeLength);
        purchasedAmount_ = new uint256[](episodeLength);
        isPublished_ = new bool[](episodeLength);
        publishDate_ = new uint256[](episodeLength);
        episodeIndex_ = new uint256[](episodeLength);

        bytes memory start = "[";
        bytes memory end = "]";
        bytes memory separator = ",";
        records_ = records_.concat(start);

        string memory strRecord;
        for(uint256 i = 0 ; i < episodeLength ; i++) {
            (strRecord, price_[i], , purchasedAmount_[i], , isPublished_[i], publishDate_[i], ) = IContent(_comicAddress).getEpisodeDetail(i, msg.sender);
            episodeIndex_[i] = i;

            records_ = records_.concat(bytes(strRecord));
            if(i != episodeLength - 1) {
                records_ = records_.concat(separator);
            }
        }
        records_ = records_.concat(end);
    }

    /**
    * @dev 작품 매출 정보 조회
    *
    * @notice publish 메뉴 중 info 탭의 매출 정보 조회
    * @param _comicAddress 작품 주소
    * @return totalPurchasedAmount_ 총 구매 pxl 양
    * @return totalPurchasedCount_ 총 구매 건수
    * @return favoriteCount_ favorite 유지 건수
    * @return totalPurchasedUserCount_ 구매 유저 수
    */
    function getComicSales(
        address _comicAddress
    )
        external
        view
        returns (
            uint256 totalPurchasedAmount_,
            uint256 totalPurchasedCount_,
            uint256 favoriteCount_,
            uint256 totalPurchasedUserCount_
        )
    {
        (totalPurchasedAmount_, totalPurchasedCount_, favoriteCount_, totalPurchasedUserCount_) = IContent(_comicAddress).getSalesInfo();
    }

    /**
    * @dev 작품의 이미지 조회
    *
    * @notice comics, publish 등의 메뉴에서 작품의 이미지 조회
    * @param _comicAddress 작품 주소
    * @param _index episode index
    * @return cuts_ Json type의 이미지 주소
    */
    function getCuts(
        address _comicAddress,
        uint256 _index
    )
        external
        view
        returns (string cuts_)
    {
        if(isPurchasedEpisode(_comicAddress, _index, msg.sender)) {
            cuts_ = IContent(_comicAddress).getEpisodeCuts(_index, msg.sender);
        }
    }

    /**
    * @dev 작가의 초기 보증금 조회
    * @param _writerAddress 작가 주소
    * @return initialDeposit_ 보증금
    */
    function getInitialDeposit(
        address _writerAddress
    )
        public
        view
        returns (uint256 initialDeposit_)
    {
        initialDeposit_ = contentsManager.getInitialDeposit(_writerAddress);
    }

    /**
    * @dev 작품에 등록 된 에피소드 수 조회
    * @param _contentsAddress 작품 컨트랙트 주소 목록
    * @return episodeLength_ 등록 된 에피소드 수
    */
    function getEpisodeLength(
        address _contentsAddress
    )
        public
        view
        returns (uint256 episodeLength_)
    {
        episodeLength_ = IContent(_contentsAddress).getEpisodeLength();
    }

    function isPurchasedEpisode(
        address _comicAddress,
        uint256 _index,
        address _user
    )
        public
        view
        returns (bool isPurchased_)
    {
        isPurchased_ = IContent(_comicAddress).isPurchasedEpisode(_index, _user);
    }

    function _getComicRecords (
        address[] _comicAddress
    )
        private
        view
        returns (bytes records_)
    {
        bytes memory start = "[";
        bytes memory end = "]";
        bytes memory separator = ",";
        records_ = records_.concat(start);
        for(uint256 i = 0 ; i < _comicAddress.length ; i++) {
            records_ = records_.concat(bytes(IContent(_comicAddress[i]).getRecord()));
            if(i != _comicAddress.length - 1) {
                records_ = records_.concat(separator);
            }
        }
        records_ = records_.concat(end);
    }

    function _checkWriterContents(
        address _contentsAddress
    )
        private
        view
        returns (bool isRegisterd_)
    {
        address[] memory writerContents = contentsManager.getWriterContentsAddress(msg.sender);

        if(writerContents.length == 0) {
            isRegisterd_ = false;
            return;
        }

        for(uint256 i = 0 ; i < writerContents.length ; i++) {
            if(writerContents[i] == _contentsAddress) {
                isRegisterd_ = true;
                break;
            }
        }
    }

    function _checkAccessRole(
        IContent _content
    )
        private
        view
        returns (bool isAccessible_)
    {
        isAccessible_ = (_content.getWriter() == msg.sender) ? true : false;
    }
}