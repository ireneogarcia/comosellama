enum Difficulty {
  facil('fácil'),
  media('media'),
  dificil('difícil'),
  extrema('extrema');

  const Difficulty(this.value);
  final String value;

  static Difficulty fromString(String value) {
    final cleanValue = value.toLowerCase().trim();
    print('Difficulty.fromString: "$value" -> "$cleanValue"');
    
    switch (cleanValue) {
      case 'fácil':
        print('  -> Difficulty.facil');
        return Difficulty.facil;
      case 'media':
        print('  -> Difficulty.media');
        return Difficulty.media;
      case 'difícil':
        print('  -> Difficulty.dificil');
        return Difficulty.dificil;
      case 'extrema':
        print('  -> Difficulty.extrema');
        return Difficulty.extrema;
      default:
        print('  -> DEFAULT: Difficulty.media (valor no reconocido: "$cleanValue")');
        return Difficulty.media;
    }
  }
} 