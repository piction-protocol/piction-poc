pragma solidity ^0.4.24;

import "contracts/interface/ICouncil.sol";
import "contracts/interface/IContent.sol";
import "contracts/interface/IReport.sol";

import "contracts/utils/ValidValue.sol";
import "contracts/utils/ExtendsOwnable.sol";
import "contracts/utils/BytesLib.sol";

contract Api is ValidValue, ExtendsOwnable {
    using BytesLib for bytes;

    //위원회
    ICouncil council;

    constructor(address _councilAddress) public validAddress(_councilAddress) {
        council = ICouncil(_councilAddress);
    }

    /**
    * @dev 컨텐츠의 주소 배열로 컨텐츠 내용을 records에 담아 회신한다
    * @param contents 컨텐츠 주소 목록
    */
    function getContentRecord(address[] contents) external view returns(bytes memory records, uint256[] memory spos, uint256[] memory epos) {
        uint tempLength;
        uint index;

        for(uint i = 0; i < contents.length; i++) {
            bytes memory str = bytes(IContent(contents[i]).getRecord());
            spos[index] = tempLength;
            records = records.concat(str);
            tempLength = (tempLength == 0)? tempLength = tempLength + ((str.length * 2) + 2): tempLength = tempLength + (str.length * 2);
            epos[index] = tempLength;
        }
    }

    /**
    * @dev 신고 목록의 id 값으로 처리여부, 처리 결과, 토큰량을 회신한다
    * @param ids 신고 id 목록
    */
    function getReportResult(uint256[] ids) external view returns(bool[] memory complete, bool[] memory completeValid, uint256[] memory completeAmount) {
        complete = new bool[](ids.length);
        completeValid = new bool[](ids.length);
        completeAmount = new uint256[](ids.length);

        for(uint i = 0; i < ids.length; i++) {
            (,,,complete[i], completeValid[i], completeAmount[i]) = IReport(council.getReport()).getReport(ids[i]);
        }
    }
}
