// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/widgets.dart';
// import 'package:auralynn/firebase_options.dart';
// import 'package:auralynn/utils/achievement_data.dart';

// void main() async {
//   try {
//     print('Initializing Firebase...');
//     WidgetsFlutterBinding.ensureInitialized();
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     print('Firebase initialized successfully');

//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//     print('Starting achievement upload...');
//     print('Total achievements to upload: ${allAchievements.length}');

//     for (var achievementData in allAchievements) {
//       try {
//         final String id = achievementData['id'] as String;
//         print('\nProcessing achievement: $id');

//         // Use the 'id' field from your data as the document ID in Firestore
//         await firestore.collection('achievements').doc(id).set(achievementData);
//         print('✓ Successfully uploaded: ${achievementData['title']}');
//       } catch (e) {
//         print('✗ Error uploading achievement ${achievementData['title']}:');
//         print('  Error details: $e');
//       }
//     }

//     print('\nAll achievements processed.');
//     print('Please check the Firebase Console to verify the uploads.');
//   } catch (e) {
//     print('\nFatal error occurred:');
//     print(e);
//   }
// }
