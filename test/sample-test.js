const { expect } = require("chai");
const { ethers } = require("hardhat");


// Deployment test
describe("Deployment Registry", function () {
  
  beforeEach(async function () {
      
      /**
       * Deploying ERC-1155 Contract
       */
      // A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts
      REGORegistry = await ethers.getContractFactory("REGORegsiter");
      registry = await REGORegistry.deploy();
      
  });

  //Checking accreditor has been registered
  it("Register role successfully set...", async function () {
      // const [owner] = await ethers.getSigners(); // A Signer in ethers.js is an object that represents an Ethereum account
      const [owner] = await ethers.getSigners();
      //console.log(test)
      expect((await registry.getRole(owner.address))).to.equal(true);
  });

  it("Accreditor has been successfully registered...", async function () {
    // const [owner] = await ethers.getSigners(); // A Signer in ethers.js is an object that represents an Ethereum account
    const [owner] = await ethers.getSigners();
    await registry.registerForIssuingBody(owner.address);
    expect(await registry.isRegisteredAccreditor(owner.address)).to.equal(true);
  });
  
  it("Test Mint Function", async function () {
    // const [owner] = await ethers.getSigners(); // A Signer in ethers.js is an object that represents an Ethereum account
    const [owner] = await ethers.getSigners();
    await registry.registerForIssuingBody(owner.address);
    await registry.issueREGOCertificate(owner.address, "0x00", 9698, "0x00");
    await registry.issueREGOCertificate(owner.address,"0x00", 1, "0x00");
    console.log(await registry.balanceOf(owner.address, 2))
    console.log(await registry.getCertificateId());
    expect(await registry.balanceOf(owner.address, 1)).to.equal(9698);
  });

  it("Test Balance Of Function", async function () {
    // const [owner] = await ethers.getSigners(); // A Signer in ethers.js is an object that represents an Ethereum account
    const [owner] = await ethers.getSigners();
    await registry.registerForIssuingBody(owner.address);
    await registry.issueREGOCertificate(owner.address,"0x00", 9698, "0x00");
    console.log(await registry.getBalance(owner.address, 1));
    expect(await registry.getBalance(owner.address, 1)).to.equal(9698);
  });

  it("Test URI", async function () {
    // const [owner] = await ethers.getSigners(); // A Signer in ethers.js is an object that represents an Ethereum account
    const [owner] = await ethers.getSigners();
    await registry.registerForIssuingBody(owner.address);
    await registry.issueREGOCertificate(owner.address,  "0x00", 9698, "0x00");
    console.log(await registry.getBalance(owner.address, 1));
    console.log(await registry.uri(1))
    expect(await registry.uri(1)).to.equal("0x00");
  });

  it("Test Burn", async function () {
    // const [owner] = await ethers.getSigners(); // A Signer in ethers.js is an object that represents an Ethereum account
    const [owner] = await ethers.getSigners();
    await registry.registerForIssuingBody(owner.address);
    const gas = await registry.issueREGOCertificate(owner.address, "0x00", 2, "hello there");
    
    originalBalance = await registry.getBalance(owner.address, 1);
    burn = await registry.retireREGOCertificate(owner.address, 1, 2);
    newBalance = await registry.getBalance(owner.address, 1);
    console.log("Original Balance", originalBalance)
    console.log("New Balance", newBalance)
    console.log("Test", await registry.getCertificateHolder(1))
    expect(newBalance).to.equal(originalBalance - 2);
  });
  
});