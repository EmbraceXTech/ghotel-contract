// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IPermit2.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

contract Payment {

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

    IPermit2 public immutable permit2;
    uint public paymentCount;
    Pay[] public paymentList;

    constructor(IPermit2 _permit2) {
        permit2 = _permit2;
    }

    function pay(address _to, address _token, uint _amount, uint _fee, address _feeTo, uint _nonce, uint _deadline, bytes calldata _signature) external returns (uint) {
        uint id = paymentCount++;
        paymentList.push(Pay(id, block.timestamp, msg.sender, _to, _token, _amount, _fee, _feeTo));

        // IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        permit2.permitTransferFrom(
            // The permit message.
            ISignatureTransfer.PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({
                    token: _token,
                    amount: _amount
                }),
                nonce: _nonce,
                deadline: _deadline
            }),
            // The transfer recipient and amount.
            ISignatureTransfer.SignatureTransferDetails({
                to: address(this),
                requestedAmount: _amount
            }),
            // The owner of the tokens, which must also be
            // the signer of the message, otherwise this call
            // will fail.
            msg.sender,
            // The packed signature that was the result of signing
            // the EIP712 hash of `permit`.
            _signature
        );
        IERC20(_token).transfer(_feeTo, _fee);
        IERC20(_token).transfer(_to, _amount - _fee);

        return id;
    }

    function payPermit(address _to, address _token, uint _amount, uint _fee, address _feeTo, Signature memory _permitS) external returns (uint) {
        uint id = paymentCount++;
        paymentList.push(Pay(id, block.timestamp, msg.sender, _to, _token, _amount, _fee, _feeTo));

        (uint8 vPermit, bytes32 rPermit, bytes32 sPermit) = splitSignature(_permitS.signature);
        IERC20Permit(_token).permit(msg.sender, address(this), _amount, _permitS.deadline, vPermit, rPermit, sPermit);

        // IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        // permit2.permitTransferFrom(
        //     // The permit message.
        //     ISignatureTransfer.PermitTransferFrom({
        //         permitted: ISignatureTransfer.TokenPermissions({
        //             token: _token,
        //             amount: _amount
        //         }),
        //         nonce: _nonce,
        //         deadline: _deadline
        //     }),
        //     // The transfer recipient and amount.
        //     ISignatureTransfer.SignatureTransferDetails({
        //         to: address(this),
        //         requestedAmount: _amount
        //     }),
        //     // The owner of the tokens, which must also be
        //     // the signer of the message, otherwise this call
        //     // will fail.
        //     msg.sender,
        //     // The packed signature that was the result of signing
        //     // the EIP712 hash of `permit`.
        //     _signature
        // );
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        IERC20(_token).transfer(_feeTo, _fee);
        IERC20(_token).transfer(_to, _amount - _fee);

        return id;
    }

    function getPayment(uint id) external view returns (Pay memory) {
        return paymentList[id];
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

}
