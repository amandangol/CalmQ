const functions = require("firebase-functions");
const { ethers } = require("ethers");
const admin = require("firebase-admin");

admin.initializeApp();

const CONTRACT_ADDRESS = "0x73a5765e70c74186e3537fafe5170986ef507149"; // Your contract address
const PRIVATE_KEY = process.env.PRIVATE_KEY; // Store in Firebase config
const RPC_URL = "https://1rpc.io/sepolia"; // Your RPC URL

const CONTRACT_ABI = [
  // Your contract ABI here
];

exports.mintBadge = functions.https.onCall(async (data, context) => {
  // Verify user authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const { userAddress, badgeType, metadataURI } = data;

  console.log(`Minting badge ${badgeType} for ${userAddress}`);

  try {
    // Initialize provider and wallet
    const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
    const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

    // Create contract instance
    const contract = new ethers.Contract(
      CONTRACT_ADDRESS,
      CONTRACT_ABI,
      wallet
    );

    // Check if user already has this badge
    const hasBadge = await contract.hasBadge(userAddress, badgeType);
    if (hasBadge) {
      throw new functions.https.HttpsError(
        "already-exists",
        "User already has this badge"
      );
    }

    // Mint the badge
    const tx = await contract.mintBadge(userAddress, badgeType, metadataURI);
    console.log(`Transaction sent: ${tx.hash}`);

    // Wait for confirmation
    const receipt = await tx.wait();
    console.log(`Transaction confirmed: ${receipt.transactionHash}`);

    // Save badge info to Firestore
    await admin.firestore().collection("user_badges").add({
      userId: context.auth.uid,
      userAddress: userAddress,
      badgeType: badgeType,
      transactionHash: receipt.transactionHash,
      mintedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      transactionHash: receipt.transactionHash,
      message: "Badge minted successfully!",
    };
  } catch (error) {
    console.error("Error minting badge:", error);
    throw new functions.https.HttpsError(
      "internal",
      `Failed to mint badge: ${error.message}`
    );
  }
});

exports.hasBadge = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const { userAddress, badgeType } = data;

  try {
    const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
    const contract = new ethers.Contract(
      CONTRACT_ADDRESS,
      CONTRACT_ABI,
      provider
    );

    const hasBadge = await contract.hasBadge(userAddress, badgeType);

    return {
      hasBadge: hasBadge,
    };
  } catch (error) {
    console.error("Error checking badge:", error);
    throw new functions.https.HttpsError(
      "internal",
      `Failed to check badge: ${error.message}`
    );
  }
});
