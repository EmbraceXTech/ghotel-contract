import { ethers } from "hardhat";
import { Payment, Permit2, TestERC20, TestGho } from "../typechain-types"
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
    })

    it("Should be able to pay", async () => {
        const [signer] = await ethers.getSigners();

        const nonce = Math.floor(Math.random() * Math.pow(10, 10));
        const deadline = Math.floor((new Date().valueOf() + 60 * 60 * 1000) / 1000);
        const network = await signer.provider?.getNetwork();
        const chainId = network?.chainId || 0;

        const amount = ethers.parseEther('10')

        const permit: PermitTransferFrom = {
            permitted: {
                // token we are permitting to be transferred
                token: await testERC20.getAddress(),
                // amount we are permitting to be transferred
                amount: amount,
            },
            // who can transfer the tokens
            spender: await payment.getAddress(),
            nonce,
            // signature deadline
            deadline,
        };

        const { domain, types, values } = SignatureTransfer.getPermitData(
            permit,
            await permit2.getAddress(),
            Number(chainId),
        );

        const signature = await signer.signTypedData({ ...domain, chainId: Number(chainId), salt: undefined }, types, values);

        await testERC20.approve(await permit2.getAddress(), ethers.MaxUint256);
        await payment.pay(signer.address, await testERC20.getAddress(), amount, 0, signer.address, nonce, deadline, signature);

        const lastPayment = await payment.paymentCount();
        const paymentInfo = await payment.getPayment(lastPayment - BigInt(1));
        expect(paymentInfo).to.not.null;
    })

    it("Should be able to pay gho without approve", async () => {
        const [signer] = await ethers.getSigners();

        const nonce = Math.floor(Math.random() * Math.pow(10, 10));
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

        // const abiCoder = new ethers.AbiCoder();

        // console.log({
        //     domain: await testGho.DOMAIN_SEPARATOR(),
        //     computed: ethers.keccak256(abiCoder.encode(['bytes32', 'bytes32', 'bytes32', 'uint256', 'address'], [
        //         ethers.keccak256(abiCoder.encode(['string'], ['EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'])),
        //         ethers.keccak256(abiCoder.encode(['bytes'], [abiCoder.encode(['string'], [tokenName])])),
        //         ethers.keccak256(abiCoder.encode(['string'], ['1'])),
        //         chainId,
        //         ghoAddress
        //     ]))
        // })

        const signature = await signer.signTypedData(domain, types, values);
        const { v, r, s } = ethers.Signature.from(signature);

        const recovered = ethers.verifyTypedData(domain, types, values, { v, r, s });
        console.log(recovered === signer.address);

        await testGho.permit(signer.address, paymentAddress, amount, deadline, v, r, s);

        // await testGho.approve(await permit2.getAddress(), ethers.MaxUint256);
        // await payment.payPermit(signer.address, await testGho.getAddress(), amount, 0, signer.address, { nonce, deadline, signature });

        // const lastPayment = await payment.paymentCount();
        // const paymentInfo = await payment.getPayment(lastPayment - BigInt(1));
        // expect(paymentInfo).to.not.null;
    })

})