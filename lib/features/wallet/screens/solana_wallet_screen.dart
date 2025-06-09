// import 'package:flutter/material.dart';
// import 'package:solana/solana.dart';
// import 'package:solana_mobile_client/solana_mobile_client.dart';

// class SolanaWalletScreen extends StatefulWidget {
//   const SolanaWalletScreen({super.key});

//   @override
//   State<SolanaWalletScreen> createState() => _SolanaWalletScreenState();
// }

// class _SolanaWalletScreenState extends State<SolanaWalletScreen> {
//   AuthorizationResult? _result;
//   final _solanaClient = SolanaClient(
//     rpcUrl: Uri.parse("https://api.devnet.solana.com"),
//     websocketUrl: Uri.parse("wss://api.devnet.solana.com"),
//   );
//   final int _lamportsPerSol = 1000000000;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkWalletAvailability();
//   }

//   Future<void> _checkWalletAvailability() async {
//     if (!await LocalAssociationScenario.isAvailable()) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'No MWA Compatible wallet available; please install a wallet',
//             ),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _connectWallet() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final localScenario = await LocalAssociationScenario.create();
//       localScenario.startActivityForResult(null).ignore();
//       final client = await localScenario.start();

//       final result = await client.authorize(
//         identityUri: Uri.parse('https://solana.com'),
//         iconUri: Uri.parse('favicon.ico'),
//         identityName: 'Solana',
//         cluster: 'devnet',
//       );

//       localScenario.close();

//       setState(() {
//         _result = result;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error connecting wallet: $e')));
//       }
//     }
//   }

//   Future<void> _requestAirdrop() async {
//     if (_result == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please connect your wallet first')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _solanaClient.requestAirdrop(
//         address: Ed25519HDPublicKey(_result!.publicKey.toList()),
//         lamports: 1 * _lamportsPerSol,
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Airdrop requested successfully')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error requesting airdrop: $e')));
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _sendTransaction() async {
//     if (_result == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please connect your wallet first')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final localScenario = await LocalAssociationScenario.create();
//       localScenario.startActivityForResult(null).ignore();
//       final client = await localScenario.start();

//       final reAuth = await client.reauthorize(
//         identityUri: Uri.parse('https://solana.com'),
//         iconUri: Uri.parse('favicon.ico'),
//         identityName: 'Solana',
//         authToken: _result!.authToken,
//       );

//       if (reAuth != null) {
//         // Create Memo Program Instruction
//         final instruction = MemoInstruction(
//           signers: [Ed25519HDPublicKey(_result!.publicKey.toList())],
//           memo: 'Example memo',
//         );

//         // Create empty signature and get latest blockhash
//         final signature = Signature(
//           List.filled(64, 0),
//           publicKey: Ed25519HDPublicKey(_result!.publicKey.toList()),
//         );

//         final blockhash = await _solanaClient.rpcClient
//             .getLatestBlockhash()
//             .then((it) => it.value.blockhash);

//         // Create transaction with empty signature
//         final txn = SignedTx(
//           signatures: [signature],
//           compiledMessage: Message.only(instruction).compile(
//             recentBlockhash: blockhash,
//             feePayer: Ed25519HDPublicKey(_result!.publicKey.toList()),
//           ),
//         );

//         // Sign and send transaction
//         final result = await client.signAndSendTransactions(
//           transactions: [Uint8List.fromList(txn.toByteArray().toList())],
//         );

//         await localScenario.close();

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Transaction sent! View on Solscan: https://solscan.io/tx/${base58encode(result.signatures[0])}?cluster=devnet',
//               ),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error sending transaction: $e')),
//         );
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Solana Wallet')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (_isLoading)
//                 const CircularProgressIndicator()
//               else ...[
//                 if (_result == null)
//                   ElevatedButton(
//                     onPressed: _connectWallet,
//                     child: const Text('Connect Wallet'),
//                   )
//                 else ...[
//                   const Icon(
//                     Icons.account_balance_wallet,
//                     size: 64,
//                     color: Colors.green,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Wallet Address:',
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     base58encode(_result!.publicKey),
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   const SizedBox(height: 24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         onPressed: _requestAirdrop,
//                         child: const Text('Request Airdrop'),
//                       ),
//                       const SizedBox(width: 16),
//                       ElevatedButton(
//                         onPressed: _sendTransaction,
//                         child: const Text('Send Transaction'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
