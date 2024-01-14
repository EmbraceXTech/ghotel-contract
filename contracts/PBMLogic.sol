// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IPBMAddressList.sol";

contract PBMLogic is IPBMAddressList {
    mapping(address => bool) internal blackList;
    mapping(address => bool) internal merchantList;

    function whitelistAddresses(
        address[] memory _addresses,
        string memory metadata
    ) external {
        for (uint256 i = 0; i < _addresses.length; i++) {
            merchantList[_addresses[i]] = true;
        }
        emit MerchantList("add", _addresses, metadata);
    }

    function unWhitelistAddresses(
        address[] memory _addresses,
        string memory metadata
    ) external {
        for (uint256 i = 0; i < _addresses.length; i++) {
            merchantList[_addresses[i]] = false;
        }
        emit MerchantList("remove", _addresses, metadata);
    }

    function blacklistAddresses(
        address[] memory _addresses,
        string memory metadata
    ) external {
        for (uint256 i = 0; i < _addresses.length; i++) {
            blackList[_addresses[i]] = true;
        }
        emit Blacklist("add", _addresses, metadata);
    }

    function unBlacklistAddresses(
        address[] memory _addresses,
        string memory metadata
    ) external {
        for (uint256 i = 0; i < _addresses.length; i++) {
            blackList[_addresses[i]] = false;
        }
        emit Blacklist("remove", _addresses, metadata);
    }

    function isBlacklisted(
        address _address
    ) external view override returns (bool bool_) {
        return blackList[_address];
    }

    function isMerchant(
        address _address
    ) external view override returns (bool bool_) {
        return merchantList[_address] && !blackList[_address];
    }
}
