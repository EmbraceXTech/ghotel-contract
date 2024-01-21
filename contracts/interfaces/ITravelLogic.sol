// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

interface ITravelLogic {
    function whitelistTravelers(address[] memory addresses) external;
    function unWhitelistTravelers(address[] memory addresses) external;
    function whitelistMerchants(uint256 _tokenId, address[] memory addresses) external;
    function unWhitelistMerchants(uint256 _tokenId, address[] memory addresses) external;
    function blacklistAddresses(address[] memory addresses) external;
    function unBlacklistAddresses(address[] memory addresses) external;

    function isTraveler(address _address) external returns (bool bool_);
    function isMerchant(uint256 _tokenId, address _address) external returns (bool bool_);
    function isBlacklisted(address _address) external returns (bool bool_);

    event TravelerList(string action, address[] addresses);
    event MerchantList(string action, uint256 _tokenId, address[] addresses);
    event Blacklist(string action, address[] addresses);
}
