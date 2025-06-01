enum WordStatus {
  noJugada,
  adivinada,
  noAdivinada;

  String toJson() => name;
  
  static WordStatus fromJson(String json) {
    switch (json) {
      case 'adivinada':
        return WordStatus.adivinada;
      case 'noAdivinada':
        return WordStatus.noAdivinada;
      default:
        return WordStatus.noJugada;
    }
  }
} 