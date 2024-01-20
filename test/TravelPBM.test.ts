import { ethers } from "hardhat";
import { TestERC20, TravelLogic, TravelPBM, TravelPBMManager } from "../typechain-types"
import { expect } from "chai";

describe("TravelPBM", () => {

    let testERC20: TestERC20;
    let travelLogic: TravelLogic;
    let travelPbmManager: TravelPBMManager;
    let travelPBM: TravelPBM;

    const uri = "https://bafybeihidh7z4tgengyhu7qwmden6e4dzy42tds7h2jd7hsbozakpedh5i.ipfs.nftstorage.link/{id}.json";


    async function deployAll() {
        const testERC20Factory = await ethers.getContractFactory("TestERC20");
        const travelLogicFactory = await ethers.getContractFactory("TravelLogic");
        const travelPbmManagerFactory = await ethers.getContractFactory("TravelPBMManager");
        const travelPBMFactory = await ethers.getContractFactory("TravelPBM");

        testERC20 = await testERC20Factory.deploy();
        travelLogic = await travelLogicFactory.deploy();
        travelPbmManager = await travelPbmManagerFactory.deploy();
        travelPBM = await travelPBMFactory.deploy(uri);

        const block = await ethers.provider.getBlock("latest");
        const blockTime = block?.timestamp || 0;
        const expiry = blockTime + (365 * 24 * 60);

        const erc20Addr = await testERC20.getAddress();
        const travelLogicAddr = await travelLogic.getAddress();
        const travelPBMManagerAddr = await travelPbmManager.getAddress();

        await travelPBM.initialise(erc20Addr, expiry, travelLogicAddr, travelPBMManagerAddr);
    }

    beforeEach(async () => {
        const [signer] = await ethers.getSigners();

        await deployAll();
        await testERC20.mint(signer, ethers.parseEther("1000000"));
    })

    it("Should be able to mint", async () => {
        const [signer] = await ethers.getSigners();

        const block = await ethers.provider.getBlock("latest");
        const blockTime = block?.timestamp || 0;
        const expiry = blockTime + (365 * 24 * 60);

        await travelPbmManager.createPBMTokenType("Hotel", 1, expiry, uri, 4000);
        await testERC20.approve(await travelPBM.getAddress(), ethers.MaxUint256);
        await travelPBM.safeMint(signer.address, 0, ethers.parseEther("10"), ethers.encodeBytes32String(""));

        expect(await travelPBM.balanceOf(signer.address, 0)).eq(ethers.parseEther("10").toString())
    })

    it("Should be able to transfer", async () => {

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