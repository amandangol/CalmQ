import 'package:flutter/material.dart';
import '../models/affirmation.dart';

class AffirmationProvider extends ChangeNotifier {
  List<Affirmation> _affirmations = [
    Affirmation(
      text: "You are doing better than you think.",
      category: "self-esteem",
      language: "en",
    ),
    Affirmation(
      text: "Every day is a new opportunity to grow.",
      category: "growth",
      language: "en",
    ),
    Affirmation(
      text: "You are stronger than your challenges.",
      category: "strength",
      language: "en",
    ),
    Affirmation(
      text:
          "Your peace is more important than driving yourself crazy trying to understand why something happened.",
      category: "peace",
      language: "en",
    ),
    Affirmation(
      text: "You are worthy of love and respect.",
      category: "self-worth",
      language: "en",
    ),
  ];

  Affirmation? _dailyAffirmation;
  String? _selectedCategory;

  Affirmation? get dailyAffirmation => _dailyAffirmation;
  String? get selectedCategory => _selectedCategory;
  List<String> get categories =>
      _affirmations.map((a) => a.category).toSet().toList();

  AffirmationProvider() {
    _setDailyAffirmation();
  }

  void _setDailyAffirmation() {
    _affirmations.shuffle();
    _dailyAffirmation = _affirmations.first;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Affirmation getRandomAffirmation() {
    final filteredAffirmations = _selectedCategory != null
        ? _affirmations.where((a) => a.category == _selectedCategory).toList()
        : _affirmations;

    filteredAffirmations.shuffle();
    return filteredAffirmations.first;
  }

  void refreshDailyAffirmation() {
    _setDailyAffirmation();
  }
}
