import 'round.dart';
import 'word_repository.dart';

class RoundService {
  final WordRepository _wordRepository;
  
  RoundService(this._wordRepository);

  Future<Round> createRound({
    String category = 'mixed',
    int wordCount = 5,
    int timeLimit = 60,
  }) async {
    final words = await _wordRepository.getWords(
      category: category,
      count: wordCount,
    );

    return Round(
      words: words,
      timeLimit: timeLimit,
    );
  }

  void handleSwipe(Round round, bool isCorrect) {
    round.markCurrentWord(isCorrect);
  }

  bool isTimeUp(Round round) {
    return round.remainingTime <= 0;
  }

  Map<String, dynamic> getRoundStats(Round round) {
    return {
      'score': round.score,
      'correctAnswers': round.correctAnswers,
      'wrongAnswers': round.wrongAnswers,
      'accuracy': round.accuracy,
      'timeSpent': round.timeSpent,
      'totalWords': round.words.length,
    };
  }
} 