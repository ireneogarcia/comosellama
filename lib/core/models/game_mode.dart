enum GameMode {
  oneByOne,  // Modalidad 1: Una palabra a la vez
  wordList,  // Modalidad 2: Lista de 5 palabras
}

extension GameModeExtension on GameMode {
  String get name {
    switch (this) {
      case GameMode.oneByOne:
        return 'Una por Una';
      case GameMode.wordList:
        return 'Lista de Palabras';
    }
  }

  String get description {
    switch (this) {
      case GameMode.oneByOne:
        return 'Aparece una palabra, marcas acierto o fallo y pasas a la siguiente';
      case GameMode.wordList:
        return 'Ves las 5 palabras y puedes marcar cada una por separado';
    }
  }

  String get icon {
    switch (this) {
      case GameMode.oneByOne:
        return '📝';
      case GameMode.wordList:
        return '📋';
    }
  }
} 