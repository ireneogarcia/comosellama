import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dopamine_theme.dart';
import '../blocs/round_bloc.dart';
import 'team_transition_screen.dart';
import 'team_results_screen.dart';
import 'word_list_game_screen.dart';
import '../../core/models/team.dart';
import '../../core/models/game_mode.dart';
import '../../core/services/feedback_service.dart';

class GameScreen extends StatefulWidget {
  final String category;
  final Team? team;
  final int? currentRound;
  final int? totalRounds;
  final List<Team>? allTeams;
  final int timeLimit;
  final GameMode gameMode;
  
  const GameScreen({
    super.key,
    required this.category,
    this.team,
    this.currentRound,
    this.totalRounds,
    this.allTeams,
    this.timeLimit = 60,
    this.gameMode = GameMode.oneByOne,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _hasNavigated = false; // Bandera para evitar navegaciones múltiples

  @override
  void initState() {
    super.initState();
    
    print('=== INICIALIZANDO GAME SCREEN ===');
    print('Equipo: ${widget.team?.name ?? "Individual"}');
    print('Ronda: ${widget.currentRound ?? 1}');
    print('Modo de juego: ${widget.gameMode}');
    print('Categoría: ${widget.category}');
    
    // Si es modalidad de lista de palabras, redirigir a la pantalla correspondiente
    if (widget.gameMode == GameMode.wordList) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasNavigated) {
          _hasNavigated = true;
          print('Redirigiendo a WordListGameScreen...');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WordListGameScreen(
                category: widget.category,
                team: widget.team,
                currentRound: widget.currentRound,
                totalRounds: widget.totalRounds,
                allTeams: widget.allTeams,
                timeLimit: widget.timeLimit,
                gameMode: widget.gameMode,
              ),
            ),
          );
        }
      });
      return;
    }
    
    // RESETEAR EL BLOC INMEDIATAMENTE Y DE FORMA SÍNCRONA
    // Esto debe ocurrir ANTES del primer build para evitar que se ejecute con estado finished
    final roundBloc = Provider.of<RoundBloc>(context, listen: false);
    print('Estado del bloc ANTES del reset: ${roundBloc.state.status}');
    roundBloc.resetState();
    print('Estado del bloc DESPUÉS del reset: ${roundBloc.state.status}');
  }

  @override
  Widget build(BuildContext context) {
    // Si es modalidad de lista de palabras, mostrar loading mientras se redirige
    if (widget.gameMode == GameMode.wordList) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: DopamineGradients.backgroundGradient,
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: DopamineGradients.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: DopamineColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DopamineGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<RoundBloc>(
            builder: (context, roundBloc, child) {
              final state = roundBloc.state;
              
              print('=== GAME SCREEN BUILD - ESTADO: ${state.status} ===');
              print('Equipo: ${widget.team?.name ?? "Individual"}');
              print('Ronda: ${widget.currentRound ?? 1}');
              print('Estado del bloc: ${state.status}');
              if (state.round != null) {
                print('Tiempo restante: ${state.round!.remainingTime}');
                print('Palabras totales: ${state.round!.words.length}');
                print('Palabra actual: ${state.round!.currentWordIndex}');
              }
              
              switch (state.status) {
                case RoundStatus.initial:
                  print('Mostrando loading - estado INITIAL');
                  _startRound(roundBloc);
                  return _buildLoadingView();
                  
                case RoundStatus.loading:
                  print('Mostrando loading - estado LOADING');
                  return _buildLoadingView();
                  
                case RoundStatus.playing:
                  print('Mostrando juego - estado PLAYING');
                  return _GameView(
                    word: state.round!.currentWord.text,
                    timeRemaining: state.round!.remainingTime,
                    score: state.round!.score,
                    totalWords: state.round!.words.length,
                    currentWordIndex: state.round!.currentWordIndex,
                    onSwipe: (right) => _handleSwipe(roundBloc, right),
                    team: widget.team,
                  );
                  
                case RoundStatus.paused:
                  print('Mostrando pausa - estado PAUSED');
                  return _PausedView(
                    onResume: () => roundBloc.resumeRound(),
                    team: widget.team,
                  );
                  
                case RoundStatus.finished:
                  print('Juego terminado - estado FINISHED, navegando...');
                  return _handleGameFinished(context, roundBloc);
                  
                case RoundStatus.error:
                  print('Error en el juego - estado ERROR: ${state.errorMessage}');
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: DopamineGradients.errorGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: DopamineColors.errorRed.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        'Error: ${state.errorMessage}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
              }
            },
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: DopamineGradients.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: DopamineColors.primaryPurple.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Consumer<RoundBloc>(
      builder: (context, roundBloc, child) {
        if (roundBloc.state.status == RoundStatus.playing) {
          return Container(
            decoration: BoxDecoration(
              gradient: DopamineGradients.warningGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: DopamineColors.warningOrange.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                FeedbackService().buttonTapFeedback();
                roundBloc.pauseRound();
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.pause, color: Colors.white, size: 28),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _handleSwipe(RoundBloc roundBloc, bool right) {
    roundBloc.handleAnswer(right);
  }

  void _startRound(RoundBloc roundBloc) {
    // Evitar iniciar múltiples rondas
    if (roundBloc.state.status != RoundStatus.initial) {
      print('Ronda ya iniciada o en progreso, estado: ${roundBloc.state.status}');
      return;
    }
    
    Future.microtask(() {
      print('=== INICIANDO RONDA EN GAME SCREEN ===');
      print('Categoría: ${widget.category}');
      print('Ronda actual: ${widget.currentRound ?? 1}');
      print('Tiempo límite: ${widget.timeLimit}');
      print('Estado actual del bloc: ${roundBloc.state.status}');
      
      roundBloc.startNewRound(
        category: widget.category,
        roundNumber: widget.currentRound ?? 1,
        timeLimit: widget.timeLimit,
      );
    });
  }

  Widget _handleGameFinished(BuildContext context, RoundBloc roundBloc) {
    // Usar Future.microtask para asegurar que la navegación ocurra después del build
    Future.microtask(() => _navigateAfterRound(context, roundBloc));
    
    // Mostrar una pantalla de carga mientras se navega
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DopamineColors.backgroundDark,
            widget.team?.color ?? DopamineColors.primaryPurple,
            (widget.team?.color ?? DopamineColors.primaryPurple).withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: DopamineGradients.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: DopamineColors.primaryPurple.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                '¡Ronda completada!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateAfterRound(BuildContext context, RoundBloc roundBloc) {
    if (_hasNavigated) {
      print('Navegación ya realizada, evitando duplicado');
      return;
    }
    _hasNavigated = true;
    
    if (widget.team != null && widget.allTeams != null) {
      // Modo por equipos
      final roundScore = roundBloc.state.round?.score ?? 0;
      if (widget.team != null) {
        widget.team!.score += roundScore;
      }
      
      // Calcular siguiente equipo y ronda
      final currentTeamIndex = widget.allTeams!.indexOf(widget.team!);
      final nextTeamIndex = (currentTeamIndex + 1) % widget.allTeams!.length;
      final nextTeam = widget.allTeams![nextTeamIndex];
      
      // La ronda solo se incrementa cuando volvemos al primer equipo (todos han jugado)
      final nextRound = nextTeamIndex == 0 ? widget.currentRound! + 1 : widget.currentRound!;

      print('=== NAVEGACIÓN DESPUÉS DE RONDA ===');
      print('Equipo actual: ${widget.team!.name} (índice: $currentTeamIndex)');
      print('Siguiente equipo: ${nextTeam.name} (índice: $nextTeamIndex)');
      print('Ronda actual: ${widget.currentRound}');
      print('Siguiente ronda: $nextRound');
      print('Total rondas: ${widget.totalRounds}');

      // Lógica corregida: 
      // - Si nextTeamIndex != 0: aún hay equipos por jugar en la ronda actual
      // - Si nextTeamIndex == 0 Y nextRound <= totalRounds: nueva ronda válida
      final shouldContinue = (nextTeamIndex != 0) || (nextTeamIndex == 0 && nextRound <= widget.totalRounds!);
      
      print('¿Debe continuar? $shouldContinue');
      print('Razón: nextTeamIndex=$nextTeamIndex, nextRound=$nextRound, totalRounds=${widget.totalRounds}');

      if (shouldContinue) {
        // Continuar con el siguiente turno
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TeamTransitionScreen(
              team: nextTeam,
              currentRound: nextRound,
              totalRounds: widget.totalRounds!,
              timeLimit: widget.timeLimit,
              category: widget.category,
              allTeams: widget.allTeams!,
              gameMode: widget.gameMode,
            ),
          ),
        );
      } else {
        // Juego terminado - ir a resultados
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TeamResultsScreen(
              teams: widget.allTeams!,
              onPlayAgain: () {
                // Reiniciar puntuaciones
                for (final team in widget.allTeams!) {
                  team.score = 0;
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamTransitionScreen(
                      team: widget.allTeams![0],
                      currentRound: 1,
                      totalRounds: widget.totalRounds!,
                      timeLimit: widget.timeLimit,
                      category: widget.category,
                      allTeams: widget.allTeams!,
                      gameMode: widget.gameMode,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } else {
      // Modo individual - mostrar estadísticas
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: _FinishedView(
              stats: roundBloc.finishRound(),
            ),
          ),
        ),
      );
    }
  }
}

class _GameView extends StatelessWidget {
  final String word;
  final int timeRemaining;
  final int score;
  final int totalWords;
  final int currentWordIndex;
  final Function(bool) onSwipe;
  final Team? team;

  const _GameView({
    required this.word,
    required this.timeRemaining,
    required this.score,
    required this.totalWords,
    required this.currentWordIndex,
    required this.onSwipe,
    this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            team?.color.withOpacity(0.1) ?? DopamineColors.primaryPurple.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          final isRightSwipe = details.primaryVelocity! > 0;
          onSwipe(isRightSwipe);
        },
        child: Column(
          children: [
            if (team != null) _buildTeamHeader(),
            _buildTimer(),
            const SizedBox(height: 20),
            _buildScore(),
            const SizedBox(height: 30),
            Expanded(
              child: _buildWordSection(),
            ),
            _buildProgress(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildSwipeInstructions(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: team!.color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 25,
              child: Text(
                team!.name[0],
                style: TextStyle(
                  color: team!.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              team!.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final isLowTime = timeRemaining <= 10;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: isLowTime ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLowTime ? Colors.red : Colors.blue,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            timeRemaining.toString(),
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: isLowTime ? Colors.red : Colors.blue,
            ),
          ).animate(
            target: isLowTime ? 1 : 0,
          ).shake(duration: const Duration(milliseconds: 500)),
          Text(
            'segundos restantes',
            style: TextStyle(
              fontSize: 16,
              color: isLowTime ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScore() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Text(
        'Puntuación: $score',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildWordSection() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Palabra a adivinar:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              word.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ).animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (currentWordIndex + 1) / totalWords,
            minHeight: 8,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              team?.color ?? DopamineColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Palabra ${currentWordIndex + 1} de $totalWords',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                FeedbackService().wrongAnswerFeedback();
                onSwipe(false);
              },
              icon: const Icon(Icons.close, size: 28),
              label: const Text(
                'FALLO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                FeedbackService().correctAnswerFeedback();
                onSwipe(true);
              },
              icon: const Icon(Icons.check, size: 28),
              label: const Text(
                'ACIERTO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSwipeInstruction(
            icon: Icons.swipe_left,
            text: 'Desliza ←',
            color: Colors.red,
          ),
          const Text(
            'o usa los botones',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          _buildSwipeInstruction(
            icon: Icons.swipe_right,
            text: 'Desliza →',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeInstruction({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PausedView extends StatelessWidget {
  final VoidCallback onResume;
  final Team? team;

  const _PausedView({
    required this.onResume,
    this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            team?.color ?? DopamineColors.primaryPurple,
            (team?.color ?? DopamineColors.primaryPurple).withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.pause_circle_filled,
                size: 120,
                color: Colors.white,
              ).animate()
                .scale(duration: const Duration(milliseconds: 500))
                .then()
                .shimmer(duration: const Duration(seconds: 2)),
              const SizedBox(height: 40),
              if (team != null) ...[
                Text(
                  team!.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                'JUEGO PAUSADO',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate()
                .fadeIn()
                .slideY(begin: 0.3),
              const SizedBox(height: 20),
              const Text(
                'Tómate un respiro y continúa cuando estés listo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text(
                      'Salir',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: team?.color ?? DopamineColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinishedView extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _FinishedView({required this.stats});

  @override
  Widget build(BuildContext context) {
    final score = stats['score'] ?? 0;
    final totalWords = stats['totalWords'] ?? 0;
    final timeSpent = stats['timeSpent'] ?? 0;
    final percentage = totalWords > 0 ? (score / totalWords * 100).round() : 0;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DopamineColors.primaryPurple,
            DopamineColors.primaryPurple.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.amber,
              ).animate()
                .scale(duration: const Duration(milliseconds: 600))
                .then()
                .shimmer(duration: const Duration(seconds: 2)),
              const SizedBox(height: 30),
              const Text(
                '¡RONDA TERMINADA!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate()
                .fadeIn()
                .slideY(begin: 0.3),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      icon: Icons.star,
                      label: 'Puntuación',
                      value: '$score / $totalWords',
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      icon: Icons.percent,
                      label: 'Porcentaje',
                      value: '$percentage%',
                      color: Colors.lightBlue,
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      icon: Icons.timer,
                      label: 'Tiempo usado',
                      value: '$timeSpent segundos',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildPerformanceMessage(percentage),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home),
                label: const Text(
                  'Volver al Menú',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: DopamineColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMessage(int percentage) {
    String message;
    IconData icon;
    Color color;

    if (percentage >= 80) {
      message = '¡Excelente trabajo!';
      icon = Icons.star;
      color = Colors.amber;
    } else if (percentage >= 60) {
      message = '¡Buen trabajo!';
      icon = Icons.thumb_up;
      color = Colors.green;
    } else if (percentage >= 40) {
      message = 'No está mal, ¡sigue practicando!';
      icon = Icons.trending_up;
      color = Colors.orange;
    } else {
      message = '¡La práctica hace al maestro!';
      icon = Icons.school;
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 