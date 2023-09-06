// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./ERC721.sol"; // Import the ERC-721 interface
import "./ERC721Metadata.sol"; // Import the ERC-721 Metadata interface

contract MyNFT is ERC721, ERC721Metadata {
    // Mapping from token ID to owner address
    mapping(uint256 => address) private tokenOwners;

    // Mapping from owner address to token count
    mapping(address => uint256) private ownedTokensCount;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private operatorApprovals;

    // Token name
    string private _name = "MyNFT";

    // Token symbol
    string private _symbol = "MNFT";

    // URI base for token metadata
    string private _baseTokenURI = "https://example.com/api/token/";

    // An array containing all token IDs
    uint256[] private allTokens;

    constructor() public {
        // Mint an initial token when the contract is deployed
        mintToken(msg.sender);
    }

    // Function to get the name of the NFT collection
    function name() external view returns (string) {
        return _name;
    }

    // Function to get the symbol of the NFT collection
    function symbol() external view returns (string) {
        return _symbol;
    }

    // Function to get the URI for a specific token
    function tokenURI(uint256 _tokenId) external view returns (string) {
        require(_exists(_tokenId), "Token does not exist");
        return string(abi.encodePacked(_baseTokenURI, uint2str(_tokenId)));
    }

    // Function to check if a token exists
    function _exists(uint256 _tokenId) internal view returns (bool) {
        return tokenOwners[_tokenId] != address(0);
    }

    // Function to convert uint to string
    function uint2str(uint256 _i) internal pure returns (string) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        return string(bstr);
    }

    // Function to mint a new token
    function mintToken(address _to) private {
        uint256 tokenId = allTokens.length;
        allTokens.push(tokenId);
        tokenOwners[tokenId] = _to;
        ownedTokensCount[_to]++;
        emit Transfer(address(0), _to, tokenId);
    }

    // Function to transfer ownership of a token
    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "Not approved or owner");
        require(tokenOwners[_tokenId] == _from, "Not token owner");
        require(_to != address(0), "Invalid recipient address");

        // Clear approval
        if (tokenApprovals[_tokenId] != address(0)) {
            tokenApprovals[_tokenId] = address(0);
        }

        // Transfer token
        tokenOwners[_tokenId] = _to;
        ownedTokensCount[_from]--;
        ownedTokensCount[_to]++;
        emit Transfer(_from, _to, _tokenId);
    }

    // Function to check if the caller is approved or the owner of the token
    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        address owner = tokenOwners[_tokenId];
        return (_spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender));
    }

    // Function to approve an address to transfer a token
    function approve(address _approved, uint256 _tokenId) external {
        address owner = tokenOwners[_tokenId];
        require(_approved != owner, "Cannot approve the owner");
        require(msg.sender == owner || operatorApprovals[owner][msg.sender], "Not owner or operator");

        tokenApprovals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    // Function to check the approved address for a token
    function getApproved(uint256 _tokenId) external view returns (address) {
        return tokenApprovals[_tokenId];
    }

    // Function to set or revoke operator approval
    function setApprovalForAll(address _operator, bool _approved) external {
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // Function to check if an address is an approved operator for another address
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }
}
