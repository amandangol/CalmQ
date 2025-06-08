// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract WellnessAchievementNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    struct Achievement {
        string name;
        string description;
        string category; // Mood, Journal, Focus, Breathing, Meditation
        uint256 difficulty; // 1-5
        string imageUri;
        uint256 timestamp;
    }
    
    mapping(uint256 => Achievement) public achievements;
    mapping(address => bool) public minters;
    mapping(string => mapping(address => bool)) public userAchievements;
    
    event AchievementMinted(address indexed user, uint256 tokenId, string achievementName);
    event MinterStatusChanged(address indexed minter, bool status);
    
    constructor() ERC721("Wellness Achievement", "WELLACH") {}
    
    modifier onlyMinter() {
        require(minters[msg.sender], "Not authorized to mint");
        _;
    }
    
    function setMinter(address minter, bool status) external onlyOwner {
        minters[minter] = status;
        emit MinterStatusChanged(minter, status);
    }
    
    function mintAchievement(
        address to,
        string memory name,
        string memory description,
        string memory category,
        uint256 difficulty,
        string memory imageUri
    ) external onlyMinter returns (uint256) {
        require(!userAchievements[name][to], "Achievement already earned");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        achievements[newTokenId] = Achievement({
            name: name,
            description: description,
            category: category,
            difficulty: difficulty,
            imageUri: imageUri,
            timestamp: block.timestamp
        });
        
        userAchievements[name][to] = true;
        _mint(to, newTokenId);
        
        emit AchievementMinted(to, newTokenId, name);
        return newTokenId;
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return achievements[tokenId].imageUri;
    }
    
    function getUserAchievements(address user) external view returns (uint256[] memory) {
        uint256 balance = balanceOf(user);
        uint256[] memory tokenIds = new uint256[](balance);
        uint256 index = 0;
        
        for (uint256 i = 1; i <= _tokenIds.current(); i++) {
            if (ownerOf(i) == user) {
                tokenIds[index] = i;
                index++;
            }
        }
        
        return tokenIds;
    }
} 