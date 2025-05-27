import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'team_transition_screen.dart';
import '../../core/models/team.dart';

class QuickGameCategoryScreen extends StatelessWidget {
  const QuickGameCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego Rápido - Elige Categoría'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Configuración del Juego Rápido:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• 2 equipos (Equipo A y Equipo B)\n• 1 ronda por equipo\n• 60 segundos por ronda',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: const Duration(milliseconds: 500))
                .slideY(begin: -0.2),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _CategoryCard(
                      icon: '🐾',
                      name: 'Animales',
                      category: 'animales',
                      color: Colors.brown,
                    ),
                    _CategoryCard(
                      icon: '🏠',
                      name: 'Objetos',
                      category: 'objetos',
                      color: Colors.blue,
                    ),
                    _CategoryCard(
                      icon: '🍎',
                      name: 'Comida',
                      category: 'comida',
                      color: Colors.red,
                    ),
                    _CategoryCard(
                      icon: '👨‍⚕️',
                      name: 'Profesiones',
                      category: 'profesiones',
                      color: Colors.purple,
                    ),
                    _CategoryCard(
                      icon: '⚽',
                      name: 'Deportes',
                      category: 'deportes',
                      color: Colors.orange,
                    ),
                    _CategoryCard(
                      icon: '🎨',
                      name: 'Colores',
                      category: 'colores',
                      color: Colors.green,
                    ),
                    _CategoryCard(
                      icon: '😊',
                      name: 'Emociones',
                      category: 'emociones',
                      color: Colors.pink,
                    ),
                    _CategoryCard(
                      icon: '🎲',
                      name: 'Mixta',
                      category: 'mixed',
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String icon;
  final String name;
  final String category;
  final Color color;

  const _CategoryCard({
    required this.icon,
    required this.name,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _onCategorySelected(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 600))
      .scale(begin: const Offset(0.8, 0.8));
  }

  void _onCategorySelected(BuildContext context) {
    // Crear los dos equipos predeterminados para el juego rápido
    final teams = [
      Team(
        name: 'Equipo A',
        color: Colors.blue,
        score: 0,
      ),
      Team(
        name: 'Equipo B',
        color: Colors.red,
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
          category: category,
          allTeams: teams,
        ),
      ),
    );
  }
} 