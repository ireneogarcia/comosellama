import 'difficulty.dart';
import 'word_status.dart';

class EnhancedWord {
  final String palabra;
  final Difficulty dificultad;
  final String categoria;
  final String fuenteLista;
  final WordStatus status;
  final DateTime? fechaJugada;

  const EnhancedWord({
    required this.palabra,
    required this.dificultad,
    required this.categoria,
    required this.fuenteLista,
    this.status = WordStatus.noJugada,
    this.fechaJugada,
  });

  EnhancedWord copyWith({
    String? palabra,
    Difficulty? dificultad,
    String? categoria,
    String? fuenteLista,
    WordStatus? status,
    DateTime? fechaJugada,
  }) {
    return EnhancedWord(
      palabra: palabra ?? this.palabra,
      dificultad: dificultad ?? this.dificultad,
      categoria: categoria ?? this.categoria,
      fuenteLista: fuenteLista ?? this.fuenteLista,
      status: status ?? this.status,
      fechaJugada: fechaJugada ?? this.fechaJugada,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'palabra': palabra,
      'dificultad': dificultad.value,
      'categoria': categoria,
      'fuenteLista': fuenteLista,
      'status': status.toJson(),
      'fechaJugada': fechaJugada?.toIso8601String(),
    };
  }

  factory EnhancedWord.fromJson(Map<String, dynamic> json) {
    return EnhancedWord(
      palabra: json['palabra'],
      dificultad: Difficulty.fromString(json['dificultad']),
      categoria: json['categoria'],
      fuenteLista: json['fuenteLista'],
      status: WordStatus.fromJson(json['status'] ?? 'noJugada'),
      fechaJugada: json['fechaJugada'] != null 
          ? DateTime.parse(json['fechaJugada']) 
          : null,
    );
  }

  factory EnhancedWord.fromCsv(List<String> csvRow) {
    return EnhancedWord(
      palabra: csvRow[0].trim(),
      dificultad: Difficulty.fromString(csvRow[1].trim()),
      categoria: csvRow[2].trim(),
      fuenteLista: csvRow[3].trim(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedWord && other.palabra == palabra;
  }

  @override
  int get hashCode => palabra.hashCode;

  @override
  String toString() {
    return 'EnhancedWord(palabra: $palabra, dificultad: ${dificultad.value}, categoria: $categoria, status: ${status.name})';
  }
} 