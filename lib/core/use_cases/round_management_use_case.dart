import '../models/enhanced_word.dart';
import '../models/game_progress.dart';
import '../models/round_configuration.dart';
import '../services/enhanced_round_service.dart';

class RoundManagementUseCase {
  final EnhancedRoundService _roundService;

  RoundManagementUseCase(this._roundService);

  Future<List<EnhancedWord>> startNewRound(int roundNumber) async {
    try {
      print('=== INICIANDO RONDA $roundNumber ===');
      final words = await _roundService.generateRoundWords(roundNumber);
      print('Ronda $roundNumber iniciada con ${words.length} palabras');
      return words;
    } catch (e) {
      print('Error iniciando ronda $roundNumber: $e');
      throw Exception('No hay suficientes palabras disponibles para la ronda $roundNumber');
    }
  }

  Future<void> resetGameProgress() async {
    print('=== RESETEANDO PROGRESO DEL JUEGO ===');
    await _roundService.resetAllWords();
    print('Progreso del juego reseteado');
  }

  Future<bool> canStartRound(int roundNumber) async {
    try {
      // Verificar si hay suficientes palabras para la configuración de la ronda
      final configuration = RoundConfigurationProvider.getConfigurationForRound(roundNumber);
      await _roundService.ensureWordsLoaded();
      
      // Verificar cada dificultad requerida
      for (final entry in configuration.wordsPerDifficulty.entries) {
        final difficulty = entry.key;
        final requiredCount = entry.value;
        
        if (requiredCount > 0) {
          final availableWords = _roundService.allWords!
              .where((word) => word.dificultad == difficulty)
              .length;
          
          if (availableWords < requiredCount) {
            return false;
          }
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<RoundConfiguration> getRoundConfiguration(int roundNumber) async {
    return RoundConfigurationProvider.getConfigurationForRound(roundNumber);
  }

  Future<void> completeWord(String palabra, bool wasGuessed) async {
    // Por ahora, este método no hace nada específico
    // En el futuro podría actualizar estadísticas o persistir el estado
    print('Palabra "$palabra" completada. Adivinada: $wasGuessed');
  }

  Future<GameProgress> getGameProgress() async {
    // Por ahora retornamos un progreso básico
    // En el futuro esto podría venir del servicio de persistencia
    return GameProgress(
      totalWords: 0,
      playedWords: 0,
      guessedWords: 0,
    );
  }
} 