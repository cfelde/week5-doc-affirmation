// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DocAffirmation is ERC721 {
    uint private nextTokenId;
    mapping(uint => uint) public tokenVersion;
    mapping(uint => uint[]) public tokenDocuments;
    mapping(uint => mapping(address => bool)) public tokenViewers;
    mapping(uint => mapping(address => bool)) public tokenSigners;

    event CreateDocumentEntry(address indexed sender, uint id);
    event DocumentEntryVersion(address indexed sender, uint id, uint newVersion);
    event AddDocumentEntry(address indexed sender, uint indexed id, uint docHash);
    event RemoveDocumentEntry(address indexed sender, uint indexed id, uint docHash);

    event SignDocuments(address indexed signer, uint indexed id, uint version, bool signed);

    constructor() ERC721("Document Affirmation", "DocAff") {
        console.log("Deployed DocAff to", address(this));
    }

    modifier onlyApproved(uint id) {
        require(_isApprovedOrOwner(msg.sender, id), "Unauthorized");
        _;
    }

    function createDocumentEntry() external returns (uint) {
        uint id = nextTokenId++;
        _mint(msg.sender, id);
        emit CreateDocumentEntry(msg.sender, id);
        console.log("Created document entry", id);
        return (id);
    }

    function resetDocumentEntry(uint id) external onlyApproved(id) returns (uint) {
        tokenVersion[id]++;
        emit DocumentEntryVersion(msg.sender, id, tokenVersion[id]);
        console.log("Reset document entry", id);
        return (tokenVersion[id]);
    }

    function addDocumentToEntry(uint id, uint docHash) external onlyApproved(id) returns (uint) {
        tokenDocuments[id].push(docHash);
        tokenVersion[id]++;
        emit AddDocumentEntry(msg.sender, id, docHash);
        emit DocumentEntryVersion(msg.sender, id, tokenVersion[id]);
        console.log("Add document to entry", id, docHash, tokenDocuments[id].length - 1);
        return (tokenDocuments[id].length);
    }

    function removeDocumentToEntry(uint id, uint docHash, uint docIndex) external onlyApproved(id) returns (uint) {
        require(tokenDocuments[id][docIndex] == docHash, "Invalid document");
        tokenDocuments[id][docIndex] = tokenDocuments[id][tokenDocuments[id].length - 1];
        tokenDocuments[id].pop();
        tokenVersion[id]++;
        emit RemoveDocumentEntry(msg.sender, id, docHash);
        emit DocumentEntryVersion(msg.sender, id, tokenVersion[id]);
        console.log("Remove document to entry", id, docHash, docIndex);
        return (tokenDocuments[id].length);
    }

    function setViewer(uint id, address user) external onlyApproved(id) {
        console.log("Set viewer", id, user);
        tokenViewers[id][user] = true;
    }

    function resetViewer(uint id, address user) external onlyApproved(id) {
        console.log("Reset viewer", id, user);
        tokenViewers[id][user] = false;
    }

    function setSigner(uint id, address user) external onlyApproved(id) {
        console.log("Set signer", id, user);
        tokenSigners[id][user] = true;
    }

    function resetSigner(uint id, address user) external onlyApproved(id) {
        console.log("Reset signer", id, user);
        tokenViewers[id][user] = false;
    }

    function canView(uint id, address user) public view returns (bool) {
        return (tokenViewers[id][user]);
    }

    function canSign(uint id, address user) public view returns (bool) {
        return (tokenSigners[id][user]);
    }

    function sign(uint id, uint version) external {
        require(canSign(id, msg.sender), "Not signer");
        require(tokenVersion[id] == version, "Invalid version");
        console.log("Sign", id, version);
        emit SignDocuments(msg.sender, id, version, true);
    }

    function reject(uint id, uint version) external {
        require(canSign(id, msg.sender), "Not signer");
        require(tokenVersion[id] == version, "Invalid version");
        console.log("Reject", id, version);
        emit SignDocuments(msg.sender, id, version, false);
    }

    function docCount(uint id) public view returns (uint) {
        return (tokenDocuments[id].length);
    }
}
