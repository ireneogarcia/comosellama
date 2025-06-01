import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/word_status.dart';

class WordPersistenceService {
  static const String _wordsStatusKey = 'words_status';
  static const String _lastResetKey = 'last_reset';

  Future<Map<String, WordStatus>> loadWordsStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? statusJson = prefs.getString(_wordsStatusKey);
      
      if (statusJson == null) return {};
      
      final Map<String, dynamic> statusMap = json.decode(statusJson);
      return statusMap.map((key, value) => 
          MapEntry(key, WordStatus.fromJson(value)));
    } catch (e) {
      print('Error cargando estado de palabras: $e');
      return {};
    }
  }

  Future<void> saveWordsStatus(Map<String, WordStatus> wordsStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, String> statusMap = wordsStatus.map((key, value) => 
          MapEntry(key, value.toJson()));
      
      await prefs.setString(_wordsStatusKey, json.encode(statusMap));
    } catch (e) {
      print('Error guardando estado de palabras: $e');
    }
  }

  Future<void> markWordAsPlayed(String palabra, WordStatus status) async {
    final wordsStatus = await loadWordsStatus();
    wordsStatus[palabra] = status;
    await saveWordsStatus(wordsStatus);
  }

  Future<void> resetAllWords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wordsStatusKey);
      await prefs.setString(_lastResetKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error reseteando palabras: $e');
    }
  }

  Future<DateTime?> getLastResetDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? dateString = prefs.getString(_lastResetKey);
      return dateString != null ? DateTime.parse(dateString) : null;
    } catch (e) {
      print('Error obteniendo fecha de reset: $e');
      return null;
    }
  }

  Future<Map<WordStatus, int>> getWordsStatistics() async {
    final wordsStatus = await loadWordsStatus();
    final stats = <WordStatus, int>{
      WordStatus.noJugada: 0,
      WordStatus.adivinada: 0,
      WordStatus.noAdivinada: 0,
    };

    for (final status in wordsStatus.values) {
      stats[status] = (stats[status] ?? 0) + 1;
    }

    return stats;
  }
} 