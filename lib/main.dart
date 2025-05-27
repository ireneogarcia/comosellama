import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/password/round_service.dart';
import 'core/password/word_repository.dart';
import 'core/presentation/round_ploc.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar el repositorio de palabras
  final wordRepository = WordRepository();
  await wordRepository.initialize();
  
  runApp(DeslizasApp(wordRepository: wordRepository));
}

class DeslizasApp extends StatelessWidget {
  final WordRepository wordRepository;
  
  const DeslizasApp({super.key, required this.wordRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(
          value: wordRepository,
        ),
        ProxyProvider<WordRepository, RoundService>(
          update: (_, wordRepository, __) => RoundService(wordRepository),
        ),
        ChangeNotifierProxyProvider<RoundService, RoundPloc>(
          create: (context) => RoundPloc(
            Provider.of<RoundService>(context, listen: false),
          ),
          update: (_, roundService, previous) => previous ?? RoundPloc(roundService),
        ),
      ],
      child: MaterialApp(
        title: 'Deslizas',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          brightness: Brightness.light,
          useMaterial3: true,
          fontFamily: 'Roboto',
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 3,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
} 