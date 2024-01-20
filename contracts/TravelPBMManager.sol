// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/ITravelPBMManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TravelPBMManager is ITravelPBMManager, Ownable {

    uint256 totalTokenType;

    constructor() Ownable(msg.sender) {}

    function getTokenDetails(
        uint256 tokenId
    ) public view virtual override returns (PBMToken memory pbmToken_) {
        return tokenTypes[tokenId];
    }

    function createPBMTokenType(
        string memory _name,
        uint256 _faceValue,
        uint256 _tokenExpiry,
        string memory _tokenURI, // "https://bafybeihidh7z4tgengyhu7qwmden6e4dzy42tds7h2jd7hsbozakpedh5i.ipfs.nftstorage.link/{id}.json";
        uint256 _percentSupport
    ) external virtual override onlyOwner returns (uint256 tokenId_) {
        tokenId_ = totalTokenType++;
        require(
            _tokenExpiry > block.timestamp,
            "PBMTokenManager: token expiry must be in the future"
        );
        require(_faceValue > 0, "_faceValue cannot be 0");
        tokenTypes[tokenId_] = PBMToken({
            name: _name,
            faceValue: _faceValue,
            expiry: _tokenExpiry,
            uri: _tokenURI,
            totalSupply: 0,
            percentSupport: _percentSupport
        });
        emit NewPBMTypeCreated(
            tokenId_,
            _name,
            _faceValue,
            _tokenExpiry,
            msg.sender
        );
    }

    function increaseTotalSupply(uint256 tokenId, uint256 amount) external override {
        tokenTypes[tokenId].totalSupply += amount;
    }

    function decreaseTotalSupply(uint256 tokenId, uint256 amount) external override {
        tokenTypes[tokenId].totalSupply -= amount;
    }

    function pbmToSov(uint256 tokenId, uint256 pbmAmount) external override view returns (uint256) {
        PBMToken memory _pbm = getTokenDetails(tokenId);
        return pbmAmount * _pbm.faceValue;
    }

    function sovToPBM(uint256 tokenId, uint256 sovAmount) external override view returns (uint256) {
        PBMToken memory _pbm = getTokenDetails(tokenId);
        return sovAmount * _pbm.faceValue;
    }

}
