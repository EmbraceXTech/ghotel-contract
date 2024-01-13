// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IPBMTokenManager.sol";

contract PBMTokenManager is IPBMTokenManager {
    function createPBMTokenType(
        string memory _name,
        uint256 _faceValue,
        uint256 _tokenExpiry,
        string memory _tokenURI
    ) external virtual override returns (uint256 tokenId_) {}

    function getTokenDetails(
        uint256 tokenId
    ) external view virtual override returns (PBMToken memory pbmToken_) {
        return tokenTypes[tokenId];
    }
}
