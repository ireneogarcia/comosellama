import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import '../models/word.dart';

class WordRepository {
  Map<String, List<String>>? _words;
  Map<String, String>? _wordDifficulties;
  final Random _random = Random();

  Future<void> initialize() async {
    await _loadWordsFromCsv();
  }

  Future<void> _loadWordsFromCsv() async {
    try {
      final String csvString = await rootBundle.loadString('assets/words/words_file.csv');
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
      
      // Inicializar los mapas
      _words = <String, List<String>>{};
      _wordDifficulties = <String, String>{};
      
      // Saltar la primera fila (headers) y procesar el resto
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.length >= 4) {
          final palabra = row[0].toString().trim();
          final dificultad = row[1].toString().trim();
          final categoria = row[2].toString().trim();
          
          // Guardar la dificultad de la palabra
          _wordDifficulties![palabra] = dificultad;
          
          // Inicializar la lista si no existe
          _words![categoria] ??= <String>[];
          
          // Añadir la palabra a la categoría
          if (!_words![categoria]!.contains(palabra)) {
            _words![categoria]!.add(palabra);
          }
        }
      }
      
      print('Palabras cargadas desde CSV:');
      _words!.forEach((categoria, palabras) {
        print('  $categoria: ${palabras.length} palabras');
      });
      
      // Mostrar estadísticas de dificultad
      final Map<String, int> difficultyCount = {};
      _wordDifficulties!.values.forEach((difficulty) {
        difficultyCount[difficulty] = (difficultyCount[difficulty] ?? 0) + 1;
      });
      print('Distribución por dificultad:');
      difficultyCount.forEach((difficulty, count) {
        print('  $difficulty: $count palabras');
      });
      
    } catch (e) {
      print('Error cargando palabras desde CSV: $e');
      _words = {};
      _wordDifficulties = {};
    }
  }

  Future<List<Word>> getWords({required String category, required int count}) async {
    if (_words == null) await initialize();
    
    List<String> wordPool;
    if (category == 'mixed') {
      wordPool = _words!.values.expand((words) => words).toList();
    } else {
      wordPool = _words![category] ?? [];
    }

    if (wordPool.isEmpty) {
      throw Exception('No hay palabras disponibles para la categoría: $category');
    }

    final selectedWords = <Word>[];
    final tempPool = List<String>.from(wordPool);

    while (selectedWords.length < count && tempPool.isNotEmpty) {
      final index = _random.nextInt(tempPool.length);
      final word = tempPool.removeAt(index);
      selectedWords.add(Word(
        text: word,
        category: category == 'mixed' ? _findCategory(word) : category,
      ));
    }

    return selectedWords;
  }

  Future<List<Word>> getWordsByDifficulty({required String difficulty, required int count}) async {
    if (_words == null || _wordDifficulties == null) await initialize();
    
    // Filtrar palabras por dificultad
    final wordsWithDifficulty = <String>[];
    _wordDifficulties!.forEach((palabra, dif) {
      if (dif.toLowerCase() == difficulty.toLowerCase()) {
        wordsWithDifficulty.add(palabra);
      }
    });

    if (wordsWithDifficulty.isEmpty) {
      throw Exception('No hay palabras disponibles para la dificultad: $difficulty');
    }

    final selectedWords = <Word>[];
    final tempPool = List<String>.from(wordsWithDifficulty);

    while (selectedWords.length < count && tempPool.isNotEmpty) {
      final index = _random.nextInt(tempPool.length);
      final word = tempPool.removeAt(index);
      selectedWords.add(Word(
        text: word,
        category: _findCategory(word),
      ));
    }

    return selectedWords;
  }

  String? getWordDifficulty(String word) {
    return _wordDifficulties?[word];
  }

  String _findCategory(String word) {
    for (final entry in _words!.entries) {
      if (entry.value.contains(word)) {
        return entry.key;
      }
    }
    return 'mixed';
  }

  List<String> get availableCategories => _words?.keys.toList() ?? [];
} 