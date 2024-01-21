// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract TestERC20Permit is ERC20Permit {
    
    constructor() ERC20Permit("Test Permit") ERC20("Test Permit", "TESTP")  {}

    function mint(address _to, uint _amount) public {
        _mint(_to, _amount);
    }
}
