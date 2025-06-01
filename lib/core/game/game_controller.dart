import '../password/round.dart';
import '../password/round_service.dart';
import '../models/team.dart';

class GameController {
  final RoundService _roundService;
  Round? _currentRound;
  List<Team>? _teams;
  int _currentTeamIndex = 0;
  int _currentRoundNumber = 1;
  int _totalRounds = 5; // Por defecto 5 rondas con el nuevo sistema

  GameController(this._roundService);

  // Getters
  Round? get currentRound => _currentRound;
  List<Team>? get teams => _teams;
  Team? get currentTeam => _teams?[_currentTeamIndex];
  int get currentTeamIndex => _currentTeamIndex;
  int get currentRoundNumber => _currentRoundNumber;
  int get totalRounds => _totalRounds;
  bool get isGameFinished => _currentRoundNumber > _totalRounds;

  // Configuración del juego
  void setupGame({
    List<Team>? teams,
    int totalRounds = 5, // Por defecto 5 rondas
  }) {
    _teams = teams;
    _totalRounds = totalRounds;
    _currentTeamIndex = 0;
    _currentRoundNumber = 1;
  }

  // Crear nueva ronda usando el sistema mejorado
  Future<Round> createRound({
    String? category,
    int? roundNumber,
  }) async {
    final roundNum = roundNumber ?? _currentRoundNumber;
    print('=== CREANDO RONDA $roundNum EN GAME CONTROLLER ===');
    
    _currentRound = await _roundService.generateRound(
      roundNum,
      category: category,
    );
    
    print('Ronda $roundNum creada con ${_currentRound!.words.length} palabras');
    return _currentRound!;
  }

  // Método legacy para compatibilidad (deprecated)
  @Deprecated('Use createRound() instead')
  Future<Round> createLegacyRound({
    String category = 'mixed',
    int wordCount = 5,
    int timeLimit = 60,
  }) async {
    // Convertir a nuevo sistema usando ronda 1 por defecto
    return createRound(category: category);
  }

  // Manejar respuesta
  void handleAnswer(bool isCorrect) {
    if (_currentRound == null) return;
    _currentRound!.markCurrentWord(isCorrect);
  }

  // Verificar si el tiempo se agotó
  bool isTimeUp() {
    if (_currentRound == null) return false;
    return _currentRound!.remainingTime <= 0;
  }

  // Finalizar ronda actual
  Map<String, dynamic> finishCurrentRound() {
    if (_currentRound == null) return {};
    
    final stats = {
      'roundNumber': _currentRound!.roundNumber,
      'totalWords': _currentRound!.words.length,
      'correctAnswers': _currentRound!.correctAnswers,
      'wrongAnswers': _currentRound!.wrongAnswers,
      'accuracy': _currentRound!.accuracy,
      'score': _currentRound!.score,
      'timeSpent': _currentRound!.timeSpent,
      'category': _currentRound!.category,
    };
    
    // Actualizar puntuación del equipo actual
    if (_teams != null && _currentTeamIndex < _teams!.length) {
      _teams![_currentTeamIndex].score += _currentRound!.score;
    }
    
    return stats;
  }

  // Avanzar al siguiente turno
  bool moveToNextTurn() {
    if (_teams == null) return false;
    
    _currentTeamIndex = (_currentTeamIndex + 1) % _teams!.length;
    
    // Si volvemos al primer equipo, incrementamos la ronda
    if (_currentTeamIndex == 0) {
      _currentRoundNumber++;
    }
    
    return !isGameFinished;
  }

  // Avanzar a la siguiente ronda directamente
  void moveToNextRound() {
    _currentRoundNumber++;
  }

  // Obtener resultados finales
  List<Team> getFinalResults() {
    if (_teams == null) return [];
    
    final sortedTeams = List<Team>.from(_teams!)
      ..sort((a, b) => b.score.compareTo(a.score));
    
    return sortedTeams;
  }

  // Verificar si hay ganador
  bool hasWinner() {
    final results = getFinalResults();
    if (results.length < 2) return true;
    return results[0].score > results[1].score;
  }

  // Verificar si hay empate
  bool isTie() {
    final results = getFinalResults();
    if (results.length < 2) return false;
    return results[0].score == results[1].score;
  }

  // Reiniciar juego
  void resetGame() {
    _currentRound = null;
    _currentTeamIndex = 0;
    _currentRoundNumber = 1;
    
    // Reiniciar puntuaciones de equipos
    if (_teams != null) {
      for (final team in _teams!) {
        team.score = 0;
      }
    }
  }

  // Obtener categorías disponibles
  Future<List<String>> getAvailableCategories() async {
    return _roundService.getAvailableCategories();
  }
} 