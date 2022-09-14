// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MintableNFT is ERC721URIStorage, AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");


    constructor() ERC721("ERC721", "NFT"){
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
    }


    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }


    function mintNFT(address recipient, string memory tokenURI) external {
        require(hasRole(MINTER_ROLE, msg.sender), "Not a minter role");

        _tokenId.increment();
        uint256 newItemId = _tokenId.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);
    }


    function burnNFT(address owner, uint256 tokenId) public {
        require(hasRole(BURNER_ROLE, msg.sender), "Not a burner role");
        require((ownerOf(tokenId) == owner || hasRole(ADMIN_ROLE, msg.sender)), "Not an owner");
        
        _burn(tokenId);
    }

}
