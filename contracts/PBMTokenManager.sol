// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IPBMTokenManager.sol";

contract PBMTokenManager is IPBMTokenManager {
    function getTokenDetails(
        uint256 tokenId
    ) external view virtual override returns (PBMToken memory pbmToken_) {
        return tokenTypes[tokenId];
    }

    function createPBMTokenType(
        string memory _name,
        uint256 _faceValue,
        uint256 _tokenExpiry,
        string memory _tokenURI
    ) external virtual override returns (uint256 tokenId_) {
        tokenId_ = uint256(
            keccak256(
                abi.encodePacked(_name, _faceValue, _tokenExpiry, _tokenURI)
            )
        );
        require(
            _tokenExpiry > block.timestamp,
            "PBMTokenManager: token expiry must be in the future"
        );
        tokenTypes[tokenId_] = PBMToken({
            name: _name,
            faceValue: _faceValue,
            expiry: _tokenExpiry,
            uri: _tokenURI,
            totalSupply: 0
        });
        emit NewPBMTypeCreated(
            tokenId_,
            _name,
            _faceValue,
            _tokenExpiry,
            msg.sender
        );
    }

    function increaseTotalSupply(uint256 tokenId, uint256 amount) external {
        tokenTypes[tokenId].totalSupply += amount;
    }

    function decreaseTotalSupply(uint256 tokenId, uint256 amount) external {
        tokenTypes[tokenId].totalSupply -= amount;
    }
}
