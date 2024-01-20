// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

interface ITravelLogic {
    function whitelistAddresses(uint256 _tokenId, address[] memory addresses, string memory metadata) external;
    function unWhitelistAddresses(uint256 _tokenId, address[] memory addresses, string memory metadata) external;
    function blacklistAddresses(uint256 _tokenId, address[] memory addresses, string memory metadata) external;
    function unBlacklistAddresses(uint256 _tokenId, address[] memory addresses, string memory metadata) external;

    function isBlacklisted(uint256 _tokenId,  address _address) external returns (bool bool_);
    function isMerchant(uint256 _tokenId, address _address) external returns (bool bool_);

    event MerchantList(string action, uint256 _tokenId, address[] addresses, string metadata);
    event Blacklist(string action, uint256 _tokenId, address[] addresses, string metadata);
}
