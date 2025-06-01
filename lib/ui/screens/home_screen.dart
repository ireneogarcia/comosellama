import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../core/theme/dopamine_theme.dart';
import 'game_mode_selection_screen.dart';
import 'team_setup_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo estático
          _buildAnimatedBackground(),
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildAnimatedTitle(),
                const SizedBox(height: 60),
                _buildMainButtons(context),
                const Spacer(),
                _buildBottomButtons(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DopamineColors.backgroundDark,
            DopamineColors.primaryPurple,
            DopamineColors.secondaryPink,
            DopamineColors.backgroundDark,
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            DopamineColors.primaryPurple,
            DopamineColors.secondaryPink,
            DopamineColors.electricBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: DopamineColors.primaryPurple.withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: DopamineColors.secondaryPink.withOpacity(0.4),
            blurRadius: 35,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'DESLIZAS',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'El Juego de las Palabras',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
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
          animationController: _pulseController,
        ).animate(delay: const Duration(milliseconds: 600))
          .fadeIn(duration: const Duration(milliseconds: 800))
          .slideX(begin: -0.5, end: 0)
          .then()
          .shimmer(duration: const Duration(seconds: 3), delay: const Duration(seconds: 1)),
        const SizedBox(height: 30),
        _DopamineHomeButton(
          icon: Icons.groups,
          text: 'Modo Equipos',
          gradient: DopamineGradients.successGradient,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeamSetupScreen()),
          ),
          animationController: _pulseController,
        ).animate(delay: const Duration(milliseconds: 800))
          .fadeIn(duration: const Duration(milliseconds: 800))
          .slideX(begin: 0.5, end: 0)
          .then()
          .shimmer(duration: const Duration(seconds: 3), delay: const Duration(seconds: 2)),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: DopamineColors.primaryPurple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
            animationController: _pulseController,
          ).animate(delay: const Duration(milliseconds: 1000))
            .fadeIn(duration: const Duration(milliseconds: 600))
            .scale(begin: const Offset(0.3, 0.3), end: const Offset(1.0, 1.0))
            .then()
            .shake(duration: const Duration(milliseconds: 500), delay: const Duration(seconds: 2)),
          _DopamineCircleButton(
            icon: Icons.settings,
            text: 'Ajustes',
            gradient: DopamineGradients.errorGradient,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            animationController: _pulseController,
          ).animate(delay: const Duration(milliseconds: 1200))
            .fadeIn(duration: const Duration(milliseconds: 600))
            .scale(begin: const Offset(0.3, 0.3), end: const Offset(1.0, 1.0))
            .then()
            .shake(duration: const Duration(milliseconds: 500), delay: const Duration(seconds: 3)),
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
  final AnimationController animationController;

  const _DopamineHomeButton({
    required this.icon,
    required this.text,
    required this.gradient,
    required this.onPressed,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + animationController.value * 0.05,
          child: Container(
            width: 300,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient.colors.map((color) => 
                  Color.lerp(color, Colors.white, animationController.value * 0.1)!
                ).toList(),
                begin: gradient.begin,
                end: gradient.end,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.5 + animationController.value * 0.2),
                  blurRadius: 25 + animationController.value * 10,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: gradient.colors.last.withOpacity(0.3),
                  blurRadius: 35,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon, 
                      size: 36, 
                      color: Colors.white,
                    ).animate(
                      onPlay: (controller) => controller.repeat(),
                    ).rotate(
                      duration: const Duration(seconds: 4),
                      begin: 0,
                      end: icon == Icons.flash_on ? 0.1 : 0,
                    ).then().rotate(
                      begin: icon == Icons.flash_on ? 0.1 : 0,
                      end: icon == Icons.flash_on ? -0.1 : 0,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DopamineCircleButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final LinearGradient gradient;
  final VoidCallback onPressed;
  final AnimationController animationController;

  const _DopamineCircleButton({
    required this.icon,
    required this.text,
    required this.gradient,
    required this.onPressed,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 1.0 + math.sin(animationController.value * 2 * math.pi) * 0.1,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.6),
                      blurRadius: 20 + animationController.value * 5,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: gradient.colors.last.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
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
                  child: Icon(
                    icon, 
                    size: 36, 
                    color: Colors.white,
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  ).rotate(
                    duration: Duration(seconds: icon == Icons.settings ? 6 : 8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ).animate(
              onPlay: (controller) => controller.repeat(),
            ).shimmer(
              duration: const Duration(seconds: 4),
              delay: Duration(seconds: icon == Icons.bar_chart ? 1 : 2),
            ),
          ],
        );
      },
    );
  }
} 