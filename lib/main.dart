import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/password/round_service.dart';
import 'core/password/word_repository.dart';
import 'core/game/game_controller.dart';
import 'core/theme/dopamine_theme.dart';
import 'ui/blocs/round_bloc.dart';
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
        // Repositorio de palabras
        Provider.value(value: wordRepository),
        
        // Servicio de rondas
        ProxyProvider<WordRepository, RoundService>(
          update: (_, wordRepository, __) => RoundService(wordRepository),
        ),
        
        // Controlador de juego (lógica de negocio)
        ProxyProvider<RoundService, GameController>(
          update: (_, roundService, __) => GameController(roundService),
        ),
        
        // Bloc de presentación
        ChangeNotifierProxyProvider<GameController, RoundBloc>(
          create: (context) => RoundBloc(
            Provider.of<GameController>(context, listen: false),
          ),
          update: (_, gameController, previous) => 
              previous ?? RoundBloc(gameController),
        ),
      ],
      child: MaterialApp(
        title: 'Deslizas',
        theme: DopamineTheme.theme,
        home: const HomeScreen(),
      ),
    );
  }
} 