const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying WellnessAchievementNFT...");

  const WellnessAchievementNFT = await ethers.getContractFactory(
    "WellnessAchievementNFT"
  );
  const contract = await WellnessAchievementNFT.deploy();

  await contract.deployed();

  console.log("WellnessAchievementNFT deployed to:", contract.address);

  // Save contract address and ABI for Flutter app
  const fs = require("fs");
  const contractInfo = {
    address: contract.address,
    network: hre.network.name,
    abi: WellnessAchievementNFT.interface.format(ethers.utils.FormatTypes.json),
  };

  fs.writeFileSync(
    "../assets/contract_info.json",
    JSON.stringify(contractInfo, null, 2)
  );

  console.log("Contract info saved to Flutter app assets");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
