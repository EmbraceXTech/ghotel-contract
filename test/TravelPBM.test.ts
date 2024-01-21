import { ethers } from "hardhat";
import { GovHelper, PBMDistributor, Payment, Permit2, TestERC20, TestGho, TravelLogic, TravelPBM, TravelPBMManager } from "../typechain-types"
import { expect } from "chai";

describe("TravelPBM", () => {

    let permit2: Permit2;
    let payment: Payment;
    let testGho: TestGho;

    let travelLogic: TravelLogic;
    let travelPbmManager: TravelPBMManager;
    let travelPBM: TravelPBM;
    let pbmDistributor: PBMDistributor;
    let govHelper: GovHelper;

    const uri = "https://bafybeih5ij4dbras2du3eq2rbbl54ffzqx5dqghswpqyiarlpcs2psijji.ipfs.nftstorage.link/{id}.json";

    async function deployAll() {
        const [signer] = await ethers.getSigners();

        const permit2Factory = await ethers.getContractFactory("Permit2");
        const paymentFactory = await ethers.getContractFactory("Payment");
        const testGhoFactory = await ethers.getContractFactory("TestGho");

        const travelLogicFactory = await ethers.getContractFactory("TravelLogic");
        const travelPbmManagerFactory = await ethers.getContractFactory("TravelPBMManager");
        const travelPBMFactory = await ethers.getContractFactory("TravelPBM");

        const pbmDistributorFactory = await ethers.getContractFactory("PBMDistributor");
        const govHelperFactory = await ethers.getContractFactory("GovHelper");

        permit2 = await permit2Factory.deploy();
        payment = await paymentFactory.deploy(await permit2.getAddress());
        testGho = await testGhoFactory.deploy(signer.address);

        travelLogic = await travelLogicFactory.deploy(await payment.getAddress());
        travelPbmManager = await travelPbmManagerFactory.deploy();
        travelPBM = await travelPBMFactory.deploy(uri);

        pbmDistributor = await pbmDistributorFactory.deploy();
        govHelper = await govHelperFactory.deploy(await travelPBM.getAddress(), await pbmDistributor.getAddress(), await travelLogic.getAddress());
    }

    async function setup() {
        const [signer, signer2] = await ethers.getSigners();

        const block = await ethers.provider.getBlock("latest");
        const blockTime = block?.timestamp || 0;
        const expiry = blockTime + (365 * 24 * 60);

        await testGho.mint(signer.address, ethers.parseEther("10000000"));
        await testGho.mint(signer2.address, ethers.parseEther("5000"));
        await testGho.approve(await travelPBM.getAddress(), ethers.MaxUint256);

        const travelLogicAddr = await travelLogic.getAddress();
        const travelPBMManagerAddr = await travelPbmManager.getAddress();
        await travelPBM.initialise(await testGho.getAddress(), expiry, travelLogicAddr, travelPBMManagerAddr);

        await travelPbmManager.setPBM(await travelPBM.getAddress());
        await travelPbmManager.createPBMTokenType("Hotel", 1, expiry, uri, 4000)
        await travelPbmManager.createPBMTokenType("Flight", 1, expiry, uri, 4000)
        await travelPbmManager.createPBMTokenType("Food", 1, expiry, uri, 3000)

        await travelLogic.transferOwnership(await govHelper.getAddress());
        await pbmDistributor.transferOwnership(await govHelper.getAddress());
        await travelPBM.safeMintBatch(await pbmDistributor.getAddress(), [0, 1, 2], [ethers.parseEther("400000"), ethers.parseEther("400000"), ethers.parseEther("20000")], ethers.encodeBytes32String(""))
    }

    beforeEach(async () => {
        const [signer] = await ethers.getSigners();

        await deployAll();
        await setup();
    })

    it("Should be able to whitelist travelers and distribute token", async () => {
        const [signer, signer2] = await ethers.getSigners();

        await govHelper.whitelistTravelersAndAirdrop([signer2.address]);

        const balances = await travelPBM.balanceOfBatch([signer2.address, signer2.address, signer2.address], [0, 1, 2]);
        const expectedBalances = [ethers.parseEther('500'), ethers.parseEther('500'), ethers.parseEther('100')]

        for (let i = 0; i < balances.length; i++) {
            expect(balances[i]).to.eq(expectedBalances[i])
        }
    })

    it("Should be able to transfer", async () => {
        const [signer, traveler, ota, hotel] = await ethers.getSigners();

        await govHelper.whitelistTravelersAndAirdrop([traveler.address]);

        const tokenName = await testGho.name();
        const nonce = 0;
        const deadline = Math.floor((new Date().valueOf() + 60 * 60 * 1000) / 1000);
        const network = await traveler.provider?.getNetwork();
        const chainId = Number(network?.chainId || BigInt(0))
        const ghoAddress = await testGho.getAddress();
        const paymentAddress = await payment.getAddress();
        const paymentAmount = ethers.parseEther('60');
        const voucherAmount = ethers.parseEther('40');
        const fee = ethers.parseEther('5');

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
            owner: traveler.address,
            spender: paymentAddress,
            value: paymentAmount,
            nonce: nonce, //you will get once you import the erc20permit contract
            deadline: deadline // future timestamp
        }
        const signature = await traveler.signTypedData(domain, types, values);

        const abiCoder = new ethers.AbiCoder();
        // (address _from, address _to, address _token, uint _amount, uint _fee, address _feeTo, IPayment.Signature memory _sig)
        const data = abiCoder.encode(['address', 'address', 'address', 'uint256', 'uint256', 'address', 'tuple(uint256,uint256,bytes)'], [traveler.address, hotel.address, await testGho.getAddress(), paymentAmount, fee, ota.address, [nonce, deadline, signature]])
        await travelPBM.safeTransferFrom(traveler.address, hotel, 0, voucherAmount, data);

        expect(await testGho.balanceOf(ota.address)).to.eq(fee)
        expect(await testGho.balanceOf(hotel.address)).to.eq(paymentAmount + voucherAmount - fee)
    })

    it("Should be able to unwrap", async () => {

    })

    it("Should be able to revoke", async () => {

    })

    it("Should be able to whitelist", async () => {

    })

    it("Should be able to blacklist", async () => {

    })

    it("Should be able to unwhitelist", async () => {

    })

    it("Should be able to unblacklist", async () => {

    })
})