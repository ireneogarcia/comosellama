import '../models/enhanced_word.dart';
import '../models/round_configuration.dart';
import '../services/csv_word_loader.dart';
import '../services/word_persistence_service.dart';
import 'dart:math';

class EnhancedRoundService {
  final WordPersistenceService _persistenceService;
  List<EnhancedWord>? allWords;
  final Random _random = Random();

  EnhancedRoundService(this._persistenceService);

  Future<void> ensureWordsLoaded() async {
    if (allWords == null) {
      print('=== CARGANDO PALABRAS EN ENHANCED ROUND SERVICE ===');
      allWords = await CsvWordLoader.loadWordsFromCsv();
      print('Service: Cargadas ${allWords!.length} palabras');
      
      // Contar por dificultad
      final Map<String, int> difficultyCount = {'fácil': 0, 'media': 0, 'difícil': 0, 'extrema': 0};
      for (final word in allWords!) {
        difficultyCount[word.dificultad.value] = (difficultyCount[word.dificultad.value] ?? 0) + 1;
      }
      
      print('Service - Distribución por dificultad:');
      difficultyCount.forEach((difficulty, count) {
        print('  $difficulty: $count palabras');
      });
    }
  }

  Future<List<EnhancedWord>> generateRoundWords(int roundNumber) async {
    await ensureWordsLoaded();
    
    final configuration = RoundConfigurationProvider.getConfigurationForRound(roundNumber);
    final List<EnhancedWord> roundWords = [];

    print('=== GENERANDO RONDA $roundNumber ===');
    print('Configuración: ${configuration.wordsPerDifficulty}');

    for (final entry in configuration.wordsPerDifficulty.entries) {
      final difficulty = entry.key;
      final count = entry.value;
      
      print('Buscando $count palabras de dificultad: ${difficulty.value}');
      
      if (count > 0) {
        // Obtener palabras disponibles de esta dificultad
        final availableWords = allWords!
            .where((word) => word.dificultad == difficulty)
            .toList();
        
        print('Palabras disponibles para ${difficulty.value}: ${availableWords.length}');
        
        if (availableWords.length < count) {
          throw Exception('No hay suficientes palabras de dificultad ${difficulty.value}. '
              'Necesarias: $count, Disponibles: ${availableWords.length}');
        }
        
        // Seleccionar palabras aleatoriamente
        availableWords.shuffle(_random);
        final selectedWords = availableWords.take(count).toList();
        
        print('Palabras seleccionadas para ${difficulty.value}:');
        for (final word in selectedWords) {
          print('  - ${word.palabra} (${word.dificultad.value})');
        }
        
        roundWords.addAll(selectedWords);
      }
    }

    // Mezclar el orden de las palabras en la ronda
    roundWords.shuffle(_random);
    
    print('=== RONDA $roundNumber GENERADA ===');
    print('Total de palabras: ${roundWords.length}');
    final finalCount = <String, int>{'fácil': 0, 'media': 0, 'difícil': 0, 'extrema': 0};
    for (final word in roundWords) {
      finalCount[word.dificultad.value] = (finalCount[word.dificultad.value] ?? 0) + 1;
    }
    print('Distribución final: $finalCount');
    
    return roundWords;
  }

  Future<void> resetAllWords() async {
    await _persistenceService.resetAllWords();
  }
} 