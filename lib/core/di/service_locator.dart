import '../services/word_persistence_service.dart';
import '../services/enhanced_round_service.dart';
import '../use_cases/round_management_use_case.dart';
import '../presentation/enhanced_round_bloc.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Servicios
  late final WordPersistenceService _persistenceService;
  late final EnhancedRoundService _roundService;
  late final RoundManagementUseCase _roundManagementUseCase;
  late final EnhancedRoundBloc _roundBloc;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    print('=== INICIALIZANDO SERVICE LOCATOR ===');
    
    // Inicializar servicios en orden de dependencia
    _persistenceService = WordPersistenceService();
    _roundService = EnhancedRoundService(_persistenceService);
    _roundManagementUseCase = RoundManagementUseCase(_roundService);
    _roundBloc = EnhancedRoundBloc(_roundManagementUseCase);

    print('Service Locator inicializado correctamente');
    _initialized = true;
  }

  // Getters para acceder a los servicios
  WordPersistenceService get persistenceService {
    _ensureInitialized();
    return _persistenceService;
  }

  EnhancedRoundService get roundService {
    _ensureInitialized();
    return _roundService;
  }

  RoundManagementUseCase get roundManagementUseCase {
    _ensureInitialized();
    return _roundManagementUseCase;
  }

  EnhancedRoundBloc get roundBloc {
    _ensureInitialized();
    return _roundBloc;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception('ServiceLocator no ha sido inicializado. Llama a initialize() primero.');
    }
  }

  void dispose() {
    if (_initialized) {
      _roundBloc.dispose();
      _initialized = false;
    }
  }
} 