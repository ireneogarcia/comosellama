import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/word.dart';

class WordRepository {
  Map<String, List<String>>? _words;
  final Random _random = Random();

  Future<void> initialize() async {
    _words = {
      'animales': await _loadWordsFromCategory('animales'),
      'objetos': await _loadWordsFromCategory('objetos'),
      'comida': await _loadWordsFromCategory('comida'),
      'profesiones': await _loadWordsFromCategory('profesiones'),
      'deportes': await _loadWordsFromCategory('deportes'),
      'colores': await _loadWordsFromCategory('colores'),
      'emociones': await _loadWordsFromCategory('emociones'),
    };
  }

  Future<List<String>> _loadWordsFromCategory(String category) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/words/$category.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<String>();
    } catch (e) {
      print('Error cargando palabras de categoría $category: $e');
      return [];
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