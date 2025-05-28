import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../blocs/round_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  @override
  void initState() {
    super.initState();
    
    // Si es modalidad de lista de palabras, redirigir a la pantalla correspondiente
    if (widget.gameMode == GameMode.wordList) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
      });
      return;
    }
    
    // Resetear el estado del RoundBloc cuando se crea una nueva instancia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roundBloc = Provider.of<RoundBloc>(context, listen: false);
      roundBloc.resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si es modalidad de lista de palabras, mostrar loading mientras se redirige
    if (widget.gameMode == GameMode.wordList) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      body: SafeArea(
        child: Consumer<RoundBloc>(
          builder: (context, roundBloc, child) {
            final state = roundBloc.state;
            
            switch (state.status) {
              case RoundStatus.initial:
                _startRound(roundBloc);
                return const Center(child: CircularProgressIndicator());
                
              case RoundStatus.loading:
                return const Center(child: CircularProgressIndicator());
                
              case RoundStatus.playing:
                return _GameView(
                  word: state.round!.currentWord.text,
                  timeRemaining: state.round!.remainingTime,
                  score: state.round!.score,
                  totalWords: state.round!.words.length,
                  currentWordIndex: state.round!.currentWordIndex,
                  onSwipe: (right) => _handleSwipe(roundBloc, right),
                  team: widget.team,
                  primaryColor: Theme.of(context).primaryColor,
                );
                
              case RoundStatus.paused:
                return _PausedView(
                  onResume: () => roundBloc.resumeRound(),
                  team: widget.team,
                );
                
              case RoundStatus.finished:
                return _handleGameFinished(context, roundBloc);
                
              case RoundStatus.error:
                return Center(
                  child: Text('Error: ${state.errorMessage}'),
                );
            }
          },
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Consumer<RoundBloc>(
      builder: (context, roundBloc, child) {
        if (roundBloc.state.status == RoundStatus.playing) {
          return FloatingActionButton(
            onPressed: () {
              FeedbackService().buttonTapFeedback();
              roundBloc.pauseRound();
            },
            child: const Icon(Icons.pause),
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
    Future.microtask(() {
      roundBloc.startNewRound(
        category: widget.category,
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.team?.color ?? Theme.of(context).primaryColor,
            (widget.team?.color ?? Theme.of(context).primaryColor).withOpacity(0.7),
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  void _navigateAfterRound(BuildContext context, RoundBloc roundBloc) {
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
      
      // Si volvemos al primer equipo, incrementamos la ronda
      final nextRound = nextTeamIndex == 0 ? widget.currentRound! + 1 : widget.currentRound!;

      if (nextRound <= widget.totalRounds!) {
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
  final Color primaryColor;

  const _GameView({
    required this.word,
    required this.timeRemaining,
    required this.score,
    required this.totalWords,
    required this.currentWordIndex,
    required this.onSwipe,
    this.team,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            team?.color.withOpacity(0.1) ?? primaryColor.withOpacity(0.1),
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
              team?.color ?? primaryColor,
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
            team?.color ?? Theme.of(context).primaryColor,
            (team?.color ?? Theme.of(context).primaryColor).withOpacity(0.7),
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
                      foregroundColor: team?.color ?? Theme.of(context).primaryColor,
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
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
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
                  foregroundColor: Theme.of(context).primaryColor,
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