pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

//import "hardhat/console.sol";
//import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

interface ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

contract YourContract {
    /*
    The MVP NFT is a lightweight 1/1 NFT contract that conforms to the ERC721 standard in a way that makes it extremely simple for someone to understand what is going on from etherscan.
    Since the token is a 1/1, the tokenId is set to 1, however this could in theory be any value and would just need to update the rest of the contract
    */

    //arbitrary string to be stored at the top of the contract
    string public arbString;
    address public owner; 
    uint public tokenId;
    mapping (uint => address) public approvedList;
    mapping (address => mapping (address => bool)) public operatorList;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    //currently declaring the owner as my local acct on scaffold-eth. Will be msg.sender later
    constructor(string memory _arbString) {
        arbString = _arbString;
        owner = 0xC9FFEe9e34723d882CB97a6c056100661d00Bfe1;
        tokenId = 1;
        emit Transfer(address(0), address(0), tokenId);
    }

    function balanceOf(address queryAddress) external view returns (uint) {
        if(queryAddress == owner) {
            return 1;
        } else {
            return 0;
        }
    }

    function ownerOf(uint _tokenId) external view returns (address) {
        if(_tokenId == tokenId) {
            return owner;
        } else {
            return address(0);
        }
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes memory data) external payable {
        //a tad confused as far as what the data field should represent
        require(msg.sender == owner || operatorList[owner][msg.sender] == true || approvedList[tokenId] == msg.sender);
        require(_from == owner && _from != address(0) && _tokenId == tokenId);
        ERC721TokenReceiver(_to).onERC721Received(_from, _from, _tokenId, data);
        emit Transfer(_from, _to, _tokenId);
        owner = _to;
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId) external payable {
        require(msg.sender == owner || operatorList[owner][msg.sender] == true || approvedList[tokenId] == msg.sender);
        require(_from == owner && _from != address(0) && _tokenId == tokenId);
        //Building out some of the safeTransfer nonsense here. Need to implement the ERC 165 interface too.
        //Not sure whether im on the right path here or not
        ERC721TokenReceiver(_to).onERC721Received(_from, _from, _tokenId, "");
        emit Transfer(_from, _to, _tokenId);
        owner = _to;
    }

    function transferFrom(address _from, address _to, uint _tokenId) external payable {
        require(msg.sender == owner || operatorList[owner][msg.sender] == true || approvedList[tokenId] == msg.sender);
        require(_from == owner && _from != address(0) && _tokenId == tokenId);
        emit Transfer(_from, _to, _tokenId);
        owner = _to;
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        require(msg.sender == owner || operatorList[owner][msg.sender] == true || approvedList[tokenId] == msg.sender);
        require(_tokenId == tokenId);
        emit Approval(owner, _approved, _tokenId);
        approvedList[tokenId] == _approved;
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(msg.sender == owner || operatorList[owner][msg.sender] == true);
        emit ApprovalForAll(owner, _operator, _approved);
        operatorList[owner][_operator] = _approved; 
    }

    function getApproved(uint _tokenId) external view returns (address) {
        return approvedList[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorList[_owner][_operator];
    }
}

//added this to try to test whether the safeTransfer will revert when sending to an address unable to hold an NFT but haven't tested it yet! 
contract ShouldntHoldNFT{
    uint num = 69;

    function readNum() public view returns (uint) {
        return num;
    }
}
