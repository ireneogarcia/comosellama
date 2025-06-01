import '../models/word.dart';

class Round {
  final int roundNumber;
  final List<Word> words;
  final String? category;
  final int timeLimit;
  int currentWordIndex;
  int score;
  bool isFinished;
  DateTime? startTime;
  DateTime? pauseTime;
  int _accumulatedPauseTime = 0;

  Round({
    required this.roundNumber,
    required List<dynamic> words, // Puede ser List<String> o List<Word>
    this.category,
    this.timeLimit = 60,
    this.currentWordIndex = 0,
    this.score = 0,
    this.isFinished = false,
  }) : words = _convertToWords(words);

  // Método estático para convertir strings a Words si es necesario
  static List<Word> _convertToWords(List<dynamic> words) {
    return words.map((word) {
      if (word is String) {
        return Word(
          text: word,
          category: 'mixed', // Categoría por defecto
        );
      } else if (word is Word) {
        return word;
      } else {
        throw ArgumentError('Words must be either String or Word objects');
      }
    }).toList();
  }

  bool get hasNextWord => currentWordIndex < words.length - 1;
  
  Word get currentWord => words[currentWordIndex];

  void markCurrentWord(bool guessed) {
    words[currentWordIndex].isGuessed = guessed;
    if (guessed) score++;
    
    // Verificar si se han acertado todas las palabras
    if (_allWordsGuessed()) {
      print('🎉 ¡Todas las palabras acertadas! Finalizando ronda automáticamente.');
      isFinished = true;
      return;
    }
    
    // Si no se han acertado todas, continuar con la lógica normal
    if (hasNextWord) {
      currentWordIndex++;
    } else {
      isFinished = true;
    }
  }

  // Método para verificar si todas las palabras han sido acertadas
  bool _allWordsGuessed() {
    return words.every((word) => word.isGuessed);
  }

  // Getter para verificar si todas las palabras han sido acertadas (público)
  bool get allWordsGuessed => _allWordsGuessed();

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