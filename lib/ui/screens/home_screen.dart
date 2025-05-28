import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dopamine_theme.dart';
import 'game_mode_selection_screen.dart';
import 'team_setup_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DopamineGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildTitle(),
              const SizedBox(height: 60),
              _buildMainButtons(context),
              const Spacer(),
              _buildBottomButtons(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          decoration: BoxDecoration(
            gradient: DopamineGradients.primaryGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: DopamineColors.primaryPurple.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'DESLIZAS',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 6,
                ),
              ).animate()
                .fadeIn(duration: const Duration(milliseconds: 800))
                .scale(begin: const Offset(0.5, 0.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '🎮 El Juego de las Palabras 🎮',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate(delay: const Duration(milliseconds: 400))
                .fadeIn()
                .slideY(begin: 0.3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainButtons(BuildContext context) {
    return Column(
      children: [
        _DopamineHomeButton(
          icon: Icons.flash_on,
          text: 'Juego Rápido',
          gradient: DopamineGradients.electricGradient,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GameModeSelectionScreen()),
          ),
        ).animate(delay: const Duration(milliseconds: 600))
          .fadeIn()
          .slideX(begin: -0.3),
        const SizedBox(height: 25),
        _DopamineHomeButton(
          icon: Icons.groups,
          text: 'Modo Equipos',
          gradient: DopamineGradients.successGradient,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeamSetupScreen()),
          ),
        ).animate(delay: const Duration(milliseconds: 800))
          .fadeIn()
          .slideX(begin: 0.3),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _DopamineCircleButton(
            icon: Icons.bar_chart,
            text: 'Estadísticas',
            gradient: DopamineGradients.warningGradient,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ).animate(delay: const Duration(milliseconds: 1000))
            .fadeIn()
            .scale(begin: const Offset(0.5, 0.5)),
          _DopamineCircleButton(
            icon: Icons.settings,
            text: 'Ajustes',
            gradient: DopamineGradients.errorGradient,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ).animate(delay: const Duration(milliseconds: 1200))
            .fadeIn()
            .scale(begin: const Offset(0.5, 0.5)),
        ],
      ),
    );
  }
}

class _DopamineHomeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final LinearGradient gradient;
  final VoidCallback onPressed;

  const _DopamineHomeButton({
    required this.icon,
    required this.text,
    required this.gradient,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 70,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
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
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DopamineCircleButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final LinearGradient gradient;
  final VoidCallback onPressed;

  const _DopamineCircleButton({
    required this.icon,
    required this.text,
    required this.gradient,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
} 