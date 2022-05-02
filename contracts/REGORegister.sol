// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract REGORegsiter is ERC1155, Ownable, ERC1155Burnable {


        event REGOIssued(address _to, uint amount, string _data, address _accreditor);
        event REGORetired(address _REGOHolder, uint _REGOId, uint256 _burnAmount, address _accreditor);
        event accreditorRegistered(address _accreditorAddress);
        event loggedREGOApplicant(address _applicantAddress, address _accreditor);
        event GrantRole(bytes32 role, address account);
        event balanceRetrieved(address _REGOHolder, uint256 _REGOId);
        event certificatesTransferred(address _oldREGOHolder, address _newREGOHolder, uint256 _REGOId);

     
        // IPFS Hash to save reference of file from IPFS
        string ipfsHash;

        // REGO Register role (deployer)
        bytes32 private constant REGOREGISTER = keccak256(abi.encodePacked("REGOREGISTER"));

        // Accreditor mapping
        mapping(bytes32 => mapping(address => bool)) public roles;
        
        // Certificate mapping
        mapping(uint => REGOCertificateStruct) public REGOCertificate;

        // REGO applicant mapping
        mapping(address => bool) public REGOApplicant;

        // Maps accreditor details
        mapping(address => bool) public accreditor;


        // Certificate unique id
        uint certificateId = 0;

        // Certificate struct
        struct REGOCertificateStruct {
            address certificateHolder;
            address certificateIssuer;
            string REGOData;
        }


        // function getStruct() public view returns(bytes32[]) {
        //     return REGOCertificate[msg.sender].REGOData;
        // }

        function getREGOApplicant(address _REGOApplicant) public view returns (bool) {
            return REGOApplicant[_REGOApplicant];
        }

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

        function logApplicant(address _REGOApplicant, address _accreditor) external onlyREGOAccreditors(_accreditor) {
            REGOApplicant[_REGOApplicant] = true;
            require(getREGOApplicant(_REGOApplicant), "REGO Applicant does not exist");
            emit loggedREGOApplicant(_REGOApplicant, _accreditor);

        }

        // function certificateToStruct(address _certificateHolder, bytes _REGOData) 
        //     REGOCertificate.certificateHolder = _certificateHolder;
        //     REGOCertificate.certificateIssuer = msg.sender;
        //     REGOCertificate.REGOdata = _REGOData;
        // }   


      

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

        
        function registerREGOAccreditor(address _account) external onlyRole(REGOREGISTER) returns(bool){
            require(
                _account != address(0), "Invalid address! REGO Accreditor cannot be the zero address"
            );
            // Setting accreditor to be true        
            accreditor[_account] = true;

            // Trigger the event to indicate the accreditor has been registered
            emit accreditorRegistered(_account);
            return accreditor[_account];
        }
       
        function issueREGOCertificate(address applicantAddress, bytes memory REGOdata, uint amount, 
        string memory _ipfsHash, address accreditor)  external onlyREGOAccreditors(accreditor) returns (uint256 gasUsed) {
            // Checking REGOApplicant exists
            require(getREGOApplicant(applicantAddress), "REGO Applicant does not exist");
            // Generate token id
            certificateId += 1;
            uint256 startGas = gasleft();
            _mint(applicantAddress, certificateId, amount, REGOdata);
            
            // Save Certificate to struct
            REGOCertificate[certificateId] = REGOCertificateStruct(applicantAddress, msg.sender, _ipfsHash);
            
            // Transfer to account
            safeTransferFrom(msg.sender, applicantAddress, 1, amount, REGOdata);
            gasUsed = startGas - gasleft();
            console.log("Gas Used: ", gasUsed);
            
            // Triggers REGO is issued event
            emit REGOIssued(applicantAddress, amount, _ipfsHash, accreditor);
            return gasUsed; 
        }

        function retireREGOCertificate(address REGOHolder, uint256 REGOId, uint256 burnAmount, address accreditor) public onlyREGOAccreditors(accreditor) {
            // If request is not to burn more than in possession
            require(burnAmount <= getBalance(REGOHolder, REGOId), "Error, Trying to delete too many certificates");
            require(REGOCertificate[certificateId].certificateHolder == REGOHolder, "You're not the certificate holder!");
           
            _burn(REGOHolder, REGOId, burnAmount);
            emit REGORetired(REGOHolder, REGOId, burnAmount, accreditor);
        }

        function getBalance(address _REGOApplicant, uint256 _REGOId) public returns(uint) {
            require(getREGOApplicant(_REGOApplicant), "REGO Applicant does not exist");
            emit balanceRetrieved(_REGOApplicant, _REGOId);
            return balanceOf(_REGOApplicant, _REGOId);
        }

        function transferREGOCertificate(address _holderAddress, address _to, uint _certificateId, uint  _amount, bytes calldata _REGOData, string calldata _ipfsHash) external {
            // Check REGO Holder exists
            require(getREGOApplicant(_holderAddress), "REGO Applicant does not exist");
            // Checking if caller is holder
            require(_holderAddress == REGOCertificate[_certificateId].certificateHolder, "You are not the Certificate Holder!");
            // Checking balance
            require(_amount <= getBalance(_holderAddress, _certificateId), "Attempted to transfer... Found Insufficient funds!");
            // Change certificate address after transfer
            safeTransferFrom(_holderAddress, _to, _certificateId, _amount, _REGOData);
            // Save Certificate to struct
            REGOCertificate[_certificateId] = REGOCertificateStruct(_to, msg.sender, _ipfsHash);
            emit certificatesTransferred(_to, _holderAddress, _certificateId);
        }

        
        

}