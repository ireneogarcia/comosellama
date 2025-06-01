class GameProgress {
  final int totalWords;
  final int playedWords;
  final int guessedWords;

  GameProgress({
    required this.totalWords,
    required this.playedWords,
    required this.guessedWords,
  });

  double get progressPercentage => totalWords > 0 ? (playedWords / totalWords) * 100 : 0;
  double get successPercentage => playedWords > 0 ? (guessedWords / playedWords) * 100 : 0;
  int get unplayedWords => totalWords - playedWords;
  int get notGuessedWords => playedWords - guessedWords;

  @override
  String toString() {
    return 'GameProgress(total: $totalWords, played: $playedWords, guessed: $guessedWords)';
  }
} 