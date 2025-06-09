import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  firebase_auth.User? _user;
  bool _rememberMe = false;
  bool _isInitialized = false;
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';

  bool get isLoading => _isLoading;
  firebase_auth.User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get rememberMe => _rememberMe;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Set up auth state listener
      _auth.authStateChanges().listen((user) {
        if (_user != user) {
          _user = user;
          if (user != null) {
            _initializeUserData();
          }
          notifyListeners();
        }
      });

      // Load remember me preference
      await _loadRememberMePreference();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing AuthProvider: $e');
    }
  }

  Future<void> _initializeUserData() async {
    if (_user == null) return;

    try {
      // Only update last login timestamp if it's a new session
      final userDoc = await _firestore
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(_user!.uid).set({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error initializing user data: $e');
    }
  }

  Future<void> _loadRememberMePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _rememberMe = prefs.getBool(_rememberMeKey) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading remember me preference: $e');
    }
  }

  Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_savedEmailKey);
    } catch (e) {
      debugPrint('Error getting saved email: $e');
      return null;
    }
  }

  Future<void> setRememberMe(bool value, {String? email}) async {
    try {
      _rememberMe = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, value);

      if (value && email != null) {
        await prefs.setString(_savedEmailKey, email);
      } else if (!value) {
        await prefs.remove(_savedEmailKey);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting remember me: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Update last login timestamp
      if (_user != null) {
        await _firestore.collection('users').doc(_user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error Code: ${e.code}');
      debugPrint('Firebase Auth Error Message: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Update last logout timestamp
      await _firestore.collection('users').doc(_user!.uid).update({
        'lastLogout': FieldValue.serverTimestamp(),
      });

      // Sign out from Firebase Auth
      await _auth.signOut();

      // Clear remember me data
      await setRememberMe(false);
    } catch (e) {
      debugPrint('Error during sign out: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserInfo({String? displayName, String? photoURL}) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_user != null) {
        await _user!.updateDisplayName(displayName);
        await _user!.updatePhotoURL(photoURL);

        // Update Firestore document
        await _firestore.collection('users').doc(_user!.uid).update({
          if (displayName != null) 'displayName': displayName,
          if (photoURL != null) 'photoURL': photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
