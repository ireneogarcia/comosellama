import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/enhanced_word.dart';

class CsvWordLoader {
  static const String _csvPath = 'assets/words/words_file.csv';

  static Future<List<EnhancedWord>> loadWordsFromCsv() async {
    try {
      final String csvString = await rootBundle.loadString(_csvPath);
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
      
      print('=== CARGANDO PALABRAS DESDE CSV ===');
      print('Total de filas en CSV: ${csvData.length}');
      
      // Saltar la primera fila (headers)
      final List<EnhancedWord> words = [];
      final Map<String, int> difficultyCount = {'fácil': 0, 'media': 0, 'difícil': 0, 'extrema': 0};
      
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.length >= 4) {
          try {
            final word = EnhancedWord.fromCsv(row.map((e) => e.toString()).toList());
            words.add(word);
            difficultyCount[word.dificultad.value] = (difficultyCount[word.dificultad.value] ?? 0) + 1;
            
            // Mostrar las primeras 10 palabras para depuración
            if (i <= 10) {
              print('Fila $i: ${word.palabra} - ${word.dificultad.value} - ${word.categoria}');
            }
          } catch (e) {
            print('Error procesando fila $i: $e');
            print('Contenido de la fila: $row');
            continue;
          }
        }
      }
      
      print('Cargadas ${words.length} palabras desde CSV');
      print('Distribución por dificultad:');
      difficultyCount.forEach((difficulty, count) {
        print('  $difficulty: $count palabras');
      });
      print('=== FIN CARGA CSV ===');
      
      return words;
    } catch (e) {
      print('Error cargando palabras desde CSV: $e');
      return [];
    }
  }
} 