const hre = require("hardhat");

async function main() {
  console.log("Deploying WellnessAchievementNFT...");

  const WellnessAchievementNFT = await hre.ethers.getContractFactory(
    "WellnessAchievementNFT"
  );
  const nft = await WellnessAchievementNFT.deploy();

  await nft.waitForDeployment();

  const address = await nft.getAddress();
  console.log("WellnessAchievementNFT deployed to:", address);

  // Verify the contract on Etherscan
  if (process.env.ETHERSCAN_API_KEY) {
    console.log("Waiting for block confirmations...");
    await nft.deployTransaction.wait(6); // Wait for 6 block confirmations

    console.log("Verifying contract on Etherscan...");
    try {
      await hre.run("verify:verify", {
        address: address,
        constructorArguments: [],
      });
      console.log("Contract verified successfully");
    } catch (error) {
      console.log("Error verifying contract:", error);
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
