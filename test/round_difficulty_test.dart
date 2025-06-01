import 'package:flutter_test/flutter_test.dart';
import 'package:deslizas/core/services/word_persistence_service.dart';
import 'package:deslizas/core/services/enhanced_round_service.dart';
import 'package:deslizas/core/use_cases/round_management_use_case.dart';
import 'package:deslizas/core/models/difficulty.dart';

void main() {
  group('Round Difficulty Tests', () {
    late WordPersistenceService persistenceService;
    late EnhancedRoundService roundService;
    late RoundManagementUseCase roundManagementUseCase;

    setUpAll(() async {
      // Inicializar bindings de Flutter para tests
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      persistenceService = WordPersistenceService();
      roundService = EnhancedRoundService(persistenceService);
      roundManagementUseCase = RoundManagementUseCase(roundService);
    });

    test('Ronda 1 debe tener 2 fáciles, 2 medias, 1 difícil', () async {
      // Arrange
      const expectedConfig = {
        Difficulty.facil: 2,
        Difficulty.media: 2,
        Difficulty.dificil: 1,
      };

      // Act
      final roundWords = await roundManagementUseCase.startNewRound(1);

      // Assert
      expect(roundWords.length, equals(5), reason: 'La ronda 1 debe tener exactamente 5 palabras');

      // Contar palabras por dificultad
      final actualConfig = <Difficulty, int>{
        Difficulty.facil: 0,
        Difficulty.media: 0,
        Difficulty.dificil: 0,
        Difficulty.extrema: 0,
      };

      for (final word in roundWords) {
        actualConfig[word.dificultad] = (actualConfig[word.dificultad] ?? 0) + 1;
      }

      // Verificar cada dificultad
      expectedConfig.forEach((difficulty, expectedCount) {
        final actualCount = actualConfig[difficulty] ?? 0;
        expect(
          actualCount, 
          equals(expectedCount),
          reason: 'Se esperaban $expectedCount palabras ${difficulty.value}, pero se obtuvieron $actualCount'
        );
      });

      // Imprimir detalles para depuración
      print('=== RESULTADO DEL TEST ===');
      print('Palabras generadas:');
      for (int i = 0; i < roundWords.length; i++) {
        final word = roundWords[i];
        print('  ${i + 1}. ${word.palabra} - ${word.dificultad.value}');
      }
      print('Distribución actual: $actualConfig');
      print('Distribución esperada: $expectedConfig');
    });

    test('Verificar que las palabras tienen dificultades válidas', () async {
      // Act
      final roundWords = await roundManagementUseCase.startNewRound(1);

      // Assert
      for (final word in roundWords) {
        expect(
          [Difficulty.facil, Difficulty.media, Difficulty.dificil, Difficulty.extrema],
          contains(word.dificultad),
          reason: 'La palabra "${word.palabra}" tiene una dificultad inválida: ${word.dificultad}'
        );
      }
    });

    test('Verificar configuración de todas las rondas', () async {
      final expectedConfigs = [
        // Ronda 1: 2 fáciles, 2 medias, 1 difícil
        {Difficulty.facil: 2, Difficulty.media: 2, Difficulty.dificil: 1},
        // Ronda 2: 1 fácil, 3 medias, 1 difícil
        {Difficulty.facil: 1, Difficulty.media: 3, Difficulty.dificil: 1},
        // Ronda 3: 0 fáciles, 3 medias, 2 difíciles
        {Difficulty.facil: 0, Difficulty.media: 3, Difficulty.dificil: 2},
        // Ronda 4: 0 fáciles, 2 medias, 2 difíciles, 1 extrema
        {Difficulty.facil: 0, Difficulty.media: 2, Difficulty.dificil: 2, Difficulty.extrema: 1},
        // Ronda 5: 0 fáciles, 2 medias, 2 difíciles, 1 extrema
        {Difficulty.facil: 0, Difficulty.media: 2, Difficulty.dificil: 2, Difficulty.extrema: 1},
      ];

      for (int roundNumber = 1; roundNumber <= 5; roundNumber++) {
        final expectedConfig = expectedConfigs[roundNumber - 1];
        
        // Resetear el progreso antes de cada ronda
        await roundManagementUseCase.resetGameProgress();
        
        final roundWords = await roundManagementUseCase.startNewRound(roundNumber);
        
        final actualConfig = <Difficulty, int>{
          Difficulty.facil: 0,
          Difficulty.media: 0,
          Difficulty.dificil: 0,
          Difficulty.extrema: 0,
        };

        for (final word in roundWords) {
          actualConfig[word.dificultad] = (actualConfig[word.dificultad] ?? 0) + 1;
        }

        expectedConfig.forEach((difficulty, expectedCount) {
          final actualCount = actualConfig[difficulty] ?? 0;
          expect(
            actualCount, 
            equals(expectedCount),
            reason: 'Ronda $roundNumber: Se esperaban $expectedCount palabras ${difficulty.value}, pero se obtuvieron $actualCount'
          );
        });

        print('Ronda $roundNumber: ✅ Configuración correcta');
      }
    });
  });
} 