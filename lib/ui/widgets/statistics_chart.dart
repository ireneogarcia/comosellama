import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/team.dart';

class StatisticsChart extends StatelessWidget {
  final List<Team> teams;
  final bool showWinnerHighlight;

  const StatisticsChart({
    super.key,
    required this.teams,
    this.showWinnerHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    if (teams.isEmpty) return const SizedBox.shrink();

    final sortedTeams = List<Team>.from(teams)
      ..sort((a, b) => b.score.compareTo(a.score));

    final hasWinner = _hasWinner(sortedTeams);
    final isTie = _isTie(sortedTeams);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            isTie ? 'Empate - Puntuaciones' : 'Puntuaciones Finales',
            style: const TextStyle(
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
                maxY: _getMaxY(sortedTeams),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final team = sortedTeams[group.x.toInt()];
                      return BarTooltipItem(
                        '${team.name}\n${team.score} puntos',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedTeams.length) {
                          final team = sortedTeams[index];
                          final isWinner = index == 0 && hasWinner && showWinnerHighlight;
                          final isTiedTeam = isTie && team.score == sortedTeams.first.score;
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isWinner) ...[
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(height: 2),
                                ] else if (isTiedTeam) ...[
                                  const Icon(
                                    Icons.handshake,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                Text(
                                  team.name.length > 8
                                      ? '${team.name.substring(0, 8)}...'
                                      : team.name,
                                  style: TextStyle(
                                    color: isWinner || isTiedTeam 
                                        ? Colors.amber 
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: isWinner || isTiedTeam 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: _getMaxY(sortedTeams) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false,
                ),
                barGroups: sortedTeams.asMap().entries.map((entry) {
                  final index = entry.key;
                  final team = entry.value;
                  final isWinner = index == 0 && hasWinner && showWinnerHighlight;
                  final isTiedTeam = isTie && team.score == sortedTeams.first.score;
                  
                  Color barColor;
                  if (isWinner) {
                    barColor = Colors.amber;
                  } else if (isTiedTeam) {
                    barColor = Colors.orange;
                  } else {
                    barColor = team.color;
                  }
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: team.score.toDouble(),
                        color: barColor,
                        width: 30,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            barColor,
                            barColor.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ).animate()
              .slideY(begin: 1, duration: const Duration(milliseconds: 1000))
              .fadeIn(),
          ),
        ],
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

  double _getMaxY(List<Team> teams) {
    if (teams.isEmpty) return 10;
    final maxScore = teams.first.score;
    return (maxScore * 1.2).ceilToDouble();
  }
} 