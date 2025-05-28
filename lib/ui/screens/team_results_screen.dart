import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dopamine_theme.dart';
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: hasWinner
                ? [
                    DopamineColors.backgroundDark,
                    sortedTeams.first.color.withOpacity(0.8),
                    sortedTeams.first.color,
                    DopamineColors.accent3,
                  ]
                : isTie
                    ? [
                        DopamineColors.backgroundDark,
                        DopamineColors.warningOrange.withOpacity(0.8),
                        DopamineColors.accent3,
                        DopamineColors.secondaryPink,
                      ]
                    : [
                        DopamineColors.backgroundDark,
                        DopamineColors.primaryPurple.withOpacity(0.8),
                        DopamineColors.electricBlue,
                      ],
            stops: hasWinner || isTie ? [0.0, 0.4, 0.7, 1.0] : [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(hasWinner, isTie, sortedTeams),
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
    LinearGradient gradient;
    
    if (hasWinner) {
      title = '¡${sortedTeams.first.name} Gana!';
      icon = Icons.emoji_events;
      gradient = const LinearGradient(
        colors: [DopamineColors.accent3, DopamineColors.warningOrange],
      );
    } else if (isTie) {
      title = '¡Empate Épico!';
      icon = Icons.handshake;
      gradient = DopamineGradients.warningGradient;
    } else {
      title = '¡Juego Terminado!';
      icon = Icons.flag;
      gradient = DopamineGradients.primaryGradient;
    }

    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.6),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: gradient.colors.last.withOpacity(0.4),
                blurRadius: 60,
                offset: const Offset(0, 30),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 70,
            color: Colors.white,
          ),
        ).animate()
          .scale(duration: const Duration(milliseconds: 1000), curve: Curves.elasticOut)
          .then()
          .shimmer(duration: const Duration(seconds: 3))
          .then()
          .shake(duration: const Duration(milliseconds: 800))
          .then(delay: const Duration(milliseconds: 500))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: const Duration(milliseconds: 1000),
          )
          .then()
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1.0, 1.0),
            duration: const Duration(milliseconds: 1000),
          ),
        
        const SizedBox(height: 25),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.5),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: gradient.colors.last.withOpacity(0.3),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.5,
            ),
            textAlign: TextAlign.center,
          ),
        ).animate()
          .fadeIn(delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 800))
          .scale(begin: const Offset(0.7, 0.7), duration: const Duration(milliseconds: 800))
          .slideY(begin: 0.4, duration: const Duration(milliseconds: 800))
          .then()
          .shimmer(duration: const Duration(milliseconds: 2500))
          .then(delay: const Duration(milliseconds: 1000))
          .shake(duration: const Duration(milliseconds: 600)),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            hasWinner 
                ? '🎉 ¡Victoria espectacular! 🎉'
                : isTie 
                    ? '🤝 ¡Qué emocionante empate! 🤝'
                    : '🎮 ¡Gracias por jugar! 🎮',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ).animate(delay: const Duration(milliseconds: 1000))
          .fadeIn(duration: const Duration(milliseconds: 800))
          .slideY(begin: 0.3, duration: const Duration(milliseconds: 800))
          .then()
          .shimmer(duration: const Duration(milliseconds: 2000))
          .then(delay: const Duration(milliseconds: 1500))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.05, 1.05),
            duration: const Duration(milliseconds: 800),
          )
          .then()
          .scale(
            begin: const Offset(1.05, 1.05),
            end: const Offset(1.0, 1.0),
            duration: const Duration(milliseconds: 800),
          ),
      ],
    );
  }

  Widget _buildScoreList(List<Team> sortedTeams) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: sortedTeams.length,
        itemBuilder: (context, index) {
          final team = sortedTeams[index];
          final isWinner = index == 0 && _hasWinner(sortedTeams);
          final isTied = _isTie(sortedTeams) && team.score == sortedTeams.first.score;
          
          LinearGradient cardGradient;
          if (isWinner) {
            cardGradient = LinearGradient(
              colors: [DopamineColors.accent3.withOpacity(0.9), DopamineColors.warningOrange.withOpacity(0.8)],
            );
          } else if (isTied) {
            cardGradient = LinearGradient(
              colors: [DopamineColors.warningOrange.withOpacity(0.8), DopamineColors.accent1.withOpacity(0.8)],
            );
          } else {
            cardGradient = LinearGradient(
              colors: [Colors.white.withOpacity(0.15), team.color.withOpacity(0.3)],
            );
          }
          
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isWinner 
                    ? DopamineColors.accent3
                    : isTied 
                        ? DopamineColors.warningOrange
                        : Colors.white.withOpacity(0.4),
                width: isWinner || isTied ? 4 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isWinner ? DopamineColors.accent3 : isTied ? DopamineColors.warningOrange : team.color).withOpacity(0.4),
                  blurRadius: isWinner || isTied ? 20 : 12,
                  offset: const Offset(0, 6),
                ),
                if (isWinner || isTied)
                  BoxShadow(
                    color: (isWinner ? DopamineColors.accent3 : DopamineColors.warningOrange).withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isWinner) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [DopamineColors.accent3, DopamineColors.warningOrange],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: DopamineColors.accent3.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                    ).animate(delay: Duration(milliseconds: 1000 + (index * 200)))
                      .scale(begin: const Offset(0.5, 0.5), duration: const Duration(milliseconds: 600))
                      .then()
                      .shimmer(duration: const Duration(milliseconds: 1500))
                      .then()
                      .shake(duration: const Duration(milliseconds: 400)),
                    const SizedBox(width: 16),
                  ] else if (isTied) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: DopamineGradients.warningGradient,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: DopamineColors.warningOrange.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.handshake, color: Colors.white, size: 24),
                    ).animate(delay: Duration(milliseconds: 1000 + (index * 200)))
                      .scale(begin: const Offset(0.5, 0.5), duration: const Duration(milliseconds: 600))
                      .then()
                      .shimmer(duration: const Duration(milliseconds: 1200)),
                    const SizedBox(width: 16),
                  ],
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [team.color, team.color.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: team.color.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ).animate(delay: Duration(milliseconds: 800 + (index * 150)))
                    .scale(begin: const Offset(0.3, 0.3), duration: const Duration(milliseconds: 500))
                    .then()
                    .shimmer(duration: const Duration(milliseconds: 1000)),
                ],
              ),
              title: Text(
                team.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isWinner || isTied ? FontWeight.bold : FontWeight.w600,
                  fontSize: isWinner ? 22 : 20,
                  letterSpacing: isWinner ? 1.2 : 0.8,
                ),
              ).animate(delay: Duration(milliseconds: 900 + (index * 150)))
                .fadeIn(duration: const Duration(milliseconds: 600))
                .slideX(begin: -0.3, duration: const Duration(milliseconds: 600)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isWinner 
                      ? const LinearGradient(colors: [DopamineColors.accent3, DopamineColors.warningOrange])
                      : isTied 
                          ? DopamineGradients.warningGradient
                          : LinearGradient(colors: [team.color, team.color.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: (isWinner ? DopamineColors.accent3 : isTied ? DopamineColors.warningOrange : team.color).withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isWinner || isTied)
                      const Icon(Icons.star, color: Colors.white, size: 18),
                    if (isWinner || isTied)
                      const SizedBox(width: 4),
                    Text(
                      '${team.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 1000 + (index * 150)))
                .scale(begin: const Offset(0.5, 0.5), duration: const Duration(milliseconds: 500))
                .then()
                .shimmer(duration: const Duration(milliseconds: 800)),
            ),
          ).animate(delay: Duration(milliseconds: 800 + (index * 150)))
            .slideX(begin: 1, duration: const Duration(milliseconds: 600))
            .fadeIn(duration: const Duration(milliseconds: 600))
            .then()
            .shimmer(duration: const Duration(milliseconds: 1000), delay: Duration(milliseconds: index * 200));
        },
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(
            gradient: DopamineGradients.successGradient,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: DopamineColors.successGreen.withOpacity(0.5),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: DopamineColors.successGreen.withOpacity(0.3),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onPlayAgain,
            icon: const Icon(Icons.refresh, size: 32),
            label: const Text(
              'JUGAR DE NUEVO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),
        ).animate(delay: const Duration(milliseconds: 1400))
          .fadeIn(duration: const Duration(milliseconds: 800))
          .slideY(begin: 0.5, duration: const Duration(milliseconds: 800))
          .then()
          .shimmer(duration: const Duration(milliseconds: 2000))
          .then()
          .shake(duration: const Duration(milliseconds: 600)),
        
        const SizedBox(height: 20),
        
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.home, color: Colors.white, size: 28),
            label: const Text(
              'MENÚ PRINCIPAL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ).animate(delay: const Duration(milliseconds: 1600))
          .fadeIn(duration: const Duration(milliseconds: 800))
          .slideY(begin: 0.3, duration: const Duration(milliseconds: 800))
          .then()
          .shimmer(duration: const Duration(milliseconds: 1500), delay: const Duration(milliseconds: 500)),
      ],
    );
  }
} 