class Word {
  final String text;
  final String category;
  bool isGuessed;

  Word({
    required this.text,
    required this.category,
    this.isGuessed = false,
  });

  Word copyWith({
    String? text,
    String? category,
    bool? isGuessed,
  }) {
    return Word(
      text: text ?? this.text,
      category: category ?? this.category,
      isGuessed: isGuessed ?? this.isGuessed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Word &&
        other.text == text &&
        other.category == category &&
        other.isGuessed == isGuessed;
  }

  @override
  int get hashCode => text.hashCode ^ category.hashCode ^ isGuessed.hashCode;

  @override
  String toString() => 'Word(text: $text, category: $category, isGuessed: $isGuessed)';
} 