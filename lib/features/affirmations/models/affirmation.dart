class Affirmation {
  final String text;
  final String category;
  final String language;

  Affirmation({
    required this.text,
    required this.category,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {'text': text, 'category': category, 'language': language};
  }

  factory Affirmation.fromJson(Map<String, dynamic> json) {
    return Affirmation(
      text: json['text'] as String,
      category: json['category'] as String,
      language: json['language'] as String,
    );
  }
}
