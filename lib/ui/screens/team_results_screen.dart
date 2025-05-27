import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
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

    final hasWinner = _hasWinner(sortedTeams);
    final isTie = _isTie(sortedTeams);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: hasWinner
                ? [
                    sortedTeams.first.color,
                    sortedTeams.first.color.withOpacity(0.7),
                  ]
                : [
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
                _buildHeader(hasWinner, isTie, sortedTeams),
                const SizedBox(height: 32),
                if (hasWinner) ...[
                  _buildWinnerSection(sortedTeams.first),
                  const SizedBox(height: 32),
                ] else if (isTie) ...[
                  _buildTieSection(sortedTeams),
                  const SizedBox(height: 32),
                ],
                _buildChart(sortedTeams),
                const SizedBox(height: 24),
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

  bool _hasWinner(List<Team> sortedTeams) {
    if (sortedTeams.length < 2) return true;
    return sortedTeams[0].score > sortedTeams[1].score;
  }

  bool _isTie(List<Team> sortedTeams) {
    if (sortedTeams.length < 2) return false;
    return sortedTeams[0].score == sortedTeams[1].score;
  }

  Widget _buildHeader(bool hasWinner, bool isTie, List<Team> sortedTeams) {
    String title;
    IconData icon;
    
    if (hasWinner) {
      title = '¡${sortedTeams.first.name} Gana!';
      icon = Icons.emoji_events;
    } else if (isTie) {
      title = '¡Empate!';
      icon = Icons.handshake;
    } else {
      title = '¡Juego Terminado!';
      icon = Icons.flag;
    }

    return Column(
      children: [
        Icon(
          icon,
          size: 80,
          color: Colors.white,
        ).animate()
          .scale(duration: const Duration(milliseconds: 600))
          .then()
          .shimmer(duration: const Duration(seconds: 2)),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ).animate()
          .fadeIn()
          .scale(),
      ],
    );
  }

  Widget _buildWinnerSection(Team winner) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: winner.color,
              child: Text(
                winner.name[0],
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ).animate()
            .scale(duration: const Duration(milliseconds: 800))
            .then()
            .shake(duration: const Duration(milliseconds: 500)),
          const SizedBox(height: 16),
          Text(
            winner.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${winner.score} puntos',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .slideY(begin: 0.5, duration: const Duration(milliseconds: 800));
  }

  Widget _buildTieSection(List<Team> sortedTeams) {
    final tiedTeams = sortedTeams.where((team) => team.score == sortedTeams.first.score).toList();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'Equipos Empatados',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: tiedTeams.map((team) => _buildTiedTeamCard(team)).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${tiedTeams.first.score} puntos cada uno',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .slideY(begin: 0.5, duration: const Duration(milliseconds: 800));
  }

  Widget _buildTiedTeamCard(Team team) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: team.color,
            child: Text(
              team.name[0],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          team.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<Team> sortedTeams) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Puntuaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (sortedTeams.isNotEmpty ? sortedTeams.first.score : 0).toDouble() * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedTeams.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              sortedTeams[index].name.length > 8
                                  ? '${sortedTeams[index].name.substring(0, 8)}...'
                                  : sortedTeams[index].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: sortedTeams.asMap().entries.map((entry) {
                  final index = entry.key;
                  final team = entry.value;
                  final isWinner = index == 0 && _hasWinner(sortedTeams);
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: team.score.toDouble(),
                        color: isWinner ? Colors.amber : team.color,
                        width: 30,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ).animate()
              .slideY(begin: 1, duration: const Duration(milliseconds: 1000)),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreList(List<Team> sortedTeams) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: sortedTeams.length,
        itemBuilder: (context, index) {
          final team = sortedTeams[index];
          final isWinner = index == 0 && _hasWinner(sortedTeams);
          final isTied = _isTie(sortedTeams) && team.score == sortedTeams.first.score;
          
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isWinner 
                  ? Colors.amber.withOpacity(0.3)
                  : isTied 
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isWinner 
                    ? Colors.amber
                    : isTied 
                        ? Colors.orange
                        : Colors.white.withOpacity(0.3),
                width: isWinner || isTied ? 2 : 1,
              ),
            ),
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isWinner) ...[
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                  ] else if (isTied) ...[
                    const Icon(Icons.handshake, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                  ],
                  CircleAvatar(
                    backgroundColor: team.color,
                    radius: 20,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                team.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isWinner || isTied ? FontWeight.bold : FontWeight.w500,
                  fontSize: isWinner ? 18 : 16,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isWinner 
                      ? Colors.amber
                      : isTied 
                          ? Colors.orange
                          : team.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${team.score} pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ).animate(delay: Duration(milliseconds: index * 100))
            .slideX(begin: 1, duration: const Duration(milliseconds: 500));
        },
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.home, color: Colors.white),
          label: const Text(
            'Menú Principal',
            style: TextStyle(color: Colors.white),
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
          onPressed: onPlayAgain,
          icon: const Icon(Icons.refresh),
          label: const Text(
            'Jugar de Nuevo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
} 