// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IPBM.sol";

contract PBMDistributor is Ownable {

    constructor() Ownable(msg.sender) {}

    function distributePBM(address _to, address _token, uint256[] memory _ids, uint256[] memory _amounts, bytes calldata _data) external onlyOwner {
        IPBM(_token).safeBatchTransferFrom(address(this), _to, _ids, _amounts, _data);
    }
}
