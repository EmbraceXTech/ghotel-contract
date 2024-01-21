// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/ITravelLogic.sol";
import "./interfaces/IPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TravelLogic is ITravelLogic, Ownable {
    mapping(address => bool) internal blackList;
    mapping(address => bool) internal travelerList;
    mapping(uint256 => mapping(address => bool)) internal merchantList;

    IPayment public payment;

    constructor(IPayment _payment) Ownable(msg.sender) {
        payment = _payment;
    }

    function whitelistTravelers(
        address[] memory _addresses
    ) external override onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            travelerList[_addresses[i]] = true;
        }
        emit TravelerList("add", _addresses);
    }

    function unWhitelistTravelers(
        address[] memory _addresses
    ) external override onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            travelerList[_addresses[i]] = false;
        }
        emit TravelerList("remove", _addresses);
    }

    function whitelistMerchants(
        uint256 _tokenId,
        address[] memory _addresses
    ) external override onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            merchantList[_tokenId][_addresses[i]] = true;
        }
        emit MerchantList("add", _tokenId, _addresses);
    }

    function unWhitelistMerchants(
        uint256 _tokenId,
        address[] memory _addresses
    ) external override onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            merchantList[_tokenId][_addresses[i]] = false;
        }
        emit MerchantList("remove", _tokenId, _addresses);
    }

    function blacklistAddresses(
        address[] memory _addresses
    ) external override onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            blackList[_addresses[i]] = true;
        }
        emit Blacklist("add", _addresses);
    }

    function unBlacklistAddresses(
        address[] memory _addresses
    ) external override onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            blackList[_addresses[i]] = false;
        }
        emit Blacklist("remove", _addresses);
    }

    function isBlacklisted(
        address _address
    ) external view override returns (bool bool_) {
        return blackList[_address];
    }

    function isTraveler(
        address _address
    ) external view override returns (bool bool_) {
        return travelerList[_address] && !blackList[_address];
    }

    function isMerchant(
        uint256 _tokenId,
        address _address
    ) external view override returns (bool bool_) {
        return merchantList[_tokenId][_address] && !blackList[_address];
    }
}
