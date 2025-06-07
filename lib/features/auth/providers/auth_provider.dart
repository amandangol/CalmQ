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
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';

  bool get isLoading => _isLoading;
  firebase_auth.User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get rememberMe => _rememberMe;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    notifyListeners();
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedEmailKey);
  }

  Future<void> setRememberMe(bool value, {String? email}) async {
    _rememberMe = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);

    if (value && email != null) {
      await prefs.setString(_savedEmailKey, email);
    } else if (!value) {
      await prefs.remove(_savedEmailKey);
    }

    notifyListeners();
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
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
      rethrow; // Rethrow to handle in the UI
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
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signOut();
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
