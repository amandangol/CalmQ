const hre = require("hardhat");

async function main() {
  console.log("Deploying Wellness System...");

  // Deploy WellnessToken
  console.log("Deploying WellnessToken...");
  const WellnessToken = await hre.ethers.getContractFactory("WellnessToken");
  const wellnessToken = await WellnessToken.deploy();
  await wellnessToken.deployed();
  const wellnessTokenAddress = wellnessToken.address;
  console.log("WellnessToken deployed to:", wellnessTokenAddress);

  // Deploy WellnessAchievementNFT
  console.log("Deploying WellnessAchievementNFT...");
  const WellnessAchievementNFT = await hre.ethers.getContractFactory(
    "WellnessAchievementNFT"
  );
  const achievementNFT = await WellnessAchievementNFT.deploy();
  await achievementNFT.deployed();
  const achievementNFTAddress = achievementNFT.address;
  console.log("WellnessAchievementNFT deployed to:", achievementNFTAddress);

  // Deploy WellnessAchievementSystem
  console.log("Deploying WellnessAchievementSystem...");
  const WellnessAchievementSystem = await hre.ethers.getContractFactory(
    "WellnessAchievementSystem"
  );
  const system = await WellnessAchievementSystem.deploy(
    wellnessTokenAddress,
    achievementNFTAddress
  );
  await system.deployed();
  const systemAddress = system.address;
  console.log("WellnessAchievementSystem deployed to:", systemAddress);

  // Verify contracts on Etherscan
  if (process.env.ETHERSCAN_API_KEY) {
    console.log("Waiting for block confirmations...");
    await system.deployTransaction.wait(6); // Wait for 6 block confirmations

    console.log("Verifying contracts on Etherscan...");
    try {
      await hre.run("verify:verify", {
        address: wellnessTokenAddress,
        constructorArguments: [],
      });
      console.log("WellnessToken verified successfully");

      await hre.run("verify:verify", {
        address: achievementNFTAddress,
        constructorArguments: [],
      });
      console.log("WellnessAchievementNFT verified successfully");

      await hre.run("verify:verify", {
        address: systemAddress,
        constructorArguments: [wellnessTokenAddress, achievementNFTAddress],
      });
      console.log("WellnessAchievementSystem verified successfully");
    } catch (error) {
      console.log("Error verifying contracts:", error);
    }
  }

  console.log("\nDeployment Summary:");
  console.log("-------------------");
  console.log("WellnessToken:", wellnessTokenAddress);
  console.log("WellnessAchievementNFT:", achievementNFTAddress);
  console.log("WellnessAchievementSystem:", systemAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
