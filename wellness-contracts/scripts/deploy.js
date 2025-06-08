const hre = require("hardhat");

async function main() {
  console.log("Deploying contracts...");

  // Deploy WellnessToken
  const WellnessToken = await hre.ethers.getContractFactory("WellnessToken");
  const wellnessToken = await WellnessToken.deploy();
  await wellnessToken.deployed();
  console.log("WellnessToken deployed to:", wellnessToken.address);

  // Deploy WellnessAchievementNFT
  const WellnessAchievementNFT = await hre.ethers.getContractFactory(
    "WellnessAchievementNFT"
  );
  const achievementNFT = await WellnessAchievementNFT.deploy();
  await achievementNFT.deployed();
  console.log("WellnessAchievementNFT deployed to:", achievementNFT.address);

  // Deploy WellnessAchievementSystem
  const WellnessAchievementSystem = await hre.ethers.getContractFactory(
    "WellnessAchievementSystem"
  );
  const achievementSystem = await WellnessAchievementSystem.deploy(
    wellnessToken.address,
    achievementNFT.address
  );
  await achievementSystem.deployed();
  console.log(
    "WellnessAchievementSystem deployed to:",
    achievementSystem.address
  );

  // Set minters
  console.log("Setting up permissions...");
  await wellnessToken.setMinter(achievementSystem.address, true);
  await achievementNFT.setMinter(achievementSystem.address, true);
  console.log("Permissions set successfully!");

  // Save deployment info
  const deploymentInfo = {
    wellnessToken: wellnessToken.address,
    achievementNFT: achievementNFT.address,
    achievementSystem: achievementSystem.address,
    network: hre.network.name,
    timestamp: new Date().toISOString(),
  };

  console.log("\nDeployment Summary:");
  console.log(JSON.stringify(deploymentInfo, null, 2));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
