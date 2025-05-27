import '../models/word.dart';

class Round {
  final List<Word> words;
  final int timeLimit;
  int currentWordIndex;
  int score;
  bool isFinished;
  DateTime? startTime;
  DateTime? pauseTime;
  int _accumulatedPauseTime = 0;

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
    
    final now = DateTime.now();
    final elapsedMillis = now.difference(startTime!).inMilliseconds - _accumulatedPauseTime;
    final remainingMillis = (timeLimit * 1000) - elapsedMillis;
    
    return (remainingMillis / 1000).ceil();
  }

  void start() {
    startTime = DateTime.now();
    pauseTime = null;
    _accumulatedPauseTime = 0;
  }

  void pause() {
    if (pauseTime == null && startTime != null) {
      pauseTime = DateTime.now();
    }
  }

  void resume() {
    if (pauseTime != null && startTime != null) {
      _accumulatedPauseTime += DateTime.now().difference(pauseTime!).inMilliseconds;
      pauseTime = null;
    }
  }

  // Métodos para estadísticas
  int get correctAnswers => words.where((word) => word.isGuessed).length;
  int get wrongAnswers => words.where((word) => !word.isGuessed).length;
  double get accuracy => words.isNotEmpty ? (correctAnswers / words.length) : 0.0;
  int get timeSpent => timeLimit - remainingTime;
} 