const ALCHEMY_KEY = process.env.ALCHEMY_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;
const PUBLIC_KEY = process.env.PUBLIC_KEY;

const { ethers } = require("hardhat");
const contractABI = require("../src/artifacts/contracts/REGORegister.sol/REGORegsiter.json");

// REGO Metadata
const application1 = require("../metadata/REGOApplication1.json")
const application2 = require("../metadata/REGOApplication2.json")
const application3 = require("../metadata/REGOApplication3.json")
const application4 = require("../metadata/REGOApplication4.json")
const application5 = require("../metadata/REGOApplication5.json")
const application6 = require("../metadata/REGOApplication6.json")
const application7 = require("../metadata/REGOApplication7.json")
const application8 = require("../metadata/REGOApplication8.json")
const application9 = require("../metadata/REGOApplication9.json")
const application10 = require("../metadata/REGOApplication10.json")

const IPFS = require('ipfs-api');
// Instance of ipfs api
const ipfs = new IPFS({host: 'ipfs.infura.io', port: 5001, protocol: 'https'});

// Alchemy provider
const provider = new ethers.providers.AlchemyProvider(network="rinkeby", ALCHEMY_KEY);

// signer from MetaMask
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

// REGO Register Contract Instance
const REGORegister = new ethers.Contract(CONTRACT_ADDRESS, contractABI.abi, signer);

let ipfsHash = {
    IPFSHash: "",

    get hash() {
        return this.IPFSHash;
    },

    set hash(hash) {
        this.ipfs = hash;
    }
}

// Retrieve values from JSON file
function readREGOJSON(application) {
    let results = [];
    let t = 0;
    for (let z = 0; z < 1; z++) {
      //console.log(z)
      let res = Object.values(application);
      res.map((x, i) => {
        //console.log(i)
        if (res[i] !== undefined) {
          

          results.push(x)
          
          return results;   
        }
      })
    }
    //console.log(results)
    return results;
  }

// IPFS
function uploadToIPFS(application) {
    var applicationArray = readREGOJSON(application);
    var applicationDict = applicationArray[0];
    const REGOAmt = applicationDict["Requested_Amt"];
    console.log("Application One Test", REGOAmt)
    var myJsonString = JSON.stringify(applicationArray);

    ipfs.files.add(Buffer.from(myJsonString), (err, result) => {
      if (err) {
        console.log(err);
        return;
      }
      
      var hash = result[0].hash;
      console.log(JSON.stringify({hash}))
      ipfsHash.hash = hash;
      
      
    })
    return REGOAmt;
}

async function main() {

  let option = 1;

   if (await REGORegister.isRegisteredAccreditor(PUBLIC_KEY) == false) {
       // Register address as REGO Accreditor
       try {
        const register =  await REGORegister.registerREGOAccreditor(PUBLIC_KEY); 
       } catch (err) {
          console.log(err);
       }
        

   }

   if (await REGORegister.getREGOApplicant(PUBLIC_KEY) == false) {
       // Log the applicant address to Smart Contract, logApplicant(applicantAddress, accreditorAddress)
       try {
        const log = await REGORegister.logApplicant(PUBLIC_KEY, PUBLIC_KEY);
       } catch(err) {
        console.log(err);
       }
   }
   else {

      switch (option) {
        case 0:
          // Mint REGOs
          // REGO data to IPFS, returning hash and Amount of REGOs to be minted
          let REGOAmt = uploadToIPFS(application10);
          const REGOAmtInt = parseInt(REGOAmt);
        
          console.log(ipfsHash.IPFSHash);
          
          try {
            // Request REGOs to be minted
            const mint = await REGORegister.issueREGOCertificate(PUBLIC_KEY, "0x00", 1, ipfsHash.IPFSHash, PUBLIC_KEY);
            await mint.wait();

          } catch(err) {
            console.log(err);
          }
          
          break;
        
        case 1:
          try {

          // Check balance 
          const balance = await REGORegister.balanceOf(PUBLIC_KEY, 26);
         
          console.log(balance);

          } catch(err) {
            console.log(err);
          }
          
          break;
        
        case 2:
            try {
              // Retire REGOs
              const burn = await REGORegister.retireREGOCertificate(PUBLIC_KEY, 26, 1, PUBLIC_KEY);
              await burn.wait();
              
             
            } catch(err) {
              console.log(err);
            }

          break;
        case 3:
          try {
            // Transfer REGOs
            const transfer = await REGORegister.transferREGOCertificate(PUBLIC_KEY, "0x18C9C8299639fF4C4Ec4D0CCdEaa928fdA6fDeeD", 12, 3000, "0x00", "hash")
            await transfer.wait();

          } catch(err) {
             console.log(err);
          }
        
          default:
            return "Invalid Option";

      }

   }

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });