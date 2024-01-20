// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./interfaces/IPBM.sol";

contract PBM is ERC1155, IPBM {
    address private _owner;

    constructor() ERC1155("") {}

    function initialise(
        address _sovToken,
        uint256 _expiry,
        address _pbmLogic,
        address _pbmTokenManager
    ) external override {}

    function uri(
        uint256 tokenId
    ) public view override(ERC1155, IPBM) returns (string memory) {
        return "";
    }

    function safeMint(
        address receiver,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external override {}

    function safeMintBatch(
        address receiver,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) external override {}

    function burn(
        address from,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external override {}

    function burnBatch(
        address from,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) external override {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override(ERC1155, IPBM) {}

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override(ERC1155, IPBM) {}

    function unwrap(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external override {}

    function revokePBM(uint256 tokenId) external override {}

    function owner() external view override returns (address) {
        return _owner;
    }

    function transferOwnership(address _newOwner) external override {
        _owner = _newOwner;
    }
}
