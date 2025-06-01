import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dopamine_theme.dart';
import 'game_screen.dart';
import 'word_list_game_screen.dart';
import '../../core/models/team.dart';
import '../../core/models/game_mode.dart';

class TeamTransitionScreen extends StatelessWidget {
  final Team team;
  final int currentRound;
  final int totalRounds;
  final int timeLimit;
  final String category;
  final List<Team> allTeams;
  final GameMode gameMode;

  TeamTransitionScreen({
    super.key,
    required this.team,
    required this.currentRound,
    required this.totalRounds,
    required this.timeLimit,
    required this.category,
    required this.allTeams,
    this.gameMode = GameMode.oneByOne,
  }) {
    print('=== CREANDO TEAM TRANSITION SCREEN ===');
    print('Equipo: ${team.name}');
    print('Ronda: $currentRound de $totalRounds');
    print('Modo de juego: $gameMode');
    print('Categoría: $category');
    print('Tiempo límite: $timeLimit');
    print('Total equipos: ${allTeams.length}');
  }

  @override
  Widget build(BuildContext context) {
    print('=== CONSTRUYENDO TEAM TRANSITION SCREEN ===');
    print('Equipo: ${team.name}');
    print('Ronda: $currentRound de $totalRounds');
    print('Modo de juego: $gameMode');
    print('Categoría: $category');
    print('Tiempo límite: $timeLimit');
    print('Total equipos: ${allTeams.length}');
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DopamineColors.backgroundDark,
              team.color.withOpacity(0.8),
              team.color,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTransitionIcon(),
                const SizedBox(height: 40),
                _buildTeamInfo(),
                const SizedBox(height: 40),
                _buildRoundInfo(),
                const SizedBox(height: 30),
                _buildGameModeInfo(),
                const SizedBox(height: 50),
                _buildStartButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransitionIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: DopamineGradients.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: DopamineColors.primaryPurple.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: const Icon(
        Icons.rocket_launch,
        size: 60,
        color: Colors.white,
      ),
    ).animate()
      .scale(duration: const Duration(milliseconds: 800))
      .then()
      .shake(duration: const Duration(milliseconds: 500));
  }

  Widget _buildTeamInfo() {
    return Column(
      children: [
        Text(
          '¡Es el turno de!',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ).animate()
          .fadeIn(delay: const Duration(milliseconds: 300))
          .slideY(begin: 0.3),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: team.color,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: team.color.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    team.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                team.name,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: team.color,
                ),
              ),
            ],
          ),
        ).animate(delay: const Duration(milliseconds: 500))
          .fadeIn()
          .scale(begin: const Offset(0.8, 0.8)),
      ],
    );
  }

  Widget _buildRoundInfo() {
    return DopamineWidgets.dopamineCard(
      gradient: DopamineGradients.electricGradient,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.timer,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                'Ronda $currentRound de $totalRounds',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$timeLimit segundos de diversión',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: const Duration(milliseconds: 700))
      .fadeIn()
      .slideX(begin: -0.3);
  }

  Widget _buildGameModeInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            gameMode.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Text(
            gameMode.name,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate(delay: const Duration(milliseconds: 900))
      .fadeIn()
      .slideY(begin: 0.3);
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      width: 250,
      height: 70,
      decoration: BoxDecoration(
        gradient: DopamineGradients.successGradient,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: DopamineColors.successGreen.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _startTeamRound(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              '¡COMENZAR!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: const Duration(milliseconds: 1100))
      .fadeIn()
      .scale(begin: const Offset(0.8, 0.8))
      .then()
      .shimmer(duration: const Duration(milliseconds: 1500));
  }

  void _startTeamRound(BuildContext context) {
    print('=== INICIANDO RONDA DESDE TEAM TRANSITION ===');
    print('Equipo: ${team.name}');
    print('Ronda: $currentRound de $totalRounds');
    print('Modo de juego: $gameMode');
    print('Categoría: $category');
    print('Tiempo límite: $timeLimit');
    
    if (gameMode == GameMode.wordList) {
      print('Navegando a WordListGameScreen...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WordListGameScreen(
            category: category,
            team: team,
            currentRound: currentRound,
            totalRounds: totalRounds,
            timeLimit: timeLimit,
            allTeams: allTeams,
            gameMode: gameMode,
          ),
        ),
      );
    } else {
      print('Navegando a GameScreen...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            category: category,
            team: team,
            currentRound: currentRound,
            totalRounds: totalRounds,
            timeLimit: timeLimit,
            allTeams: allTeams,
            gameMode: gameMode,
          ),
        ),
      );
    }
  }
} 