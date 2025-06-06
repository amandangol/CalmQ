class Affirmation {
  final String id;
  final String text;
  final String category;
  final String? author;

  Affirmation({
    this.id = '',
    required this.text,
    required this.category,
    this.author,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'category': category,
    if (author != null) 'author': author,
  };

  factory Affirmation.fromJson(Map<String, dynamic> json) => Affirmation(
    text: json['text'] as String,
    category: json['category'] as String,
    author: json['author'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Affirmation &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          category == other.category;

  @override
  int get hashCode => text.hashCode ^ category.hashCode;
}
