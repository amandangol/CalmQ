// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./WellnessToken.sol";
import "./WellnessAchievementNFT.sol";

contract WellnessAchievementSystem is Ownable, ReentrancyGuard {
    WellnessToken public wellnessToken;
    WellnessAchievementNFT public achievementNFT;
    
    struct AchievementReward {
        uint256 tokenReward;
        uint256 achievementId;  // Changed to store achievement ID
        bool exists;
    }
    
    mapping(string => AchievementReward) public achievementRewards;
    mapping(address => mapping(string => uint256)) public userProgress;
    mapping(address => mapping(string => bool)) public completedAchievements;
    
    event AchievementCompleted(address indexed user, string achievementName, uint256 tokenReward);
    event ProgressUpdated(address indexed user, string achievementName, uint256 progress);
    event AchievementAdded(string achievementName, uint256 tokenReward, uint256 achievementId);
    
    constructor(address _wellnessToken, address _achievementNFT) {
        wellnessToken = WellnessToken(_wellnessToken);
        achievementNFT = WellnessAchievementNFT(_achievementNFT);
        
        // Initialize default achievements
        _initializeAchievements();
    }
    
    function _initializeAchievements() private {
        // Mood Tracking Achievements
        achievementRewards["first_mood_log"] = AchievementReward(10 * 10**18, 1, true);
        achievementRewards["mood_streak_7"] = AchievementReward(50 * 10**18, 2, true);
        achievementRewards["mood_streak_30"] = AchievementReward(200 * 10**18, 3, true);
        
        // Journal Achievements
        achievementRewards["first_journal_entry"] = AchievementReward(15 * 10**18, 4, true);
        achievementRewards["journal_streak_7"] = AchievementReward(75 * 10**18, 5, true);
        achievementRewards["gratitude_master"] = AchievementReward(100 * 10**18, 6, true);
        
        // Meditation Achievements
        achievementRewards["first_meditation"] = AchievementReward(20 * 10**18, 7, true);
        achievementRewards["meditation_master"] = AchievementReward(300 * 10**18, 8, true);
        achievementRewards["zen_master"] = AchievementReward(500 * 10**18, 9, true);
        
        // Breathing Achievements
        achievementRewards["breathing_beginner"] = AchievementReward(25 * 10**18, 10, true);
        achievementRewards["breath_master"] = AchievementReward(150 * 10**18, 11, true);
        
        // Focus Achievements
        achievementRewards["focus_warrior"] = AchievementReward(100 * 10**18, 12, true);
        achievementRewards["productivity_guru"] = AchievementReward(250 * 10**18, 13, true);
    }
    
    function updateProgress(
        address user,
        string memory achievementName,
        uint256 progress
    ) external onlyOwner {
        require(achievementRewards[achievementName].exists, "Achievement does not exist");
        require(!completedAchievements[user][achievementName], "Achievement already completed");
        
        userProgress[user][achievementName] = progress;
        emit ProgressUpdated(user, achievementName, progress);
    }
    
    function completeAchievement(
        address user,
        string memory achievementName
    ) external onlyOwner nonReentrant {
        require(achievementRewards[achievementName].exists, "Achievement does not exist");
        require(!completedAchievements[user][achievementName], "Achievement already completed");
        
        AchievementReward memory reward = achievementRewards[achievementName];
        
        // Mark achievement as completed
        completedAchievements[user][achievementName] = true;
        
        // Award tokens
        if (reward.tokenReward > 0) {
            wellnessToken.mint(user, reward.tokenReward);
        }
        
        // Mint NFT with achievement ID
        achievementNFT.mintAchievement(reward.achievementId);
        
        emit AchievementCompleted(user, achievementName, reward.tokenReward);
    }
    
    function addAchievement(
        string memory name,
        uint256 tokenReward,
        uint256 achievementId
    ) external onlyOwner {
        require(!achievementRewards[name].exists, "Achievement already exists");
        achievementRewards[name] = AchievementReward(tokenReward, achievementId, true);
        emit AchievementAdded(name, tokenReward, achievementId);
    }
    
    function getUserProgress(address user, string memory achievementName) 
        external view returns (uint256) {
        return userProgress[user][achievementName];
    }
    
    function isAchievementCompleted(address user, string memory achievementName) 
        external view returns (bool) {
        return completedAchievements[user][achievementName];
    }
} 