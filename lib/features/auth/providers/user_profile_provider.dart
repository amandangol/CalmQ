import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import 'package:flutter/foundation.dart';

class UserProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _hasLoadedProfile = false;
  String? _error;
  bool _isInitialized = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get hasLoadedProfile => _hasLoadedProfile;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  // Initialize the provider and listen to auth state changes
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          // User is signed in, load their profile
          await loadUserProfile();
        } else {
          // User is signed out, clear profile
          clearProfile();
        }
      });

      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
      print('Error initializing UserProfileProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserProfile({
    required String name,
    required int age,
    String? gender,
    List<String>? goals,
    List<String>? causes,
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
        throw Exception('User not authenticated');
      }

      final userData = {
        'uid': user.uid,
        'name': name,
        'age': age,
        'gender': gender,
        'goals': goals ?? [],
        'causes': causes ?? [],
        'stressFrequency': stressFrequency,
        'healthyEating': healthyEating,
        'meditationExperience': meditationExperience,
        'sleepQuality': sleepQuality,
        'happinessLevel': happinessLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // If this is a new profile, add createdAt
      if (_userProfile == null) {
        userData['createdAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      // Reload the profile after saving
      await loadUserProfile();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw Exception('Error saving user profile: $e');
    }
  }

  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = user.uid; // Add the user ID to the data
        _userProfile = UserProfile.fromJson(data);
        _hasLoadedProfile = true;
      } else {
        _userProfile = null;
        _hasLoadedProfile = false;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw Exception('Error loading user profile: $e');
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
        updatedAt: Timestamp.now(),
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
      _hasLoadedProfile = true;
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
    _hasLoadedProfile = false;
    _error = null;
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
