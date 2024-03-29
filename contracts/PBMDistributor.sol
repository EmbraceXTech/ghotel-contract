// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "./interfaces/IPBM.sol";

contract PBMDistributor is Ownable, IERC1155Receiver {
    constructor() Ownable(msg.sender) {}

    function distributePBM(
        address _to,
        address _token,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes calldata _data
    ) external onlyOwner {
        IPBM(_token).safeBatchTransferFrom(
            address(this),
            _to,
            _ids,
            _amounts,
            _data
        );
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external view returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }
}
