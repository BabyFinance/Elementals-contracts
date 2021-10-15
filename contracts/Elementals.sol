// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract Elementals is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, Pausable {
    using Strings for uint256;

    uint256 public immutable maxSupply = 369;
    
    uint256 private index;
    string private baseURI;

    mapping(address => bool) public whitelist;
    mapping(address => bool) public claimed;
    
    uint256 public startTime;

    constructor() ERC721("Elementals", "ELEM") {
        _pause();
        startTime = block.timestamp;
        baseURI = "https://babygeist.finance/nft/elementals/tokens/";
    }
    
    function mint() external {
        require(whitelist[msg.sender], "Not whitelisted!");
        require(!claimed[msg.sender], "You have already claimed your Elemental");
        claimed[msg.sender] = true;
        _mint(msg.sender);
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        startTime = _startTime;
    }

    function setBaseURI(string memory __baseURI) external onlyOwner {
        baseURI = __baseURI;
    }

    function setWhitelist(address[] calldata addresses, bool allow) external onlyOwner {
        uint256 addressesLen = addresses.length;
        for (uint256 i = 0; i < addressesLen; i++) {
            whitelist[addresses[i]] = allow;
        }
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function _mint(address to) internal {
        require(totalSupply() <= maxSupply, "Supply Depleated");
        _safeMint(to, index);
        index += 1;
    }

    function _baseURI() internal view override returns(string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), 'ERC721Metadata: URI query for nonexistent token');

        string memory __baseURI = _baseURI();
        return bytes(__baseURI).length > 0 ? string(abi.encodePacked(__baseURI, tokenId.toString(), '.json')) : '';
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
