// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract REGORegsiter is ERC1155, Ownable, ERC1155Burnable {

     
        // IPFS Hash to save reference of file from IPFS
        string ipfsHash;

        event GrantRole(bytes32 role, address account);

        bytes32 private constant REGOREGISTER = keccak256(abi.encodePacked("REGOREGISTER"));
        mapping(bytes32 => mapping(address => bool)) public roles;
        
        

        // Certificate mapping
        mapping(uint => REGOCertificateStruct) public REGOCertificate;


       

        // Certificate unique id
        uint certificateId = 0;


        // Certificate struct
        struct REGOCertificateStruct {
            address certificateHolder;
            address certificateIssuer;
            // uint technologyGroup;
            // uint REGOId;
            string REGOData;
        }

        // function getStruct() public view returns(bytes32[]) {
        //     return REGOCertificate[msg.sender].REGOData;
        // }

        function getCertificateId() public view returns (uint) {
            return certificateId;
        }

        function getCertificateHolder(uint _certificateId) external view returns (address) {
            return REGOCertificate[_certificateId].certificateHolder;
        }

        function getRole(address _account) public view returns(bool) {
            return roles[REGOREGISTER][_account];
        }

        function isRegisteredAccreditor(address _account) public view returns(bool) {
            return accreditor[_account];
        }
        
        function _grantRole(bytes32 _role, address _account) internal {
            roles[_role][_account] = true;
            emit GrantRole(_role, _account);

        }

        function grantRole(bytes32 _role,  address _account) external onlyRole(REGOREGISTER) {
            _grantRole(_role, _account);
        }

        // function certificateToStruct(address _certificateHolder, bytes _REGOData) external {
        //     REGOCertificate.certificateHolder = _certificateHolder;
        //     REGOCertificate.certificateIssuer = msg.sender;
        //     REGOCertificate.REGOdata = _REGOData;
        // }   


        event REGOIssued(address _to, int energyType, int amount, bytes _data);
        event accreditorRegistered(address _accreditorAddress);

        // Modifier to ensure that the address is registered as a REGO accreditor
        modifier onlyREGOAccreditors(address accreditorAddress) {
            require(
                accreditor[accreditorAddress] == true,
                "You are not a certified REGO Accreditor!"
            ); 
            _;
        }

        modifier onlyRole(bytes32 _role) {
            // if msg.sender does not have role, then they are not authorized
            require(roles[_role][msg.sender], "Not Authorized");
            _;
        }

        // // struct for accreditor
        // struct Accreditor {
        //     address _accreditorAddress;
        //     bool _isOrIsntAcreditor;
        // }

        // Keeps count of number of accreditors
        uint256 public accreditorCount = 0;        

        // Maps accreditor details
        mapping(address => bool) public accreditor;
        
        constructor() ERC1155("https://ipfs.infura.io/ipfs/{CID}") Ownable() {
            // Granting role to deployer to access Register functions
            _grantRole(REGOREGISTER, msg.sender);
           
        }

        function uri(uint256 _certificateId) override public view returns (string memory) {
            return(REGOCertificate[_certificateId].REGOData);
        }

        // function setURI(string memory newuri) public {
        //     _setURI(newuri);
        // }

        // Registers a REGO accreditor. Is called from REGOAccreditor.sol 
        function registerForIssuingBody(address _account) external onlyRole(REGOREGISTER) returns(bool){
            // Pseudo-code
            // issuingBodyMapping[issuingBodySender] ← storeaccountAddress to state
            require(
                _account != address(0), "Invalid address! REGO Accreditor cannot be the zero address"
            );

            // Upon the execution of this transaction on the blockchain, the account owner has been registered to belong to an Issuing Body and it can now request the issuing of the GO certificate.        
            accreditor[_account] = true;

            // Trigger the event to indicate the accreditor has been registered
            emit accreditorRegistered(_account);
            return accreditor[_account];
        }
       
        function issueREGOCertificate(address applicantAddress, bytes memory REGOdata, uint amount, string memory _ipfsHash, address accreditor)  external onlyREGOAccreditors(accreditor) returns (uint256 gasUsed) {
            

           
            // Triggers an event (My own implementation)
            //emit REGOIssued(_to, technologyGroup, amount, _data);

            // Generate token id
            certificateId += 1;
            uint256 startGas = gasleft();
            _mint(applicantAddress, certificateId, amount, REGOdata);
            
            // Save Certificate to struct
            REGOCertificate[certificateId] = REGOCertificateStruct(applicantAddress, msg.sender, _ipfsHash);
            console.log("REGO Data Reference: ", REGOCertificate[certificateId].REGOData);
            
            
            //addREGOtoStruct(applicantAddress, msg.sender, ipfsHash);
            // Transfer to account
            safeTransferFrom(msg.sender, applicantAddress, 1, amount, REGOdata);
            gasUsed = startGas - gasleft();
            console.log("Gas Used: ", gasUsed);
            return gasUsed;
            
            
            
        }

        function retireREGOCertificate(address REGOHolder, uint256 REGOId, uint256 burnAmount, address accreditor) public onlyREGOAccreditors(accreditor) {
            // If request is not to burn more than in possession
            require(burnAmount <= getBalance(REGOHolder, REGOId), "Error, Trying to delete too many certificates");
            require(REGOCertificate[certificateId].certificateHolder == REGOHolder, "You're not the certificate holder!");
            _burn(REGOHolder, REGOId, burnAmount);
           
            
            
        }

        function getBalance(address _account, uint256 id) public view returns(uint) {
            return balanceOf(_account, id);
        }

        function transferREGOCertificate(address _holderAddress, address _to, uint _certificateId, uint  _amount, bytes calldata _REGOData, string calldata _ipfsHash) external {
            // Checking if caller is holder
            require(_holderAddress == REGOCertificate[_certificateId].certificateHolder, "You are not the Certificate Holder!");
            // Checking balance
            require(_amount <= getBalance(_holderAddress, _certificateId), "Attempted to transfer... Found Insufficient funds!");
            // Change certificate address after transfer
            safeTransferFrom(_holderAddress, _to, _certificateId, _amount, _REGOData);
            // Save Certificate to struct
            REGOCertificate[_certificateId] = REGOCertificateStruct(_to, msg.sender, _ipfsHash);
        }

        
        

}