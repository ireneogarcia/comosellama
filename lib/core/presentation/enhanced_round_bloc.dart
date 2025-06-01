import 'package:flutter/foundation.dart';
import '../models/enhanced_word.dart';
import '../models/difficulty.dart';
import '../models/round_configuration.dart';
import '../models/game_progress.dart';
import '../use_cases/round_management_use_case.dart';

class EnhancedRoundBloc extends ChangeNotifier {
  final RoundManagementUseCase _roundManagementUseCase;

  EnhancedRoundBloc(this._roundManagementUseCase);

  // Estado
  List<EnhancedWord> _currentRoundWords = [];
  int _currentRoundNumber = 1;
  int _currentWordIndex = 0;
  bool _isLoading = false;
  String? _error;
  GameProgress? _gameProgress;
  RoundConfiguration? _currentConfiguration;

  // Getters
  List<EnhancedWord> get currentRoundWords => _currentRoundWords;
  int get currentRoundNumber => _currentRoundNumber;
  int get currentWordIndex => _currentWordIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  GameProgress? get gameProgress => _gameProgress;
  RoundConfiguration? get currentConfiguration => _currentConfiguration;
  
  EnhancedWord? get currentWord => 
      _currentWordIndex < _currentRoundWords.length 
          ? _currentRoundWords[_currentWordIndex] 
          : null;
  
  bool get hasMoreWords => _currentWordIndex < _currentRoundWords.length;
  bool get isRoundComplete => _currentWordIndex >= _currentRoundWords.length;

  // Métodos públicos
  Future<void> startNewRound([int? roundNumber]) async {
    _setLoading(true);
    _clearError();

    try {
      final targetRound = roundNumber ?? _currentRoundNumber;
      
      // Verificar si se puede generar la ronda
      final canStart = await _roundManagementUseCase.canStartRound(targetRound);
      if (!canStart) {
        throw Exception('No hay suficientes palabras disponibles para la ronda $targetRound');
      }

      // Obtener configuración de la ronda
      _currentConfiguration = await _roundManagementUseCase.getRoundConfiguration(targetRound);
      
      // Generar palabras de la ronda
      _currentRoundWords = await _roundManagementUseCase.startNewRound(targetRound);
      _currentRoundNumber = targetRound;
      _currentWordIndex = 0;
      
      // Actualizar progreso
      await _updateGameProgress();
      
    } catch (e) {
      _setError('Error al iniciar la ronda: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeCurrentWord(bool wasGuessed) async {
    if (currentWord == null) return;

    _setLoading(true);
    _clearError();

    try {
      await _roundManagementUseCase.completeWord(currentWord!.palabra, wasGuessed);
      _currentWordIndex++;
      await _updateGameProgress();
    } catch (e) {
      _setError('Error al completar la palabra: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> nextWord() async {
    if (hasMoreWords) {
      _currentWordIndex++;
      notifyListeners();
    }
  }

  Future<void> previousWord() async {
    if (_currentWordIndex > 0) {
      _currentWordIndex--;
      notifyListeners();
    }
  }

  Future<void> nextRound() async {
    await startNewRound(_currentRoundNumber + 1);
  }

  Future<void> loadGameProgress() async {
    _setLoading(true);
    _clearError();

    try {
      await _updateGameProgress();
    } catch (e) {
      _setError('Error al cargar el progreso: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetGame() async {
    _setLoading(true);
    _clearError();

    try {
      await _roundManagementUseCase.resetGameProgress();
      _currentRoundWords = [];
      _currentRoundNumber = 1;
      _currentWordIndex = 0;
      _currentConfiguration = null;
      await _updateGameProgress();
    } catch (e) {
      _setError('Error al resetear el juego: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Métodos privados
  Future<void> _updateGameProgress() async {
    _gameProgress = await _roundManagementUseCase.getGameProgress();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Métodos de información
  String getRoundSummary() {
    if (_currentConfiguration == null) return '';
    
    final config = _currentConfiguration!;
    final parts = <String>[];
    
    if (config.wordsPerDifficulty[Difficulty.facil]! > 0) {
      parts.add('${config.wordsPerDifficulty[Difficulty.facil]} fáciles');
    }
    if (config.wordsPerDifficulty[Difficulty.media]! > 0) {
      parts.add('${config.wordsPerDifficulty[Difficulty.media]} medias');
    }
    if (config.wordsPerDifficulty[Difficulty.dificil]! > 0) {
      parts.add('${config.wordsPerDifficulty[Difficulty.dificil]} difíciles');
    }
    if (config.wordsPerDifficulty[Difficulty.extrema] != null && config.wordsPerDifficulty[Difficulty.extrema]! > 0) {
      parts.add('${config.wordsPerDifficulty[Difficulty.extrema]} extremas');
    }
    
    return 'Ronda $_currentRoundNumber: ${parts.join(', ')}';
  }

  String getProgressSummary() {
    if (_gameProgress == null) return '';
    
    return 'Progreso: ${_gameProgress!.playedWords}/${_gameProgress!.totalWords} palabras jugadas '
           '(${_gameProgress!.guessedWords} adivinadas)';
  }
} 