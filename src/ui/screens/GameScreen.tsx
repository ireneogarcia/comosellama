import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  Animated,
  PanResponder,
  Dimensions,
  ActivityIndicator,
  Alert,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import { RoundPloc, GameState, RoundPlocState } from '../../core/presentation/RoundPloc';
import { Team } from '../../core/teams/TeamGame';

interface GameScreenProps {
  navigation: any;
  roundPloc: RoundPloc;
  route: any;
}

const { width: screenWidth, height: screenHeight } = Dimensions.get('window');
const SWIPE_THRESHOLD = screenWidth * 0.25;

export const GameScreen: React.FC<GameScreenProps> = ({ navigation, roundPloc, route }) => {
  const [state, setState] = useState<RoundPlocState>(roundPloc.getState());
  const [selectedWordIndex, setSelectedWordIndex] = useState<number | null>(null);
  const [timeLeft, setTimeLeft] = useState<number>(30);
  const [timerActive, setTimerActive] = useState<boolean>(false);
  const pan = useRef(new Animated.ValueXY()).current;
  const opacity = useRef(new Animated.Value(1)).current;
  const scale = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    const unsubscribe = roundPloc.subscribe(setState);
    const selectedCategory = route?.params?.selectedCategory;
    const teams = route?.params?.teams;
    const numberOfRounds = route?.params?.numberOfRounds;
    
    roundPloc.initialize(selectedCategory, teams, numberOfRounds);
    
    return unsubscribe;
  }, []);

  // Timer effect para modo equipos
  useEffect(() => {
    let interval: NodeJS.Timeout;
    
    if (timerActive && timeLeft > 0 && state.gameMode === 'teams') {
      interval = setInterval(() => {
        setTimeLeft((prev) => {
          if (prev <= 1) {
            setTimerActive(false);
            // Tiempo agotado, pasar al siguiente equipo
            setTimeout(() => {
              handleTimeUp();
            }, 100);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    }

    return () => {
      if (interval) {
        clearInterval(interval);
      }
    };
  }, [timerActive, timeLeft, state.gameMode]);

  // Inicializar timer cuando comienza una nueva ronda en modo equipos
  useEffect(() => {
    if (state.gameState === GameState.PLAYING && state.gameMode === 'teams') {
      setTimeLeft(30);
      setTimerActive(true);
    } else {
      setTimerActive(false);
    }
  }, [state.gameState, state.gameMode, state.currentTeam]);

  const resetCardPosition = () => {
    Animated.parallel([
      Animated.spring(pan, {
        toValue: { x: 0, y: 0 },
        useNativeDriver: false,
      }),
      Animated.spring(opacity, {
        toValue: 1,
        useNativeDriver: false,
      }),
      Animated.spring(scale, {
        toValue: 1,
        useNativeDriver: false,
      }),
    ]).start();
  };

  const handleWordPress = (wordIndex: number, isCorrect: boolean) => {
    if (state.gameState !== GameState.PLAYING) return;
    
    setSelectedWordIndex(wordIndex);
    
    // Animación de feedback
    Animated.sequence([
      Animated.timing(scale, {
        toValue: 0.95,
        duration: 100,
        useNativeDriver: false,
      }),
      Animated.timing(scale, {
        toValue: 1,
        duration: 100,
        useNativeDriver: false,
      }),
    ]).start();

    // Marcar la palabra después de un breve delay para mostrar el feedback visual
    setTimeout(() => {
      roundPloc.markWordAtIndex(wordIndex, isCorrect);
      setSelectedWordIndex(null);
    }, 200);
  };

  const handleTimeUp = () => {
    if (state.gameMode === 'teams') {
      Alert.alert(
        '¡Tiempo agotado!',
        `Se acabó el tiempo para ${state.currentTeam?.name}. Puntuación: ${state.score}/5`,
        [
          {
            text: 'Siguiente equipo',
            onPress: () => roundPloc.nextTeamTurn(),
          },
        ]
      );
    }
  };

  const handleRoundCompleted = () => {
    if (state.gameMode === 'teams') {
      // Detener timer
      setTimerActive(false);
      
      // Modo equipos - pasar automáticamente al siguiente equipo
      setTimeout(() => {
        roundPloc.nextTeamTurn();
      }, 500); // Pequeño delay para que se vea la última palabra marcada
    } else {
      // Modo individual
      Alert.alert(
        'Ronda completada',
        `¡Has acertado ${state.score} de 5 palabras!`,
        [
          {
            text: 'Nueva ronda',
            onPress: () => roundPloc.startNewRound(),
          },
          {
            text: 'Volver al inicio',
            onPress: () => navigation.navigate('Home'),
          },
        ]
      );
    }
  };

  const handleTeamGameFinished = () => {
    const winners = roundPloc.getWinningTeams();
    const ranking = roundPloc.getTeamRanking();
    
    // Navegar directamente a la pantalla de resultados
    navigation.navigate('TeamResults', {
      ranking,
      winners,
      selectedCategory: route.params?.selectedCategory,
      numberOfRounds: route.params?.numberOfRounds
    });
  };

  const handleTeamTransition = () => {
    // Navegar a la pantalla de transición
    navigation.navigate('TeamTransition', {
      currentTeam: state.currentTeam,
      roundNumber: state.roundNumber,
      maxRounds: state.maxRounds,
      teams: route.params?.teams,
      gameMode: 'teams',
      numberOfRounds: route.params?.numberOfRounds,
      selectedCategory: route.params?.selectedCategory,
    });
  };

  useEffect(() => {
    if (state.gameState === GameState.ROUND_COMPLETED && !state.isAdShowing) {
      handleRoundCompleted();
    } else if (state.gameState === GameState.TEAM_GAME_FINISHED) {
      handleTeamGameFinished();
    } else if (state.gameState === GameState.TEAM_TRANSITION) {
      handleTeamTransition();
    }
  }, [state.gameState, state.isAdShowing]);

  const renderProgressBar = () => {
    const completedWords = roundPloc.getCurrentResults().filter(result => result !== null).length;
    const progress = (completedWords / 5) * 100;
    return (
      <View style={styles.progressContainer}>
        <View style={styles.progressBar}>
          <View style={[styles.progressFill, { width: `${progress}%` }]} />
        </View>
        <Text style={styles.progressText}>{completedWords}/5</Text>
      </View>
    );
  };

  const renderTeamInfo = () => {
    if (state.gameMode !== 'teams' || !state.currentTeam) return null;

    return (
      <View style={[styles.teamInfoContainer, { backgroundColor: state.currentTeam.color }]}>
        <Text style={styles.currentTeamLabel}>Turno de:</Text>
        <Text style={styles.currentTeamName}>{state.currentTeam.name}</Text>
        <Text style={styles.roundInfo}>
          Ronda {state.roundNumber} de {state.maxRounds}
        </Text>
      </View>
    );
  };

  const renderTimer = () => {
    if (state.gameMode !== 'teams' || !timerActive) return null;

    const isLowTime = timeLeft <= 10;
    const timerColor = isLowTime ? '#E74C3C' : state.currentTeam?.color || '#4A90E2';
    
    return (
      <View style={[styles.timerContainer, { backgroundColor: timerColor }]}>
        <Text style={[styles.timerText, isLowTime && styles.timerTextWarning]}>
          ⏱️ {timeLeft}s
        </Text>
      </View>
    );
  };

  const renderTeamScores = () => {
    if (state.gameMode !== 'teams') return null;

    const teams = roundPloc.getAllTeams();
    
    return (
      <ScrollView 
        horizontal 
        style={styles.scoresContainer}
        contentContainerStyle={styles.scoresContent}
        showsHorizontalScrollIndicator={false}
      >
        {teams.map((team, index) => (
          <View 
            key={team.id} 
            style={[
              styles.teamScoreCard,
              team.id === state.currentTeam?.id && styles.currentTeamCard
            ]}
          >
            <Text style={[
              styles.teamScoreName,
              team.id === state.currentTeam?.id && styles.currentTeamText
            ]}>
              {team.name}
            </Text>
            <Text style={[
              styles.teamScorePoints,
              team.id === state.currentTeam?.id && styles.currentTeamText
            ]}>
              {team.score}
            </Text>
          </View>
        ))}
      </ScrollView>
    );
  };

  const renderAllWords = () => {
    const words = roundPloc.getCurrentWords();
    const results = roundPloc.getCurrentResults();
    
    return (
      <View style={styles.wordsContainer}>
        <Text style={styles.instructionTitle}>
          Toca ✓ si acertó o ✗ si falló cada palabra:
        </Text>
        
        {words.map((word, index) => {
          const isCompleted = results[index] !== null;
          const isCorrect = results[index] === true;
          const isSelected = selectedWordIndex === index;
          
          return (
            <View key={index} style={styles.wordCard}>
              <Text style={[
                styles.wordText,
                isCompleted && isCorrect && styles.correctWordText,
                isCompleted && !isCorrect && styles.incorrectWordText,
                isSelected && styles.selectedWordText,
              ]}>
                {word}
              </Text>
              
              {!isCompleted ? (
                <View style={styles.buttonsContainer}>
                  <TouchableOpacity
                    style={[styles.actionButton, styles.incorrectButton]}
                    onPress={() => handleWordPress(index, false)}
                    disabled={state.gameState !== GameState.PLAYING}
                  >
                    <Text style={styles.buttonText}>✗</Text>
                  </TouchableOpacity>
                  
                  <TouchableOpacity
                    style={[styles.actionButton, styles.correctButton]}
                    onPress={() => handleWordPress(index, true)}
                    disabled={state.gameState !== GameState.PLAYING}
                  >
                    <Text style={styles.buttonText}>✓</Text>
                  </TouchableOpacity>
                </View>
              ) : (
                <View style={styles.resultContainer}>
                  <Text style={[
                    styles.resultIcon,
                    isCorrect ? styles.correctResult : styles.incorrectResult
                  ]}>
                    {isCorrect ? '✓' : '✗'}
                  </Text>
                  <Text style={[
                    styles.resultText,
                    isCorrect ? styles.correctResultText : styles.incorrectResultText
                  ]}>
                    {isCorrect ? 'Acertó' : 'Falló'}
                  </Text>
                </View>
              )}
            </View>
          );
        })}
      </View>
    );
  };

  if (state.gameState === GameState.LOADING) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#4A90E2" />
          <Text style={styles.loadingText}>Preparando nueva ronda...</Text>
        </View>
      </SafeAreaView>
    );
  }

  if (state.gameState === GameState.SHOWING_AD) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#E74C3C" />
          <Text style={styles.loadingText}>Mostrando anuncio...</Text>
        </View>
      </SafeAreaView>
    );
  }

  if (state.gameState === GameState.ERROR) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>Error: {state.error}</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        {renderProgressBar()}
        {state.categoryDisplayName && (
          <Text style={styles.categoryLabel}>
            Categoría: {state.categoryDisplayName}
          </Text>
        )}
        {renderTeamInfo()}
        {renderTimer()}
      </View>

      <View style={styles.gameArea}>
        {renderAllWords()}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  errorText: {
    fontSize: 18,
    color: '#E74C3C',
    textAlign: 'center',
  },
  header: {
    padding: 24,
    paddingBottom: 16,
  },
  progressContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
  },
  progressBar: {
    flex: 1,
    height: 8,
    backgroundColor: '#E9ECEF',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#4A90E2',
    borderRadius: 4,
  },
  progressText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2C3E50',
    minWidth: 40,
  },
  categoryLabel: {
    fontSize: 14,
    color: '#7F8C8D',
    textAlign: 'center',
    marginTop: 8,
    fontStyle: 'italic',
  },
  teamInfoContainer: {
    borderRadius: 12,
    padding: 16,
    marginTop: 16,
    alignItems: 'center',
  },
  currentTeamLabel: {
    fontSize: 14,
    color: 'white',
    opacity: 0.9,
  },
  currentTeamName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
    marginTop: 4,
  },
  roundInfo: {
    fontSize: 14,
    color: 'white',
    opacity: 0.9,
    marginTop: 4,
  },
  scoresContainer: {
    paddingHorizontal: 24,
    marginBottom: 16,
  },
  scoresContent: {
    gap: 12,
  },
  teamScoreCard: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
    minWidth: 100,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    borderWidth: 2,
    borderColor: '#E9ECEF',
  },
  currentTeamCard: {
    backgroundColor: '#4A90E2',
    borderColor: '#4A90E2',
  },
  teamScoreName: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2C3E50',
    textAlign: 'center',
  },
  currentTeamText: {
    color: 'white',
  },
  teamScorePoints: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2C3E50',
    marginTop: 4,
  },
  gameArea: {
    flex: 1,
    paddingHorizontal: 24,
    paddingBottom: 24,
  },
  wordsContainer: {
    flex: 1,
  },
  instructionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2C3E50',
    textAlign: 'center',
    marginBottom: 24,
    lineHeight: 24,
  },
  wordCard: {
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 20,
    marginBottom: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
    borderWidth: 2,
    borderColor: '#E9ECEF',
  },
  wordText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2C3E50',
    flex: 1,
  },
  correctWordText: {
    color: '#27AE60',
  },
  incorrectWordText: {
    color: '#E74C3C',
  },
  selectedWordText: {
    color: '#4A90E2',
  },
  buttonsContainer: {
    flexDirection: 'row',
    gap: 12,
  },
  actionButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.15,
    shadowRadius: 4,
    elevation: 3,
  },
  correctButton: {
    backgroundColor: '#27AE60',
  },
  incorrectButton: {
    backgroundColor: '#E74C3C',
  },
  buttonText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
  },
  resultContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  resultIcon: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  correctResult: {
    color: '#27AE60',
  },
  incorrectResult: {
    color: '#E74C3C',
  },
  resultText: {
    fontSize: 16,
    fontWeight: '600',
  },
  correctResultText: {
    color: '#27AE60',
  },
  incorrectResultText: {
    color: '#E74C3C',
  },
  timerContainer: {
    borderRadius: 12,
    padding: 8,
    marginTop: 16,
    alignItems: 'center',
  },
  timerText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: 'white',
  },
  timerTextWarning: {
    color: 'white',
  },
}); 