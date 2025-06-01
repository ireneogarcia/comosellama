import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/password/round_service.dart';
import 'core/password/word_repository.dart';
import 'core/game/game_controller.dart';
import 'core/theme/dopamine_theme.dart';
import 'ui/blocs/round_bloc.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/game_mode_selection_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/stats_screen.dart';
import 'examples/round_management_example.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar el repositorio de palabras (sistema antiguo para compatibilidad)
  final wordRepository = WordRepository();
  await wordRepository.initialize();
  
  // Inicializar el nuevo sistema mejorado
  final serviceLocator = ServiceLocator();
  await serviceLocator.initialize();
  
  runApp(DeslizasApp(
    wordRepository: wordRepository,
    serviceLocator: serviceLocator,
  ));
}

class DeslizasApp extends StatelessWidget {
  final WordRepository wordRepository;
  final ServiceLocator serviceLocator;
  
  const DeslizasApp({
    super.key, 
    required this.wordRepository,
    required this.serviceLocator,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Sistema antiguo (para compatibilidad)
        Provider.value(value: wordRepository),
        
        // Nuevo sistema mejorado
        Provider.value(value: serviceLocator),
        
        // Servicio de rondas (sistema antiguo)
        ProxyProvider<WordRepository, RoundService>(
          update: (_, wordRepository, __) => RoundService(wordRepository),
        ),
        
        // Controlador de juego (lógica de negocio - sistema antiguo)
        ProxyProvider<RoundService, GameController>(
          update: (_, roundService, __) => GameController(roundService),
        ),
        
        // Bloc de presentación (sistema antiguo)
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
        home: const MainNavigator(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const GameModeSelectionScreen(),
    const StatsScreen(),
    const SettingsScreen(),
    const RoundManagementExample(), // Ejemplo de desarrollo con CSV
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Jugar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Rondas CSV',
          ),
        ],
      ),
    );
  }
} 