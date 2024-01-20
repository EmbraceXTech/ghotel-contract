// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/ITravelLogic.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TravelLogic is ITravelLogic, Ownable {
    mapping(uint256 => mapping(address => bool)) internal blackList;
    mapping(uint256 => mapping(address => bool)) internal merchantList;

    constructor() Ownable(msg.sender) {}

    function whitelistAddresses(
        uint256 _tokenId, 
        address[] memory _addresses,
        string memory metadata
    ) external override onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            merchantList[_tokenId][_addresses[i]] = true;
        }
        emit MerchantList("add", _tokenId, _addresses, metadata);
    }

    function unWhitelistAddresses(
        uint256 _tokenId, 
        address[] memory _addresses,
        string memory metadata
    ) external override onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            merchantList[_tokenId][_addresses[i]] = false;
        }
        emit MerchantList("remove", _tokenId, _addresses, metadata);
    }

    function blacklistAddresses(
        uint256 _tokenId,
        address[] memory _addresses,
        string memory metadata
    ) external override onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            blackList[_tokenId][_addresses[i]] = true;
        }
        emit Blacklist("add", _tokenId, _addresses, metadata);
    }

    function unBlacklistAddresses(
        uint256 _tokenId,
        address[] memory _addresses,
        string memory metadata
    ) external override onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            blackList[_tokenId][_addresses[i]] = false;
        }
        emit Blacklist("remove", _tokenId, _addresses, metadata);
    }

    function isBlacklisted(
        uint256 _tokenId,
        address _address
    ) external view override returns (bool bool_) {
        return blackList[_tokenId][_address];
    }
    
    function isMerchant(
        uint256 _tokenId,
        address _address
    ) external view override returns (bool bool_) {
        return merchantList[_tokenId][_address] && !blackList[_tokenId][_address];
    }
}
