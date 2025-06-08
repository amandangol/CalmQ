const hre = require("hardhat");

async function main() {
  console.log("Setting up permissions for deployed contracts...");

  // Contract addresses from your deployment
  const WELLNESS_TOKEN_ADDRESS = "0xb734524de04Ec6b93D30e7132f4034e4F8Ea16cF";
  const ACHIEVEMENT_NFT_ADDRESS = "0x90D85445d55CA4F35B592355D90ecff6AC1F9740";
  const ACHIEVEMENT_SYSTEM_ADDRESS =
    "0xFf5bD3Aa319Aa8b02Cf95BED94A3F85983Ab79cb";

  // Get contract instances
  const wellnessToken = await hre.ethers.getContractAt(
    "WellnessToken",
    WELLNESS_TOKEN_ADDRESS
  );
  const achievementNFT = await hre.ethers.getContractAt(
    "WellnessAchievementNFT",
    ACHIEVEMENT_NFT_ADDRESS
  );

  // Get current gas price and add buffer
  const gasPrice = await hre.ethers.provider.getGasPrice();
  const bufferedGasPrice = gasPrice.mul(120).div(100); // 20% buffer

  console.log(
    "Current gas price:",
    hre.ethers.utils.formatUnits(gasPrice, "gwei"),
    "gwei"
  );
  console.log(
    "Using gas price:",
    hre.ethers.utils.formatUnits(bufferedGasPrice, "gwei"),
    "gwei"
  );

  try {
    // Set minter permission for WellnessToken
    console.log("\n🔧 Setting WellnessToken minter permission...");
    const tx1 = await wellnessToken.setMinter(
      ACHIEVEMENT_SYSTEM_ADDRESS,
      true,
      {
        gasPrice: bufferedGasPrice,
        gasLimit: 100000,
      }
    );
    await tx1.wait();
    console.log("✅ WellnessToken minter permission set! TX:", tx1.hash);

    // Wait a bit before next transaction
    console.log("⏳ Waiting 3 seconds before next transaction...");
    await new Promise((resolve) => setTimeout(resolve, 3000));

    // Set minter permission for AchievementNFT
    console.log("\n🔧 Setting AchievementNFT minter permission...");
    const tx2 = await achievementNFT.setMinter(
      ACHIEVEMENT_SYSTEM_ADDRESS,
      true,
      {
        gasPrice: bufferedGasPrice,
        gasLimit: 100000,
      }
    );
    await tx2.wait();
    console.log("✅ AchievementNFT minter permission set! TX:", tx2.hash);

    console.log("\n🎉 All permissions set successfully!");

    // Verify permissions
    console.log("\n🔍 Verifying permissions...");
    const tokenMinterStatus = await wellnessToken.minters(
      ACHIEVEMENT_SYSTEM_ADDRESS
    );
    const nftMinterStatus = await achievementNFT.minters(
      ACHIEVEMENT_SYSTEM_ADDRESS
    );

    console.log("WellnessToken minter status:", tokenMinterStatus);
    console.log("AchievementNFT minter status:", nftMinterStatus);

    if (tokenMinterStatus && nftMinterStatus) {
      console.log("✅ All permissions verified successfully!");
      console.log("\n🚀 Your wellness contract system is ready to use!");

      console.log("\n📋 Contract Summary:");
      console.log("WellnessToken:", WELLNESS_TOKEN_ADDRESS);
      console.log("WellnessAchievementNFT:", ACHIEVEMENT_NFT_ADDRESS);
      console.log("WellnessAchievementSystem:", ACHIEVEMENT_SYSTEM_ADDRESS);
      console.log("\n🔍 View on Sepolia Etherscan:");
      console.log(
        "https://sepolia.etherscan.io/address/" + WELLNESS_TOKEN_ADDRESS
      );
      console.log(
        "https://sepolia.etherscan.io/address/" + ACHIEVEMENT_NFT_ADDRESS
      );
      console.log(
        "https://sepolia.etherscan.io/address/" + ACHIEVEMENT_SYSTEM_ADDRESS
      );
    } else {
      console.log("❌ Permission verification failed. Please check manually.");
    }
  } catch (error) {
    console.error("❌ Error setting permissions:", error.message);

    if (error.message.includes("replacement fee too low")) {
      console.log(
        "\n💡 Try running this script again in a few minutes when network congestion decreases."
      );
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
