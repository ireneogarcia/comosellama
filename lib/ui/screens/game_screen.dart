import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/presentation/round_ploc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'team_transition_screen.dart';
import 'team_results_screen.dart';
import '../../core/models/team.dart';

class GameScreen extends StatelessWidget {
  final String category;
  final Team? team;
  final int? currentRound;
  final int? totalRounds;
  final List<Team>? allTeams;
  
  const GameScreen({
    super.key,
    required this.category,
    this.team,
    this.currentRound,
    this.totalRounds,
    this.allTeams,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<RoundPloc>(
          builder: (context, roundPloc, child) {
            final state = roundPloc.state;
            
            switch (state.status) {
              case RoundStatus.initial:
                _startRound(roundPloc);
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
                  onSwipe: (right) => roundPloc.handleSwipe(right),
                  team: team,
                );
                
              case RoundStatus.paused:
                return _PausedView(
                  onResume: () => roundPloc.resumeRound(),
                  team: team,
                );
                
              case RoundStatus.finished:
                return _handleGameFinished(context, roundPloc);
                
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
    return Consumer<RoundPloc>(
      builder: (context, roundPloc, child) {
        if (roundPloc.state.status == RoundStatus.playing) {
          return FloatingActionButton(
            onPressed: () => roundPloc.pauseRound(),
            child: const Icon(Icons.pause),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _startRound(RoundPloc roundPloc) {
    Future.microtask(() {
      roundPloc.startNewRound(category: category);
    });
  }

  Widget _handleGameFinished(BuildContext context, RoundPloc roundPloc) {
    if (team != null && allTeams != null) {
      // Modo por equipos
      team!.score += roundPloc.state.round!.score;
      
      if (currentRound! < totalRounds!) {
        // Siguiente ronda
        final nextTeamIndex = allTeams!.indexOf(team!) + 1;
        final nextTeam = nextTeamIndex < allTeams!.length 
            ? allTeams![nextTeamIndex]
            : allTeams![0];
        final nextRound = nextTeamIndex >= allTeams!.length 
            ? currentRound! + 1 
            : currentRound!;

        if (nextRound <= totalRounds!) {
          return TeamTransitionScreen(
            team: nextTeam,
            currentRound: nextRound,
            totalRounds: totalRounds!,
            timeLimit: roundPloc.state.round!.timeLimit,
            category: category,
          );
        }
      }
      
      // Juego terminado
      return TeamResultsScreen(
        teams: allTeams!,
        onPlayAgain: () {
          // Reiniciar puntuaciones
          for (final team in allTeams!) {
            team.score = 0;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TeamTransitionScreen(
                team: allTeams![0],
                currentRound: 1,
                totalRounds: totalRounds!,
                timeLimit: roundPloc.state.round!.timeLimit,
                category: category,
              ),
            ),
          );
        },
      );
    }

    // Modo individual
    return _FinishedView(
      stats: roundPloc.getStats(),
    );
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
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        onSwipe(details.primaryVelocity! > 0);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (team != null) _buildTeamHeader(),
          _buildTimer(),
          const SizedBox(height: 40),
          _buildWord(),
          const SizedBox(height: 40),
          _buildProgress(),
          const SizedBox(height: 20),
          _buildSwipeInstructions(),
        ],
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: team!.color.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: team!.color,
            child: Text(
              team!.name[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            team!.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: team!.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Text(
            timeRemaining.toString(),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('segundos restantes'),
        ],
      ),
    );
  }

  Widget _buildWord() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Text(
        word.toUpperCase(),
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ).animate()
        .fadeIn()
        .scale(),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (currentWordIndex + 1) / totalWords,
            minHeight: 10,
          ),
          const SizedBox(height: 10),
          Text(
            'Palabra ${currentWordIndex + 1} de $totalWords',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeInstructions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSwipeInstruction(
            icon: Icons.arrow_back,
            text: 'Desliza izquierda\npara FALLO',
            color: Colors.red,
          ),
          _buildSwipeInstruction(
            icon: Icons.arrow_forward,
            text: 'Desliza derecha\npara ACIERTO',
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
      children: [
        Icon(icon, color: color, size: 32),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 12,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (team != null)
              Text(
                team!.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'JUEGO PAUSADO',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: team?.color ?? Theme.of(context).primaryColor,
              ),
              child: const Text('Continuar'),
            ),
          ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¡RONDA TERMINADA!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Text(
            'Puntuación: ${stats['score']} / ${stats['totalWords']}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          Text(
            'Tiempo usado: ${stats['timeSpent']} segundos',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver al Menú'),
          ),
        ],
      ),
    );
  }
} 