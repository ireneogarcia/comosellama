import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatsCard(
              title: 'Partidas Jugadas',
              value: '0',
              icon: Icons.games,
            ),
            const SizedBox(height: 16),
            _buildStatsCard(
              title: 'Mejor Puntuación',
              value: '0/5',
              icon: Icons.star,
            ),
            const SizedBox(height: 16),
            _buildStatsCard(
              title: 'Promedio de Aciertos',
              value: '0%',
              icon: Icons.analytics,
            ),
            const SizedBox(height: 16),
            _buildStatsCard(
              title: 'Tiempo Promedio',
              value: '0s',
              icon: Icons.timer,
            ),
            const SizedBox(height: 32),
            const Text(
              'Categorías Favoritas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStats() {
    return Expanded(
      child: ListView(
        children: [
          _buildCategoryBar(
            category: 'Animales',
            percentage: 0,
            color: Colors.brown,
          ),
          _buildCategoryBar(
            category: 'Objetos',
            percentage: 0,
            color: Colors.blue,
          ),
          _buildCategoryBar(
            category: 'Comida',
            percentage: 0,
            color: Colors.red,
          ),
          _buildCategoryBar(
            category: 'Profesiones',
            percentage: 0,
            color: Colors.purple,
          ),
          _buildCategoryBar(
            category: 'Deportes',
            percentage: 0,
            color: Colors.orange,
          ),
          _buildCategoryBar(
            category: 'Colores',
            percentage: 0,
            color: Colors.green,
          ),
          _buildCategoryBar(
            category: 'Emociones',
            percentage: 0,
            color: Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar({
    required String category,
    required double percentage,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
} 