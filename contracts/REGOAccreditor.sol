// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./REGORegister.sol";

contract REGOAccreditor is ERC1155, Ownable {
        REGORegsiter public registry;
        // Test
        address address_REGORegister;

        function setAddress(address _address) external {
            address_REGORegister = _address;
        }
        

        // function callRegistry(address _accreditor) external returns(address){
        //     REGORegsiter b = REGORegsiter(address_REGORegister);
        //     return b.registerForIssuingBody(_accreditor);

        // }

        // REGORegistry contract instance
        REGORegsiter public REGORegister;

        // Account address of the accreditor
        address public accreditorAddress;


        // REGO Request mappings
        mapping(uint => requestREGOStruct) public REGORequests;

        // REGO Request ID
        uint REGORequestId;
        

        // requestREGO struct for requester
        struct requestREGOStruct {
            address REGOAccreditor;
            uint technologyGroup;
            bytes REGOdata;
            bool REGOApproved;
            bool REGORejected;
        }

        // https://game.example/api/item/{id}.json
        constructor(address test) ERC1155("GOCertificateDomain/{id}") Ownable() {
            // Sets the address of the owner (accreditor)
            accreditorAddress = msg.sender;
            test = test;
            
            // Map the user address as a REGO Accreditor
            
            // Log accreditor is REGORegsiter 
            registry = REGORegsiter(test);
            registry.registerForIssuingBody(msg.sender);

           
        }

        // function setURI(string memory newuri) public {
        //     _setURI(newuri);
        // }

        function addUserToREGORegistry(address _accreditor) public onlyOwner() {
            // Pseudo-code
            // call GORegistry instance’s function issuingBodyMapping(accountAddress)

            // dc = REGORegsiter(_accreditor);

            // dc.registerForIssuingBody(_accreditor);
            REGORegsiter b = REGORegsiter(_accreditor);
            b.registerForIssuingBody(_accreditor);

        }

        function requestREGO(address applicantAddress, bytes memory REGOdata, uint technologyGroup, uint amountCertificates) public {
            // Pseudo-code
            // create  GORequest object ← ownerAddress, data, energyType
            // GORequestMapping[issuingBodySender] ← storeGORequest object to mapping
            // emit GORequested event ← with GOOwner and id data
            
            /* 
             the production device owner will senda request to a  GOIssuingBody  smart contract specifying the owner address, the GO certificateencoded data, 
             as well as the energy type produced by the production device.

             he energy type is sentas an integer for performance purposes and it is based on the predefined enumerable object, where e.g. 
             0 – represents solar plant power, 1 – represents wind turbine power, 2 – represents hydropower.
             The smart contract will initialize a new GO request object and store it in the smart contract state,in the mapping array data structure.
             The last action to be executed is the emitting of the GORequested event. Eventsare special data types leveraged on EVM logging facilities, and when the event is emitted, 
             it storesthe logs provided as arguments on the blockchain. Therefore, the usability of events is twofold,firstly as logs of the transactions on the blockchain, 
             and secondly as a way for client applicationsto subscribe to certain events and then perform actions based on that event.
            
            */


            // Incrementing request ID
            REGORequestId += 1; 
            

            // REGO Requests structure
            REGORequests[REGORequestId] = requestREGOStruct({
                REGOAccreditor: applicantAddress,
                technologyGroup: technologyGroup,
                REGOdata: REGOdata,
                REGOApproved: false,
                REGORejected: false
            });
            requestREGOStruct storage requestCertificate = REGORequests[REGORequestId];
            // Add confirmation code

            // Mint REGO
            //REGORegister.issueREGOCertificate(requestCertificate.REGOAccreditor, requestCertificate.technologyGroup, requestCertificate.REGOdata, amountCertificates);
            

        }

        function issueREGO(int amount, address REGOReceiver, int energyType, string memory REGOData) public {
            // Pseudo-code
            // createGORequest object ← ownerAddress, data, energyType
            // GORequestMapping[issuingBodySender] ← storeGORequest object to mapping
            // if GORequest already confirmed or withdrawn
            //      revert – this step reverts the state to the one before transaction
            // set GORequest.confirmed ← true
            // set validityFunction ← reference to current Issuing Body function for checking validity of the GO certificate token
            // callGORegistry instance’s function issueGOCertificate(GO_Receiver, energyType, amount, data, validityFunction)

            /* 
            the GORequestObject is created, after which the conditionalcheck is performed to see if the request has been withdrawn or already confirmed.
            If that is the casethe transaction is reverted to the previous state of the smart contract, that existed before the functionwas called.
            If not, the request status is set to confirmed, and the validity function is initializedto the one defined by the GOIssuingBody smart contract.
             This validity function will be encodedin the created GO certificate token, and upon each transaction of the token, the validity function willbe called. This is done because blockchain is immutable 
             so there needs to be a predetermined wayfor Issuing Bodies to manage token validity giving them the option to revoke invalid tokens. It mayhappen that an Issuing Body has performed an audit of a 
             production device and realized that certainproduction parameters have not been satisfied, or that the GO certificate has expired. 
             Based on that,it can call the withdraw function on the blockchain which will invalidate the existing GO certificate.The last statement is the call of the GORegistry function for issuing the GO certificate token.
            */
        }

        

}