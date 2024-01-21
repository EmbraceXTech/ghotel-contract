// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IPBM.sol";
import "./PBMDistributor.sol";
import "./interfaces/ITravelLogic.sol";

contract GovHelper is Ownable {
    uint256[] public ids = [0, 1, 2];
    uint256[] public amounts = [500 * 1e18, 500 * 1e18, 100 * 1e18];

    address public pbm;
    PBMDistributor distributor;
    ITravelLogic logic;

    constructor(
        address _pbm,
        PBMDistributor _distributor,
        ITravelLogic _logic
    ) Ownable(msg.sender) {
        pbm = _pbm;
        distributor = _distributor;
        logic = _logic;
    }

    function whitelistTravelersAndAirdrop(
        address[] memory _travelers
    ) external onlyOwner {
        for (uint i = 0; i < _travelers.length; i++) {
            distributor.distributePBM(_travelers[i], pbm, ids, amounts, "");
        }
        logic.whitelistTravelers(_travelers);
    }

    function whitelistTravelers(
        address[] memory _travelers
    ) external onlyOwner {
        logic.whitelistTravelers(_travelers);
    }

    function unWhitelistTravelers(
        address[] memory _travelers
    ) external onlyOwner {
        logic.unWhitelistTravelers(_travelers);
    }

    function whitelistMerchants(
        uint256 _tokenId,
        address[] memory _merchants
    ) external onlyOwner {
        logic.whitelistMerchants(_tokenId, _merchants);
    }

    function blacklistAddresses(
        address[] memory _addresses
    ) external onlyOwner {
        logic.blacklistAddresses(_addresses);
    }

    function unBlacklistAddresses(
        address[] memory _addresses
    ) external onlyOwner {
        logic.unBlacklistAddresses(_addresses);
    }
}
