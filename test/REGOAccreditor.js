const { expect } = require("chai");
const { ethers } = require("hardhat");

// Deployment test
describe("Deployment", function () {
    
    before(async function () {
        // A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts
        REGOAccreditor = await ethers.getContractFactory("REGOAccreditor");
        accreditor = await REGOAccreditor.deploy()
    
        
        // Deploy contract
        await accreditor.deployed()
    });

    // Checking accreditor has been registered
    // it("Accreditor has been successfully registered...", async function () {
    //     // const [owner] = await ethers.getSigners(); // A Signer in ethers.js is an object that represents an Ethereum account
    //     expect((await accreditor.));
    // });
});


