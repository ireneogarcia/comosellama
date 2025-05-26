import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/team.dart';

class TeamResultsScreen extends StatelessWidget {
  final List<Team> teams;
  final VoidCallback onPlayAgain;

  const TeamResultsScreen({
    super.key,
    required this.teams,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final sortedTeams = List<Team>.from(teams)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      body: Container(
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
              children: [
                const Text(
                  '¡Juego Terminado!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate()
                  .fadeIn()
                  .scale(),
                const SizedBox(height: 48),
                _buildPodium(sortedTeams.take(3).toList()),
                const SizedBox(height: 32),
                _buildScoreList(sortedTeams),
                const Spacer(),
                _buildButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List<Team> topTeams) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (topTeams.length > 1) ...[
          _buildPodiumPosition(
            team: topTeams[1],
            position: 2,
            height: 120,
          ),
          const SizedBox(width: 16),
        ],
        _buildPodiumPosition(
          team: topTeams[0],
          position: 1,
          height: 160,
        ),
        if (topTeams.length > 2) ...[
          const SizedBox(width: 16),
          _buildPodiumPosition(
            team: topTeams[2],
            position: 3,
            height: 100,
          ),
        ],
      ],
    ).animate()
      .slideY(
        begin: 1,
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
      );
  }

  Widget _buildPodiumPosition({
    required Team team,
    required int position,
    required double height,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: team.color,
          child: Text(
            position.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          team.name,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '${team.score}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreList(List<Team> sortedTeams) {
    return Expanded(
      child: ListView.builder(
        itemCount: sortedTeams.length,
        itemBuilder: (context, index) {
          final team = sortedTeams[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: team.color,
              child: Text('${index + 1}'),
            ),
            title: Text(
              team.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              '${team.score} puntos',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: const Text('Menú Principal'),
        ),
        ElevatedButton(
          onPressed: onPlayAgain,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: const Text('Jugar de Nuevo'),
        ),
      ],
    );
  }
} 