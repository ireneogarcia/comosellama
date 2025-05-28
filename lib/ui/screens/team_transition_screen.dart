import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'game_screen.dart';
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

  const TeamTransitionScreen({
    super.key,
    required this.team,
    required this.currentRound,
    required this.totalRounds,
    required this.timeLimit,
    required this.category,
    required this.allTeams,
    this.gameMode = GameMode.oneByOne,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                team.color,
                team.color.withOpacity(0.7),
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
                    Icons.swap_horiz,
                    size: 64,
                    color: Colors.white,
                  ).animate()
                    .scale(duration: const Duration(milliseconds: 500))
                    .then()
                    .shake(),
                  const SizedBox(height: 32),
                  Text(
                    'Turno de',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    team.name,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate()
                    .fadeIn()
                    .scale(),
                  const SizedBox(height: 32),
                  Text(
                    'Ronda $currentRound de $totalRounds',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          gameMode.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          gameMode.name,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () => _startTeamRound(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: team.color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Comenzar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startTeamRound(BuildContext context) {
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