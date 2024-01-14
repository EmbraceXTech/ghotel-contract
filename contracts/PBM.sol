// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IPBM.sol";

contract PBM is IPBM {
    function initialise(
        address _sovToken,
        uint256 _expiry,
        address _pbmLogic,
        address _pbmTokenManager
    ) external override {}

    function uri(
        uint256 tokenId
    ) external view override returns (string memory) {}

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
    ) external override {}

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external override {}

    function unwrap(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external override {}

    function revokePBM(uint256 tokenId) external override {}
}
