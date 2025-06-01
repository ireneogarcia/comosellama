import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/di/service_locator.dart';
import '../core/presentation/enhanced_round_bloc.dart';
import '../core/models/difficulty.dart';

class RoundManagementExample extends StatefulWidget {
  const RoundManagementExample({super.key});

  @override
  State<RoundManagementExample> createState() => _RoundManagementExampleState();
}

class _RoundManagementExampleState extends State<RoundManagementExample> {
  late final ServiceLocator _serviceLocator;

  @override
  void initState() {
    super.initState();
    _serviceLocator = ServiceLocator();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _serviceLocator.initialize();
    // Cargar progreso inicial
    _serviceLocator.roundBloc.loadGameProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Rondas - Ejemplo'),
        backgroundColor: Colors.blue,
      ),
      body: ChangeNotifierProvider.value(
        value: _serviceLocator.roundBloc,
        child: Consumer<EnhancedRoundBloc>(
          builder: (context, bloc, child) {
            if (bloc.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (bloc.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${bloc.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => bloc.loadGameProgress(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(bloc),
                  const SizedBox(height: 16),
                  _buildRoundControls(bloc),
                  const SizedBox(height: 16),
                  _buildCurrentRoundInfo(bloc),
                  const SizedBox(height: 16),
                  _buildWordDisplay(bloc),
                  const SizedBox(height: 16),
                  _buildActionButtons(bloc),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressCard(EnhancedRoundBloc bloc) {
    final progress = bloc.gameProgress;
    if (progress == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso del Juego',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total de palabras: ${progress.totalWords}'),
            Text('Palabras jugadas: ${progress.playedWords}'),
            Text('Palabras adivinadas: ${progress.guessedWords}'),
            Text('Porcentaje de éxito: ${progress.successPercentage.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            Text('${progress.progressPercentage.toStringAsFixed(1)}% completado'),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundControls(EnhancedRoundBloc bloc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control de Rondas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => bloc.startNewRound(1),
                  child: const Text('Ronda 1'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => bloc.startNewRound(2),
                  child: const Text('Ronda 2'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => bloc.startNewRound(3),
                  child: const Text('Ronda 3'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: bloc.isRoundComplete ? () => bloc.nextRound() : null,
                  child: const Text('Siguiente Ronda'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _testRound1Difficulties(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text('Test Ronda 1 Dificultades'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testRound1Difficulties() async {
    print('=== TEST RONDA 1 DIFICULTADES ===');
    
    try {
      // Generar palabras para ronda 1
      final roundWords = await _serviceLocator.roundManagementUseCase.startNewRound(1);
      
      print('Palabras generadas para Ronda 1:');
      final Map<String, int> difficultyCount = {'fácil': 0, 'media': 0, 'difícil': 0};
      
      for (int i = 0; i < roundWords.length; i++) {
        final word = roundWords[i];
        print('  ${i + 1}. ${word.palabra} - ${word.dificultad.value} (${word.categoria})');
        difficultyCount[word.dificultad.value] = (difficultyCount[word.dificultad.value] ?? 0) + 1;
      }
      
      print('Resumen de dificultades:');
      difficultyCount.forEach((difficulty, count) {
        print('  $difficulty: $count palabras');
      });
      
      // Verificar si cumple con la configuración esperada (2 fáciles, 2 medias, 1 difícil)
      final expectedConfig = {'fácil': 2, 'media': 2, 'difícil': 1};
      bool isCorrect = true;
      
      expectedConfig.forEach((difficulty, expectedCount) {
        final actualCount = difficultyCount[difficulty] ?? 0;
        if (actualCount != expectedCount) {
          print('ERROR: Se esperaban $expectedCount palabras $difficulty, pero se obtuvieron $actualCount');
          isCorrect = false;
        }
      });
      
      if (isCorrect) {
        print('✅ TEST PASADO: La ronda 1 tiene la configuración correcta');
      } else {
        print('❌ TEST FALLIDO: La ronda 1 NO tiene la configuración correcta');
      }
      
    } catch (e) {
      print('ERROR en test: $e');
    }
    
    print('=== FIN TEST RONDA 1 ===');
  }

  Widget _buildCurrentRoundInfo(EnhancedRoundBloc bloc) {
    if (bloc.currentRoundWords.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay ronda activa. Inicia una nueva ronda.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bloc.getRoundSummary(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Palabra ${bloc.currentWordIndex + 1} de ${bloc.currentRoundWords.length}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (bloc.currentWordIndex + 1) / bloc.currentRoundWords.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordDisplay(EnhancedRoundBloc bloc) {
    final currentWord = bloc.currentWord;
    if (currentWord == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay palabra actual'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Palabra Actual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getDifficultyColor(currentWord.dificultad),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    currentWord.palabra.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dificultad: ${currentWord.dificultad.value}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Categoría: ${currentWord.categoria}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(EnhancedRoundBloc bloc) {
    if (bloc.currentWord == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Acciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => bloc.completeCurrentWord(true),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Adivinada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => bloc.completeCurrentWord(false),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text('No Adivinada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: bloc.currentWordIndex > 0 ? () => bloc.previousWord() : null,
                    child: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: bloc.hasMoreWords ? () => bloc.nextWord() : null,
                    child: const Text('Siguiente'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showResetDialog(context, bloc),
              icon: const Icon(Icons.refresh),
              label: const Text('Resetear Progreso'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.facil:
        return Colors.green;
      case Difficulty.media:
        return Colors.orange;
      case Difficulty.dificil:
        return Colors.red;
      case Difficulty.extrema:
        return Colors.purple;
    }
  }

  void _showResetDialog(BuildContext context, EnhancedRoundBloc bloc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetear Progreso'),
        content: const Text(
          '¿Estás seguro de que quieres resetear todo el progreso del juego? '
          'Esto marcará todas las palabras como no jugadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              bloc.resetGame();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _serviceLocator.dispose();
    super.dispose();
  }
}