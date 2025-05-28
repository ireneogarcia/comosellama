import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dopamine_theme.dart';
import 'team_transition_screen.dart';
import '../../core/models/team.dart';
import '../../core/models/game_mode.dart';

class QuickGameCategoryScreen extends StatelessWidget {
  final GameMode gameMode;
  
  const QuickGameCategoryScreen({
    super.key,
    this.gameMode = GameMode.oneByOne,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DopamineGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 25),
                _buildGameModeInfo(),
                const SizedBox(height: 30),
                Expanded(
                  child: _buildCategoriesGrid(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: DopamineGradients.primaryGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: DopamineColors.primaryPurple.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameMode.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Elige tu categoría favorita',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 600))
      .slideY(begin: -0.3);
  }

  Widget _buildGameModeInfo() {
    return DopamineWidgets.dopamineCard(
      gradient: DopamineGradients.electricGradient,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              gameMode.icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modalidad: ${gameMode.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '⚡ 2 equipos dinámicos\n🎯 1 ronda explosiva por equipo\n⏱️ 60 segundos de pura adrenalina',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 500))
      .slideY(begin: -0.2);
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      _CategoryData(icon: '🐾', name: 'Animales', category: 'animales', gradient: DopamineGradients.successGradient),
      _CategoryData(icon: '🏠', name: 'Objetos', category: 'objetos', gradient: DopamineGradients.electricGradient),
      _CategoryData(icon: '🍎', name: 'Comida', category: 'comida', gradient: DopamineGradients.errorGradient),
      _CategoryData(icon: '👨‍⚕️', name: 'Profesiones', category: 'profesiones', gradient: DopamineGradients.primaryGradient),
      _CategoryData(icon: '⚽', name: 'Deportes', category: 'deportes', gradient: DopamineGradients.warningGradient),
      _CategoryData(icon: '🎨', name: 'Colores', category: 'colores', gradient: const LinearGradient(colors: [DopamineColors.accent2, DopamineColors.successGreen])),
      _CategoryData(icon: '😊', name: 'Emociones', category: 'emociones', gradient: const LinearGradient(colors: [DopamineColors.secondaryPink, DopamineColors.accent1])),
      _CategoryData(icon: '🎲', name: 'Mixta', category: 'mixed', gradient: const LinearGradient(colors: [DopamineColors.accent4, DopamineColors.primaryPurple])),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _DopamineCategoryCard(
          categoryData: category,
          gameMode: gameMode,
          index: index,
        );
      },
    );
  }
}

class _CategoryData {
  final String icon;
  final String name;
  final String category;
  final LinearGradient gradient;

  _CategoryData({
    required this.icon,
    required this.name,
    required this.category,
    required this.gradient,
  });
}

class _DopamineCategoryCard extends StatelessWidget {
  final _CategoryData categoryData;
  final GameMode gameMode;
  final int index;

  const _DopamineCategoryCard({
    required this.categoryData,
    required this.gameMode,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: categoryData.gradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: categoryData.gradient.colors.first.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onCategorySelected(context),
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      categoryData.icon,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  categoryData.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_filled,
                        color: categoryData.gradient.colors.first,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'JUGAR',
                        style: TextStyle(
                          color: categoryData.gradient.colors.first,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 200 + (index * 100)))
      .fadeIn()
      .scale(begin: const Offset(0.8, 0.8))
      .slideY(begin: 0.3);
  }

  void _onCategorySelected(BuildContext context) {
    // Crear los dos equipos predeterminados para el juego rápido con colores dopamínicos
    final teams = [
      Team(
        name: 'Equipo A',
        color: DopamineColors.electricBlue,
        score: 0,
      ),
      Team(
        name: 'Equipo B',
        color: DopamineColors.secondaryPink,
        score: 0,
      ),
    ];

    // Navegar directamente a la transición del primer equipo
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TeamTransitionScreen(
          team: teams[0],
          currentRound: 1,
          totalRounds: 1,
          timeLimit: 60,
          category: categoryData.category,
          allTeams: teams,
          gameMode: gameMode,
        ),
      ),
    );
  }
} 