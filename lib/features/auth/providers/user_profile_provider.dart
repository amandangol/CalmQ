import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> saveUserProfile({
    required String name,
    required int age,
    String? gender,
    List<String> goals = const [],
    List<String> causes = const [],
    String? stressFrequency,
    String? healthyEating,
    String? meditationExperience,
    String? sleepQuality,
    String? happinessLevel,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('not-authenticated');
      }

      // Check if this is a new profile or update
      final docRef = _firestore.collection('users').doc(user.uid);
      final existingDoc = await docRef.get();

      final now = DateTime.now();
      final userProfile = UserProfile(
        uid: user.uid,
        name: name,
        age: age,
        gender: gender,
        goals: goals,
        causes: causes,
        stressFrequency: stressFrequency,
        healthyEating: healthyEating,
        meditationExperience: meditationExperience,
        sleepQuality: sleepQuality,
        happinessLevel: happinessLevel,
        createdAt: existingDoc.exists
            ? (existingDoc.data()?['createdAt'] != null
                  ? DateTime.parse(existingDoc.data()!['createdAt'])
                  : now)
            : now,
        updatedAt: now,
      );

      // Save to Firestore
      await docRef.set(userProfile.toJson(), SetOptions(merge: true));

      _userProfile = userProfile;
      print('User profile saved successfully for uid: ${user.uid}');
    } on FirebaseException catch (e) {
      _error = _handleFirebaseError(e);
      print('Firebase error saving user profile: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      _error = e.toString();
      print('Error saving user profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('not-authenticated');
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        _userProfile = UserProfile.fromJson(doc.data()!);
        print('User profile loaded successfully for uid: ${user.uid}');
      } else {
        _userProfile = null;
        print('No user profile found for uid: ${user.uid}');
      }
    } on FirebaseException catch (e) {
      _error = _handleFirebaseError(e);
      print('Firebase error loading user profile: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      _error = e.toString();
      print('Error loading user profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('not-authenticated');
      }

      final profileWithTimestamp = updatedProfile.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(profileWithTimestamp.toJson());

      _userProfile = profileWithTimestamp;
      print('User profile updated successfully for uid: ${user.uid}');
    } on FirebaseException catch (e) {
      _error = _handleFirebaseError(e);
      print('Firebase error updating user profile: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      _error = e.toString();
      print('Error updating user profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('not-authenticated');
      }

      await _firestore.collection('users').doc(user.uid).delete();
      _userProfile = null;
      print('User profile deleted successfully for uid: ${user.uid}');
    } on FirebaseException catch (e) {
      _error = _handleFirebaseError(e);
      print('Firebase error deleting user profile: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      _error = e.toString();
      print('Error deleting user profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear local state (useful for logout)
  void clearProfile() {
    _userProfile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Helper method to handle Firebase errors
  String _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'permission-denied';
      case 'unavailable':
        return 'unable to start connection';
      case 'deadline-exceeded':
        return 'Request timeout. Please try again.';
      case 'resource-exhausted':
        return 'Too many requests. Please try again later.';
      case 'unauthenticated':
        return 'not-authenticated';
      default:
        return 'Firebase error: ${e.message}';
    }
  }

  // Check if user has completed profile setup
  bool get hasCompletedProfile {
    return _userProfile != null &&
        _userProfile!.name.isNotEmpty &&
        _userProfile!.age > 0;
  }

  // Get user's main wellness goals
  List<String> get primaryGoals {
    return _userProfile?.goals ?? [];
  }

  // Get user's stress level for analytics
  String? get currentStressLevel {
    return _userProfile?.stressFrequency;
  }
}
