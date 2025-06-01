import 'dart:math';
import 'word_repository.dart';
import 'round.dart';
import '../models/round_configuration.dart';
import '../models/difficulty.dart';

class RoundService {
  final WordRepository _wordRepository;
  final Random _random = Random();

  RoundService(this._wordRepository);

  Future<Round> generateRound(int roundNumber, {String? category}) async {
    print('=== GENERANDO RONDA $roundNumber CON SISTEMA MEJORADO ===');
    
    // Obtener la configuración de la ronda (progresiva)
    final configuration = RoundConfigurationProvider.getConfigurationForRound(roundNumber);
    print('Configuración de ronda $roundNumber: ${configuration.wordsPerDifficulty}');
    
    final List<String> selectedWords = [];
    
    // Generar palabras según la configuración de dificultad
    for (final entry in configuration.wordsPerDifficulty.entries) {
      final difficulty = entry.key;
      final count = entry.value;
      
      if (count > 0) {
        final wordsForDifficulty = await _getWordsForDifficulty(difficulty, category);
        
        if (wordsForDifficulty.length < count) {
          print('⚠️ ADVERTENCIA: Solo hay ${wordsForDifficulty.length} palabras de dificultad ${difficulty.value}, pero se necesitan $count');
          // Usar todas las palabras disponibles si no hay suficientes
          selectedWords.addAll(wordsForDifficulty);
          print('Añadidas ${wordsForDifficulty.length} palabras de dificultad ${difficulty.value}');
        } else {
          // Seleccionar palabras aleatorias de esta dificultad
          final shuffled = List<String>.from(wordsForDifficulty)..shuffle(_random);
          selectedWords.addAll(shuffled.take(count));
          print('Añadidas $count palabras de dificultad ${difficulty.value}');
        }
      }
    }
    
    // Verificar que tenemos suficientes palabras
    if (selectedWords.isEmpty) {
      print('⚠️ No se pudieron generar palabras específicas, usando palabras de emergencia...');
      // Usar palabras de emergencia
      selectedWords.addAll([
        'casa', 'perro', 'gato', 'mesa', 'silla',
        'agua', 'fuego', 'tierra', 'aire', 'sol'
      ]);
    }
    
    // Asegurar que tenemos al menos 5 palabras
    while (selectedWords.length < 5) {
      selectedWords.add('palabra${selectedWords.length + 1}');
    }
    
    // Mezclar todas las palabras seleccionadas
    selectedWords.shuffle(_random);
    
    print('Ronda $roundNumber generada con ${selectedWords.length} palabras');
    print('Palabras: $selectedWords');
    
    return Round(
      roundNumber: roundNumber,
      words: selectedWords,
      category: category,
    );
  }

  Future<List<String>> _getWordsForDifficulty(Difficulty difficulty, String? category) async {
    print('🔍 Buscando palabras de dificultad: ${difficulty.value} para categoría: ${category ?? "mixed"}');
    
    // DIAGNÓSTICO: Probar carga del CSV
    await _wordRepository.testCsvLoading();
    
    try {
      // Usar el método getWordsByDifficulty del WordRepository
      final words = await _wordRepository.getWordsByDifficulty(
        difficulty: difficulty.value,
        count: 100, // Obtener muchas palabras para poder seleccionar
      );
      
      print('✅ Encontradas ${words.length} palabras de dificultad ${difficulty.value}');
      
      // Filtrar por categoría si se especifica
      List<String> filteredWords;
      if (category != null && category != 'mixed') {
        final filtered = words.where((word) => word.category == category).toList();
        filteredWords = filtered.map((word) => word.text).toList();
        print('📋 Después de filtrar por categoría "$category": ${filteredWords.length} palabras');
      } else {
        filteredWords = words.map((word) => word.text).toList();
        print('📋 Sin filtro de categoría: ${filteredWords.length} palabras');
      }
      
      // Mostrar algunas palabras de ejemplo
      if (filteredWords.isNotEmpty) {
        final examples = filteredWords.take(3).join(', ');
        print('📝 Ejemplos: $examples');
      }
      
      // Si no hay suficientes palabras de esta dificultad, usar fallback
      if (filteredWords.isEmpty) {
        print('⚠️ No hay palabras de dificultad ${difficulty.value}, usando fallback...');
        return await _getFallbackWords(difficulty, category);
      }
      
      return filteredWords;
    } catch (e) {
      print('❌ Error obteniendo palabras de dificultad ${difficulty.value}: $e');
      print('🔄 Usando fallback...');
      return await _getFallbackWords(difficulty, category);
    }
  }

  Future<List<String>> _getFallbackWords(Difficulty difficulty, String? category) async {
    print('🔄 INICIANDO FALLBACK para dificultad: ${difficulty.value}');
    
    // Estrategia de fallback: usar dificultades similares
    List<Difficulty> fallbackDifficulties;
    
    switch (difficulty) {
      case Difficulty.facil:
        fallbackDifficulties = [Difficulty.media, Difficulty.dificil];
        break;
      case Difficulty.media:
        fallbackDifficulties = [Difficulty.facil, Difficulty.dificil];
        break;
      case Difficulty.dificil:
        fallbackDifficulties = [Difficulty.media, Difficulty.facil];
        break;
      case Difficulty.extrema:
        fallbackDifficulties = [Difficulty.dificil, Difficulty.media];
        break;
    }
    
    print('🎯 Intentando con dificultades de fallback: ${fallbackDifficulties.map((d) => d.value).join(', ')}');
    
    // Intentar con cada dificultad de fallback
    for (final fallbackDifficulty in fallbackDifficulties) {
      print('🔍 Probando fallback con dificultad: ${fallbackDifficulty.value}');
      
      try {
        final words = await _wordRepository.getWordsByDifficulty(
          difficulty: fallbackDifficulty.value,
          count: 50,
        );
        
        print('✅ Fallback encontró ${words.length} palabras de dificultad ${fallbackDifficulty.value}');
        
        List<String> filteredWords;
        if (category != null && category != 'mixed') {
          final filtered = words.where((word) => word.category == category).toList();
          filteredWords = filtered.map((word) => word.text).toList();
          print('📋 Después de filtrar por categoría "$category": ${filteredWords.length} palabras');
        } else {
          filteredWords = words.map((word) => word.text).toList();
          print('📋 Sin filtro de categoría: ${filteredWords.length} palabras');
        }
        
        if (filteredWords.isNotEmpty) {
          final examples = filteredWords.take(3).join(', ');
          print('✅ Usando ${filteredWords.length} palabras de dificultad ${fallbackDifficulty.value} como fallback para ${difficulty.value}');
          print('📝 Ejemplos: $examples');
          return filteredWords;
        } else {
          print('⚠️ No hay palabras después del filtro para ${fallbackDifficulty.value}');
        }
      } catch (e) {
        print('❌ Error con fallback ${fallbackDifficulty.value}: $e');
        continue;
      }
    }
    
    // Si todo falla, usar palabras genéricas
    print('🚨 ÚLTIMO RECURSO: Usando palabras genéricas');
    return ['casa', 'perro', 'gato', 'mesa', 'silla', 'agua', 'fuego', 'tierra', 'aire', 'sol'];
  }

  Future<List<String>> getAvailableCategories() async {
    return _wordRepository.availableCategories;
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