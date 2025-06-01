import 'difficulty.dart';

class RoundConfiguration {
  final int roundNumber;
  final Map<Difficulty, int> wordsPerDifficulty;

  const RoundConfiguration({
    required this.roundNumber,
    required this.wordsPerDifficulty,
  });

  int get totalWords => wordsPerDifficulty.values.fold(0, (sum, count) => sum + count);

  @override
  String toString() {
    return 'RoundConfiguration(round: $roundNumber, words: $wordsPerDifficulty)';
  }
}

class RoundConfigurationProvider {
  static final List<RoundConfiguration> _configurations = [
    // Ronda 1: 2 fáciles, 2 medias, 1 difícil
    RoundConfiguration(
      roundNumber: 1,
      wordsPerDifficulty: {
        Difficulty.facil: 3,
        Difficulty.media: 2,
     
      },
    ),
    // Ronda 2: 1 fácil, 3 medias, 1 difícil
    RoundConfiguration(
      roundNumber: 2,
      wordsPerDifficulty: {
        Difficulty.facil: 2,
        Difficulty.media: 3
  
      },
    ),
    // Ronda 3: 0 fáciles, 3 medias, 2 difíciles
    RoundConfiguration(
      roundNumber: 3,
      wordsPerDifficulty: {
        Difficulty.facil: 1,
        Difficulty.media: 3,
        Difficulty.dificil: 1,
      },
    ),
    // Ronda 4: 0 fáciles, 2 medias, 2 difíciles, 1 extrema
    RoundConfiguration(
      roundNumber: 4,
      wordsPerDifficulty: {
        Difficulty.media: 4,
        Difficulty.dificil: 1
      },
    ),
    // Ronda 5: 0 fáciles, 2 medias, 2 difíciles, 1 extrema
    RoundConfiguration(
      roundNumber: 5,
      wordsPerDifficulty: {
        Difficulty.facil: 0,
        Difficulty.media: 2,
        Difficulty.dificil: 2,
        Difficulty.extrema: 1,
      },
    ),
  ];

  static RoundConfiguration getConfigurationForRound(int roundNumber) {
    final config = _configurations.firstWhere(
      (config) => config.roundNumber == roundNumber,
      orElse: () => _configurations.last, // Si no existe, usar la última configuración
    );
    return config;
  }

  static List<RoundConfiguration> getAllConfigurations() {
    return List.unmodifiable(_configurations);
  }

  static int get maxRounds => _configurations.length;
} 