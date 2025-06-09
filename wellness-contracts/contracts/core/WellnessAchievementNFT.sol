// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract WellnessAchievementNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Mapping from user address to their achievement IDs
    mapping(address => uint256[]) private _userAchievements;
    
    // Mapping from achievement ID to whether it exists
    mapping(uint256 => bool) private _validAchievementIds;
    
    // Mapping from user address to whether they've minted a specific achievement
    mapping(address => mapping(uint256 => bool)) private _hasMintedAchievement;

    // Event emitted when a new achievement is minted
    event AchievementMinted(address indexed user, uint256 indexed achievementId, uint256 tokenId);

    constructor() ERC721("Wellness Achievement", "WELL") {
        // Initialize valid achievement IDs (1-10 for now)
        for(uint256 i = 1; i <= 10; i++) {
            _validAchievementIds[i] = true;
        }
    }

    // Function to mint a new achievement NFT
    function mintAchievement(uint256 achievementId) public {
        require(_validAchievementIds[achievementId], "Invalid achievement ID");
        require(!_hasMintedAchievement[msg.sender][achievementId], "Already minted this achievement");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _mint(msg.sender, newTokenId);
        _userAchievements[msg.sender].push(achievementId);
        _hasMintedAchievement[msg.sender][achievementId] = true;

        emit AchievementMinted(msg.sender, achievementId, newTokenId);
    }

    // Function to get all achievements for a user
    function getUserAchievements(address user) public view returns (uint256[] memory) {
        return _userAchievements[user];
    }

    // Function to add new valid achievement IDs (only owner)
    function addValidAchievementId(uint256 achievementId) public onlyOwner {
        _validAchievementIds[achievementId] = true;
    }

    // Function to check if an achievement ID is valid
    function isValidAchievementId(uint256 achievementId) public view returns (bool) {
        return _validAchievementIds[achievementId];
    }

    // Function to check if a user has minted a specific achievement
    function hasMintedAchievement(address user, uint256 achievementId) public view returns (bool) {
        return _hasMintedAchievement[user][achievementId];
    }
} 