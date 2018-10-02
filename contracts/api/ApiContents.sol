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

/**
 * @title content API contract
 *
 * @author Charls Kim - <cs.kim@battleent.com>
 */

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
    * @param _record Json string 타입의 작품 세부 정보
    * @param _marketerRate 작품 판매시 마케터에서 분배할 pixel 비율
    */
    function addContents(
        string _record,
        uint256 _marketerRate
    )
        external
        validString(_record)
    {
        require(getInitialDeposit(msg.sender) == council.getInitialDeposit(),
                "Content creation failed: check contents initial deposit amount.");

        require(council.getDepositPool() != address(0),
                "Content creation failed: Piction network error. check council config.");

        string memory writerName;
        bool result;
        (writerName, result) = IAccountManager(council.getAccountManager()).getUserName(msg.sender);

        require(result, "Content creation failed: Please register account.");
        contentsManager.addContents(msg.sender, writerName, _record, _marketerRate);

        address[] memory contentsAddress = getContentsAddress();
        emit RegisterContents(contentsAddress.length.sub(1), contentsAddress[contentsAddress.length.sub(1)], msg.sender, writerName, _record, _marketerRate);
    }

    /**
    * @dev 등록 된 컨텐츠 세부정보와 마케터 비율 조정
    * @param _contentsAddress 작품 주소
    * @param _contentsRecord Json 타입의 수정할 작품 세부 정보
    * @param _marketerRate 작품 판매시 마케터에서 분배할 pixel 비율
    */
    function updateContent(
        address _contentsAddress,
        string _contentsRecord,
        uint256 _marketerRate
    )
        external
        validAddress(_contentsAddress) validString(_contentsRecord)
    {
        require(_checkWriterContents(_contentsAddress),
                "Update contents failed: Unregistered contents address.");

        IContent content = IContent(_contentsAddress);
        require(_checkAccessRole(content), "Update contents failed: Access denied.");

        content.updateContent(_contentsRecord, _marketerRate);

        emit ChangeContent(_contentsAddress, msg.sender, _contentsRecord, _marketerRate);
    }

    /**
    * @dev 작품의 에피소드 등록
    * @param _contentsAddress 작품 주소
    * @param _episodeRecord Json 타입의 에피소드 세부 정보
    * @param _cutUrls 작품 이미지 URL 정보
    * @param _price 에피소드 판매 가격
    */
    function addEpisode(
        address _contentsAddress,
        string _episodeRecord,
        string _cutUrls,
        uint256 _price
    )
        external
        validString(_episodeRecord) validString(_cutUrls)
    {
        require(_checkWriterContents(_contentsAddress),
                "Add episode failed: Unregistered contents address.");

        IContent content = IContent(_contentsAddress);
        require(_checkAccessRole(content), "Add episode failed: Access denied.");

        content.addEpisode(_episodeRecord, _cutUrls, _price);

        emit EpisodeCreation(getEpisodeLength(_contentsAddress).sub(1), _contentsAddress, msg.sender, _episodeRecord, _price);
    }

    /**
    * @dev 에피소드 등록 된 정보 수정
    * @param _contentsAddress 작품 주소
    * @param _index 에피소드 회차(start index : 0)
    * @param _episodeRecord Json 타입의 수정할 에피소드 세부 정보
    * @param _cutUrls 작품 이미지 URL 정보
    * @param _price 에피소드 판매 금액
    */
    function updateEpisode(
        address _contentsAddress,
        uint256 _index,
        string _episodeRecord,
        string _cutUrls,
        uint256 _price
    )
        external
        validString(_episodeRecord) validString(_cutUrls)
    {
        require(_checkWriterContents(_contentsAddress),
                "Update episode failed: Unregistered contents address.");

        IContent content = IContent(_contentsAddress);
        require(_checkAccessRole(content), "Update episode failed: Access denied.");
        require(getEpisodeLength(_contentsAddress) > _index, "Update episode failed: episode index out of range");

        content.updateEpisode(_index, _episodeRecord, _cutUrls, _price);

        emit ChangeEpisode(_index, _contentsAddress, msg.sender, _episodeRecord, _price);
    }

    /**
    * @dev  작품에 대한 좋아요 기능
    * @param _contentsAddress 컨텐츠 주소
    */
    function addPickCount(
        address _contentsAddress
    )
        external
        validAddress(_contentsAddress)
    {
        IContent(_contentsAddress).addPickCount(msg.sender);
    }

    /**
    * @dev 컨텐츠 전체 주소 조회
    * @return contentsAddress_ 컨텐츠 주소 배열
    */
    function getContentsAddress()
        public
        view
        returns (address[] memory contentsAddress_)
    {
        contentsAddress_ = contentsManager.getContentsAddress();
    }

    /**
    * @dev piction network에 등록 된 모든 컨텐츠의 세부정보 조회
    * @return contentsAddress_ 컨텐츠 주소 배열
    * @return records_ bytes로 변환 된 작품 record 정보
    */
    function getContentsFullList()
        external
        view
        returns (address[] memory contentsAddress_, bytes memory records_)
    {
        contentsAddress_ = getContentsAddress();
        if(contentsAddress_.length == 0) {
            return;
        }
        records_ = _getContentsRecord(contentsAddress_);
    }

    /**
    * @dev piction network에 등록 된 컨텐츠 중 특정 작가의 작품 정보 조회
    * @param _writer 찾고자 하는 작가의 계정 주소
    * @return writerContentsAddress_ 컨텐츠 주소 배열
    * @return records_ bytes로 변환 된 작품 record 정보
    */
    function getWriterContentsList(
        address _writer
    )
        external
        view
        returns (address[] memory writerContentsAddress_, bytes memory records_)
    {
        writerContentsAddress_  = getWriterContentsAddress(_writer);
        if(writerContentsAddress_.length == 0) {
            return;
        }
        records_ = _getContentsRecord(writerContentsAddress_);
    }

    /**
    * @dev 컨텐츠 주소를 이용하여 컨텐츠 정보 조회
    * @param _contentsAddress 컨텐츠 주소 배열
    * @return contentsAddress_ 컨텐츠 주소 배열
    * @return records_ bytes로 변환 된 작품 record 정보
    */
    function getContentsRecord(
        address[] _contentsAddress
    )
        external
        view
        returns (address[] memory contentsAddress_, bytes memory records_)
    {
        contentsAddress_ = _contentsAddress;
        records_ = _getContentsRecord(contentsAddress_);
    }

    /**
    * @dev 작가 주소를 이용하여 작가이름(ID) 조회
    * @param _contentsAddress 컨텐츠 주소 배열
    * @return writer_ 작가 주소 배열
    * @return writerName_ bytes로 변환 된 작품의 작가 이름(ID)
    * @return spos_ bytes로 변환 된 writerName_의 start index
    * @return epos_ bytes로 변환 된 writerName_의 end index
    */
    function getContentsWriterName(
        address[] _contentsAddress
    )
        public
        view
        returns (address[] memory writer_, bytes memory writerName_, uint256[] memory spos_, uint256[] memory epos_)
    {
        uint256 contentsLength = _contentsAddress.length;

        writer_ = new address[](contentsLength);
        spos_ = new uint256[](contentsLength);
        epos_ = new uint256[](contentsLength);

        uint256 tempLength;
        for(uint256 i = 0 ; i < contentsLength ; i++) {
            writer_[i] = IContent(_contentsAddress[i]).getWriter();

            bytes memory str = bytes(IContent(_contentsAddress[i]).getWriterName());
            spos_[i] = tempLength;
            writerName_ = writerName_.concat(str);
            tempLength = (tempLength == 0)? tempLength.add((str.length).mul(2).add(2)) : tempLength.add((str.length).mul(2));
            epos_[i] = tempLength;
        }
    }

    /**
    * @dev 에피소드 리스트 정보 조회
    * @param _contentsAddress 작품 컨트랙트 주소
    * @return episodeRecords_ 컨텐츠 주소 배열
    * @return price_ 에피소드 판매 가격
    * @return buyCount_ 해당 에피소드 구매 수
    * @return isPurchased_ 정보를 요청한 유저의 구매 유무
    */
    function getEpisodeFullList(
        address _contentsAddress
    )
        external
        view
        returns (bytes episodeRecords_, uint256[] price_, uint256[] buyCount_, bool[] isPurchased_)
    {
        IContent content = IContent(_contentsAddress);

        if(getEpisodeLength(_contentsAddress) == 0) {
            return;
        }

        uint256 episodeLength = getEpisodeLength(_contentsAddress);
        price_ = new uint256[](episodeLength);
        buyCount_ = new uint256[](episodeLength);
        isPurchased_ = new bool[](episodeLength);

        bytes memory start = "[";
	    bytes memory end = "]";
	    bytes memory separator = ",";

        episodeRecords_ = episodeRecords_.concat(start);
        for(uint256 i = 0 ; i < episodeLength ; i++) {
            bytes memory str;

            (str, price_[i], buyCount_[i], isPurchased_[i])= getEpisodeDetail(_contentsAddress, i, msg.sender);

            episodeRecords_ = episodeRecords_.concat(str);
            if(i != episodeLength - 1) {
                episodeRecords_ = episodeRecords_.concat(separator);
            }
        }
        episodeRecords_ = episodeRecords_.concat(end);
    }

    /**
    * @dev 작품의 이미지 조회
    * @param _contentsAddress 작품 컨트랙트 주소
    * @param _episodeIndex 에피소드 회차
    * @return episodeCuts_ 이미지 url
    */
    function getEpisodeCuts(
        address _contentsAddress,
        uint256 _episodeIndex
    )
        external
        view
        returns (string episodeCuts_)
    {
        IContent content = IContent(_contentsAddress);

        if(isPurchasedEpisode(_contentsAddress, _episodeIndex, msg.sender)) {
            episodeCuts_ = content.getEpisodeCuts(_episodeIndex);
        }
    }

    /**
    * @dev 작품의 좋아요 횟수 조회
    * @param _contentsAddress 작품 컨트랙트 주소
    * @return pickCount_ 좋아요 횟수
    */
    function getPickCount(
        address _contentsAddress
    )
        external
        view
        returns (uint256 pickCount_)
    {
        pickCount_ = IContent(_contentsAddress).getPickCount();
    }

    /**
    * @dev 작가의 작품 주소 조회
    * @param _writerAddress 작품 컨트랙트 주소
    * @return contentsAddress_ 등록 된 작품 주소 목록
    */
    function getWriterContentsAddress(
        address _writerAddress
    )
        public
        view
        returns (address[] contentsAddress_)
    {
        contentsAddress_ = contentsManager.getWriterContentsAddress(_writerAddress);
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
    * @dev 작품의 작가 주소 조회
    * @param _contentsAddress 작품 컨트랙트 주소
    * @return writerAddress_ 작가 주소
    */
    function getWriterAddress(
        address _contentsAddress
    )
        external
        view
        returns (address writerAddress_)
    {
        writerAddress_ = IContent(_contentsAddress).getWriter();
    }

    /**
    * @dev 작품의 세부 정보 조
    * @param _contentsAddress 작품 컨트랙트 주소
    * @return record_ Json 타입의 작품 정보
    * @return writer_ 작가 주소
    * @return writerName_ 작가 이름
    * @return marketerRate_ 마케터 분배 비율
    * @return pickCount_ 좋아요 횟수
    */
    function getContentsDetail(
        address _contentsAddress
    )
        external
        view
        returns (string record_, address writer_, string writerName_, uint256 marketerRate_, uint256 pickCount_)
    {
        (record_, writer_, writerName_, marketerRate_, pickCount_) = IContent(_contentsAddress).getContentDetail();
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

    /**
    * @dev 에피소드 회차 구매 여부 조회
    * @param _contentsAddress 작품 컨트랙트 주소 목록
    * @param _index 에피소드 회차
    * @param _buyer 구매자 주소
    * @return isPurchased_ 구매 여부
    */
    function isPurchasedEpisode(
        address _contentsAddress,
        uint256 _index,
        address _buyer
    )
        public
        view
        returns (bool isPurchased_)
    {
        isPurchased_ = IContent(_contentsAddress).isPurchasedEpisode(_index, _buyer);
    }

    /**
    * @dev 에피소드 상세 정보 조회
    * @param _contentsAddress 작품 컨트랙트 주소 목록
    * @param _index 에피소드 회차
    * @param _buyer 구매자 주소
    * @return record_ Json 타입의 에피소드 정보
    * @return price_ 에피소드 판매 금액
    * @return buyCount_ 구매자 수
    * @return isPurchased_ 구매 여부
    */
    function getEpisodeDetail(
        address _contentsAddress,
        uint256 _index,
        address _buyer
    )
        public
        view
        returns (bytes record_, uint256 price_, uint256 buyCount_, bool isPurchased_)
    {
        (record_, price_, buyCount_, isPurchased_) = IContent(_contentsAddress).getEpisodeDetail(_index, _buyer);
    }

    /**
    * @dev 작품의 세부 정보 문자열을 bytes로 convert하고 각 문자열의 index 정보를 조회하는 내부 함수
    * @param _contentsAddress 작품 컨트랙트 주소 목록
    * @return records_ bytes로 변환 된 작품 record 정보
    */
    function _getContentsRecord(
        address[] _contentsAddress
    )
        private
        view
        returns (bytes records_)
    {
	    bytes memory start = "[";
	    bytes memory end = "]";
	    bytes memory separator = ",";
        records_ = records_.concat(start);
        for(uint256 i = 0 ; i < _contentsAddress.length ; i++) {
            records_ = records_.concat(bytes(IContent(_contentsAddress[i]).getRecord()));
            if(i != _contentsAddress.length - 1) {
                records_ = records_.concat(separator);
            }
        }
        records_ = records_.concat(end);
    }

    /**
    * @dev 컨텐츠 주소가 작가의 주소로 등록 되었는지 확인
    * @param _contentsAddress 작품 컨트랙트 주소
    * @return isRegisterd_ 등록 된 작품 여부
    */
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

    /**
    * @dev 컨텐츠의 수정 권한이 있는지 확인
    * @param _content Content 인터페이스
    * @return isAccessible_ 권한 유무
    */
    function _checkAccessRole(
        IContent _content
    )
        private
        view
        returns (bool isAccessible_)
    {
        isAccessible_ = (_content.getWriter() == msg.sender) ? true : false;
    }

    event RegisterContents(uint256 indexed _contentsIndexId, address indexed _contentsAddress, address indexed _writerAddress, string _writerName, string _record, uint256 _marketerRate);
    event ChangeContent(address indexed _contentAddress, address indexed _writer, string _record, uint256 _marketerRate);
    event EpisodeCreation(uint256 indexed _episodeIndexId, address indexed _contentAddress, address indexed _writer, string _record, uint256 _price);
    event ChangeEpisode(uint256 indexed _episodeIndexId, address indexed _contentAddress, address indexed _writer, string _record, uint256 _price);
}
