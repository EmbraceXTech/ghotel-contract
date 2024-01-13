// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

// The EIP-165 identifier of this interface is 0xf4cedd5a
interface IERC5679Ext1155 {
    function safeMint(
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    ) external;

    function safeMintBatch(
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function burn(
        address _from,
        uint256 _id,
        uint256 _amount,
        bytes[] calldata _data
    ) external;

    function burnBatch(
        address _from,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata _data
    ) external;
}
