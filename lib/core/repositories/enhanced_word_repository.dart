import '../models/enhanced_word.dart';
import '../models/difficulty.dart';
import '../models/word_status.dart';
import '../services/csv_word_loader.dart';
import '../services/word_persistence_service.dart';

class EnhancedWordRepository {
  final WordPersistenceService _persistenceService;
  List<EnhancedWord>? _allWords;
  Map<String, WordStatus>? _wordsStatus;

  EnhancedWordRepository(this._persistenceService);

  Future<void> _ensureWordsLoaded() async {
    if (_allWords == null) {
      print('=== CARGANDO PALABRAS EN REPOSITORY ===');
      _allWords = await CsvWordLoader.loadWordsFromCsv();
      print('Repository: Cargadas ${_allWords!.length} palabras');
      
      // Contar por dificultad
      final Map<String, int> difficultyCount = {'fácil': 0, 'media': 0, 'difícil': 0};
      for (final word in _allWords!) {
        difficultyCount[word.dificultad.value] = (difficultyCount[word.dificultad.value] ?? 0) + 1;
      }
      print('Repository - Distribución por dificultad:');
      difficultyCount.forEach((difficulty, count) {
        print('  $difficulty: $count palabras');
      });
    }
    if (_wordsStatus == null) {
      _wordsStatus = await _persistenceService.loadWordsStatus();
      print('Repository: Cargado estado de ${_wordsStatus!.length} palabras');
    }
  }

  Future<List<EnhancedWord>> getAllWords() async {
    await _ensureWordsLoaded();
    return _allWords!.map((word) {
      final status = _wordsStatus![word.palabra] ?? WordStatus.noJugada;
      return word.copyWith(status: status);
    }).toList();
  }

  Future<List<EnhancedWord>> getWordsByDifficulty(Difficulty difficulty) async {
    final allWords = await getAllWords();
    return allWords.where((word) => word.dificultad == difficulty).toList();
  }

  Future<List<EnhancedWord>> getAvailableWordsByDifficulty(Difficulty difficulty) async {
    final words = await getWordsByDifficulty(difficulty);
    
    // Primero intentar palabras no jugadas
    final unplayedWords = words.where((word) => word.status == WordStatus.noJugada).toList();
    if (unplayedWords.isNotEmpty) {
      return unplayedWords;
    }
    
    // Si no hay palabras no jugadas, usar las no adivinadas
    final notGuessedWords = words.where((word) => word.status == WordStatus.noAdivinada).toList();
    if (notGuessedWords.isNotEmpty) {
      return notGuessedWords;
    }
    
    // Si todas están adivinadas, resetear y devolver todas
    await _resetWordsStatus();
    return await getWordsByDifficulty(difficulty);
  }

  Future<void> markWordAsPlayed(String palabra, WordStatus status) async {
    await _ensureWordsLoaded();
    _wordsStatus![palabra] = status;
    await _persistenceService.markWordAsPlayed(palabra, status);
  }

  Future<void> _resetWordsStatus() async {
    await _persistenceService.resetAllWords();
    _wordsStatus = {};
  }

  Future<Map<WordStatus, int>> getStatistics() async {
    return await _persistenceService.getWordsStatistics();
  }

  Future<Map<Difficulty, Map<WordStatus, int>>> getDetailedStatistics() async {
    final allWords = await getAllWords();
    final stats = <Difficulty, Map<WordStatus, int>>{};
    
    for (final difficulty in Difficulty.values) {
      stats[difficulty] = {
        WordStatus.noJugada: 0,
        WordStatus.adivinada: 0,
        WordStatus.noAdivinada: 0,
      };
    }
    
    for (final word in allWords) {
      stats[word.dificultad]![word.status] = 
          (stats[word.dificultad]![word.status] ?? 0) + 1;
    }
    
    return stats;
  }

  Future<bool> areAllWordsPlayed() async {
    final allWords = await getAllWords();
    return allWords.every((word) => word.status != WordStatus.noJugada);
  }

  Future<bool> areAllWordsGuessed() async {
    final allWords = await getAllWords();
    return allWords.every((word) => word.status == WordStatus.adivinada);
  }

  Future<void> resetAllWords() async {
    await _resetWordsStatus();
    _wordsStatus = {};
  }
} 