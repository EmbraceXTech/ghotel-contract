// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPayment {
    struct Pay {
        uint id;
        uint timestamp;
        address from;
        address to;
        address token;
        uint amount;
        uint fee;
        address feeTo;
    }

    struct Signature {
        uint nonce;
        uint deadline;
        bytes signature;
    }

    function pay(
        address _from,
        address _to,
        address _token,
        uint _amount,
        uint _fee,
        address _feeTo,
        Signature memory _sig
    ) external returns (uint);

    function payPermit(
        address _from,
        address _to,
        address _token,
        uint _amount,
        uint _fee,
        address _feeTo,
        Signature memory _sig
    ) external returns (uint);

    function getPayment(uint id) external view returns (Pay memory);
}
