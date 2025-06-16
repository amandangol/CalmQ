// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SoulboundBadge is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Mapping from token ID to badge type
    mapping(uint256 => string) private _badgeTypes;
    
    // Mapping from user address to badge type to token ID
    mapping(address => mapping(string => uint256)) private _userBadges;

    // Mapping from badge type to token URI
    mapping(string => string) private _badgeURIs;

    event BadgeMinted(address indexed to, string badgeType, uint256 tokenId);
    event BadgeURIUpdated(string badgeType, string tokenURI);

    constructor() ERC721("Auralynn Soulbound Badge", "ASB") {}

    function mintBadge(address to, string memory badgeType, string memory tokenURI) 
        public 
        onlyOwner 
        returns (uint256) 
    {
        require(_userBadges[to][badgeType] == 0, "Badge already minted for this type");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(to, newTokenId);
        _badgeTypes[newTokenId] = badgeType;
        _userBadges[to][badgeType] = newTokenId;
        _setTokenURI(newTokenId, tokenURI);

        emit BadgeMinted(to, badgeType, newTokenId);
        return newTokenId;
    }

    function setBadgeURI(string memory badgeType, string memory tokenURI) 
        public 
        onlyOwner 
    {
        _badgeURIs[badgeType] = tokenURI;
        emit BadgeURIUpdated(badgeType, tokenURI);
    }

    function getBadgeType(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Badge does not exist");
        return _badgeTypes[tokenId];
    }

    function getUserBadge(address user, string memory badgeType) 
        public 
        view 
        returns (uint256) 
    {
        return _userBadges[user][badgeType];
    }

    // Override transfer functions to make tokens non-transferable
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(from == address(0) || to == address(0), "Soulbound tokens cannot be transferred");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // Override tokenURI to use our custom URI mapping
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Badge does not exist");
        string memory badgeType = _badgeTypes[tokenId];
        return _badgeURIs[badgeType];
    }
} 