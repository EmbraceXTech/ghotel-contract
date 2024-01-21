import { ethers } from "hardhat";
import { Payment, Permit2, TestERC20, TestERC20Permit, TestGho } from "../typechain-types"
import {
    PermitTransferFrom,
    SignatureTransfer,
} from '@uniswap/permit2-sdk';
import { expect } from "chai";

describe("Payment", () => {

    let testERC20: TestERC20;
    let testGho: TestGho;
    let permit2: Permit2;
    let payment: Payment;

    async function deployAll() {
        const testERC20Factory = await ethers.getContractFactory("TestERC20");
        const testGhoFactory = await ethers.getContractFactory("TestGho");
        const permit2Factory = await ethers.getContractFactory("Permit2");
        const paymentFactory = await ethers.getContractFactory("Payment");

        testERC20 = await testERC20Factory.deploy()
        testGho = await testGhoFactory.deploy(await testERC20.getAddress());
        permit2 = await permit2Factory.deploy()
        payment = await paymentFactory.deploy(await permit2.getAddress());
    }

    beforeEach(async () => {
        const [signer] = await ethers.getSigners();

        await deployAll();
        await testERC20.mint(signer, ethers.parseEther("1000000"));
        await testGho.mint(signer, ethers.parseEther("1000000"));
    })

    it("Should be able to pay legal token with permit2", async () => {
        const [signer, signer2, signer3] = await ethers.getSigners();

        const nonce = Math.floor(Math.random() * Math.pow(10, 10));
        const deadline = Math.floor((new Date().valueOf() + 60 * 60 * 1000) / 1000);
        const network = await signer.provider?.getNetwork();
        const chainId = network?.chainId || 0;

        const amount = ethers.parseEther('10');

        const tokenAddress = await testERC20.getAddress();
        const paymentAddress = await payment.getAddress();
        const permit2Address = await permit2.getAddress();

        const permit: PermitTransferFrom = {
            permitted: {
                // token we are permitting to be transferred
                token: tokenAddress,
                // amount we are permitting to be transferred
                amount: amount,
            },
            // who can transfer the tokens
            spender: paymentAddress,
            nonce,
            // signature deadline
            deadline,
        };

        const { domain, types, values } = SignatureTransfer.getPermitData(
            permit,
            permit2Address,
            Number(chainId),
        );

        const signature = await signer.signTypedData({ ...domain, chainId: Number(chainId), salt: undefined }, types, values);

        await testERC20.approve(permit2Address, ethers.MaxUint256);
        await payment.connect(signer2).pay(signer.address, signer2.address, tokenAddress, amount, 0, signer3.address, { nonce, deadline, signature });

        const lastPayment = await payment.paymentCount();
        const paymentInfo = await payment.getPayment(lastPayment - BigInt(1));
        expect(paymentInfo.amount).to.eq(amount)
    })

    it("Should be able to pay gho without approve", async () => {
        const [signer, signer2, signer3] = await ethers.getSigners();

        const nonce = 0;
        const deadline = Math.floor((new Date().valueOf() + 60 * 60 * 1000) / 1000);
        const network = await signer.provider?.getNetwork();
        const chainId = Number(network?.chainId || BigInt(0))

        const ghoAddress = await testGho.getAddress();
        const paymentAddress = await payment.getAddress();

        const amount = ethers.parseEther('10');

        const tokenName = await testGho.name();

        const domain = {
            name: tokenName,
            version: "1",
            chainId: chainId,
            verifyingContract: ghoAddress,

        }

        const types = {
            Permit: [
                { name: 'owner', type: 'address' },
                { name: 'spender', type: 'address' },
                { name: 'value', type: 'uint256' },
                { name: 'nonce', type: 'uint256' },
                { name: 'deadline', type: 'uint256' }
            ],
        }

        const values = {
            owner: signer.address,
            spender: paymentAddress,
            value: amount,
            nonce: nonce, //you will get once you import the erc20permit contract
            deadline: deadline // future timestamp
        }

        const signature = await signer.signTypedData(domain, types, values);

        await payment.payPermit(signer.address, signer2.address, ghoAddress, amount, 0, signer3.address, { nonce, deadline, signature });

        const lastPayment = await payment.paymentCount();
        const paymentInfo = await payment.getPayment(lastPayment - BigInt(1));
        expect(paymentInfo.amount).to.eq(amount)
    })

})