import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/affirmation.dart';

class AffirmationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final String _baseUrl = 'https://www.affirmations.dev';

  List<Affirmation> _affirmations = [];
  List<Affirmation> _favoriteAffirmations = [];
  List<Affirmation> _customAffirmations = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters
  List<Affirmation> get affirmations => _affirmations;
  List<Affirmation> get favoriteAffirmations => _favoriteAffirmations;
  List<Affirmation> get customAffirmations => _customAffirmations;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get categories => ['All', ...categoryTags.keys.toList()];

  // Categories for mental wellness
  final Map<String, List<String>> categoryTags = {
    'Self-Love': ['self-love', 'confidence'],
    'Anxiety Relief': ['anxiety', 'peace'],
    'Stress Management': ['stress', 'calm'],
    'Confidence': ['confidence', 'strength'],
    'Gratitude': ['gratitude', 'joy'],
    'Mindfulness': ['mindfulness', 'peace'],
    'Healing': ['healing', 'hope'],
    'Growth': ['growth', 'wisdom'],
    'Peace': ['peace', 'calm'],
  };

  AffirmationProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Load default affirmations first (these are shared across users)
      await _loadDefaultAffirmations();

      // Then load user-specific data if user is authenticated
      final user = _auth.currentUser;
      if (user != null) {
        await _loadUserData(user);
      }

      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData(firebase_auth.User user) async {
    try {
      // Load favorites and custom affirmations in parallel
      final futures = await Future.wait([
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .get(),
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('custom_affirmations')
            .get(),
      ]);

      final favoritesSnapshot = futures[0] as QuerySnapshot;
      final customSnapshot = futures[1] as QuerySnapshot;

      _favoriteAffirmations = favoritesSnapshot.docs
          .map(
            (doc) => Affirmation.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      _customAffirmations = customSnapshot.docs
          .map(
            (doc) => Affirmation.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadDefaultAffirmations() async {
    try {
      final snapshot = await _firestore
          .collection('default_affirmations')
          .get();

      if (snapshot.docs.isEmpty) {
        await initializeDefaultAffirmations();
      } else {
        _affirmations = snapshot.docs
            .map((doc) => Affirmation.fromJson(doc.data()))
            .toList();
      }
    } catch (e) {
      print('Error loading default affirmations: $e');
      _initializeFallbackAffirmations();
    }
  }

  // Initialize default affirmations
  Future<void> initializeDefaultAffirmations() async {
    try {
      List<Affirmation> allAffirmations = [];

      for (var category in categoryTags.keys) {
        for (int i = 0; i < 5; i++) {
          final response = await http.get(Uri.parse(_baseUrl));

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            final String affirmationText = data['affirmation'] as String;

            allAffirmations.add(
              Affirmation(text: affirmationText, category: category),
            );
          }
        }
      }

      // Save to Firestore
      final batch = _firestore.batch();
      for (var affirmation in allAffirmations) {
        final docRef = _firestore.collection('default_affirmations').doc();
        batch.set(docRef, affirmation.toJson());
      }
      await batch.commit();

      _affirmations = allAffirmations;
    } catch (e) {
      print('Error initializing default affirmations: $e');
      _initializeFallbackAffirmations();
    }
  }

  // Fallback affirmations
  void _initializeFallbackAffirmations() {
    final defaultAffirmations = [
      Affirmation(
        text: "I am worthy of love, respect, and happiness.",
        category: "Self-Love",
      ),
      Affirmation(
        text: "I choose to release anxiety and embrace peace.",
        category: "Anxiety Relief",
      ),
      Affirmation(
        text: "I am capable of handling any challenge that comes my way.",
        category: "Confidence",
      ),
      Affirmation(
        text: "I am grateful for all the blessings in my life.",
        category: "Gratitude",
      ),
      Affirmation(
        text: "I am present in this moment and at peace.",
        category: "Mindfulness",
      ),
    ];

    _affirmations = defaultAffirmations;
  }

  // Get filtered affirmations based on category
  List<Affirmation> getFilteredAffirmations() {
    return _affirmations.where((affirmation) {
      return _selectedCategory == 'All' ||
          affirmation.category == _selectedCategory;
    }).toList();
  }

  // Set selected category
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Affirmation affirmation) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        return;
      }

      final isFavorite = _favoriteAffirmations.any(
        (fav) => fav.text == affirmation.text,
      );

      if (isFavorite) {
        // Remove from favorites
        final favoriteToRemove = _favoriteAffirmations.firstWhere(
          (fav) => fav.text == affirmation.text,
        );
        if (favoriteToRemove.id.isNotEmpty) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .doc(favoriteToRemove.id)
              .delete();
        }
        _favoriteAffirmations.removeWhere(
          (fav) => fav.text == affirmation.text,
        );
      } else {
        // Add to favorites
        final docRef = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .add(affirmation.toJson());

        final favoriteAffirmation = Affirmation(
          id: docRef.id,
          text: affirmation.text,
          category: affirmation.category,
        );
        _favoriteAffirmations.add(favoriteAffirmation);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle favorite: $e';
      print(_error);
    }
  }

  // Check if affirmation is favorite
  bool isFavorite(Affirmation affirmation) {
    return _favoriteAffirmations.any((fav) => fav.text == affirmation.text);
  }

  // Get daily affirmation
  Affirmation getDailyAffirmation() {
    if (_affirmations.isEmpty) {
      return Affirmation(
        text: "I am capable of amazing things.",
        category: "Confidence",
      );
    }
    final now = DateTime.now();
    final index = now.day % _affirmations.length;
    return _affirmations[index];
  }

  //  new custom affirmation
  Future<void> addAffirmation(Affirmation affirmation) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        return;
      }

      _isLoading = true;
      notifyListeners();

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('custom_affirmations')
          .add(affirmation.toJson());

      final newAffirmation = Affirmation(
        id: docRef.id,
        text: affirmation.text,
        category: affirmation.category,
      );

      _customAffirmations.add(newAffirmation);
      _affirmations.add(newAffirmation);
      _error = null;
    } catch (e) {
      _error = 'Failed to add affirmation: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete affirmation
  Future<void> deleteAffirmation(Affirmation affirmation) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        return;
      }

      _isLoading = true;
      notifyListeners();

      // Delete from custom affirmations if it exists
      if (_customAffirmations.contains(affirmation)) {
        if (affirmation.id.isNotEmpty) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('custom_affirmations')
              .doc(affirmation.id)
              .delete();
        }
        _customAffirmations.remove(affirmation);
      }

      // Remove from favorites if it exists
      if (_favoriteAffirmations.contains(affirmation)) {
        final favoriteToRemove = _favoriteAffirmations.firstWhere(
          (fav) => fav.text == affirmation.text,
        );
        if (favoriteToRemove.id.isNotEmpty) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .doc(favoriteToRemove.id)
              .delete();
        }
        _favoriteAffirmations.removeWhere(
          (fav) => fav.text == affirmation.text,
        );
      }

      _affirmations.remove(affirmation);
      _error = null;
    } catch (e) {
      _error = 'Failed to delete affirmation: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    _isInitialized = false;
    await _initializeData();
  }
}
