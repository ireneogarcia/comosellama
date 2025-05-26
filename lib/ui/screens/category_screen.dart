import 'package:flutter/material.dart';
import 'game_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige una Categoría'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
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
    );
  }

  void _onCategorySelected(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(category: category),
      ),
    );
  }
} 