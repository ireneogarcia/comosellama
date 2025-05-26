class Word {
  final String text;
  final String category;
  bool isGuessed;

  Word({
    required this.text,
    required this.category,
    this.isGuessed = false,
  });
}

class Round {
  final List<Word> words;
  final int timeLimit;
  int currentWordIndex;
  int score;
  bool isFinished;
  DateTime? startTime;

  Round({
    required this.words,
    this.timeLimit = 60,
    this.currentWordIndex = 0,
    this.score = 0,
    this.isFinished = false,
  });

  bool get hasNextWord => currentWordIndex < words.length - 1;
  
  Word get currentWord => words[currentWordIndex];

  void markCurrentWord(bool guessed) {
    words[currentWordIndex].isGuessed = guessed;
    if (guessed) score++;
    if (hasNextWord) {
      currentWordIndex++;
    } else {
      isFinished = true;
    }
  }

  int get remainingTime {
    if (startTime == null) return timeLimit;
    final elapsed = DateTime.now().difference(startTime!).inSeconds;
    return timeLimit - elapsed;
  }

  void start() {
    startTime = DateTime.now();
  }
} 