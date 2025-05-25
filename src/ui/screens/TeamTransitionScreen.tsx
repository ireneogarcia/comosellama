import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  TouchableOpacity,
} from 'react-native';
import { Team } from '../../core/teams/TeamGame';
import { RoundPloc } from '../../core/presentation/RoundPloc';

interface TeamTransitionScreenProps {
  navigation: any;
  route: any;
  roundPloc: RoundPloc;
}

export const TeamTransitionScreen: React.FC<TeamTransitionScreenProps> = ({ navigation, route, roundPloc }) => {
  const { currentTeam, roundNumber, maxRounds } = route.params;
  const timePerRound = route.params?.timePerRound || 30;

  const handleStartRound = async () => {
    await roundPloc.startTeamRound();
    navigation.navigate('Game', route.params);
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.header}>
          <Text style={styles.title}>📱 Pasa el móvil</Text>
          <Text style={styles.subtitle}>
            Es el turno del siguiente equipo
          </Text>
        </View>

        <View style={[styles.teamContainer, { backgroundColor: currentTeam.color }]}>
          <Text style={styles.teamLabel}>Turno de:</Text>
          <Text style={styles.teamName}>{currentTeam.name}</Text>
          <Text style={styles.roundInfo}>
            Ronda {roundNumber} de {maxRounds}
          </Text>
        </View>

        <View style={styles.instructionsContainer}>
          <Text style={styles.instructionsTitle}>📋 Instrucciones:</Text>
          <Text style={styles.instructionText}>
            • Pasa el móvil al equipo {currentTeam.name}
          </Text>
          <Text style={styles.instructionText}>
            • Tendrán {timePerRound} segundos para acertar las 5 palabras
          </Text>
          <Text style={styles.instructionText}>
            • Toca ✓ si aciertan o ✗ si fallan cada palabra
          </Text>
        </View>

        <TouchableOpacity 
          style={[styles.startButton, { backgroundColor: currentTeam.color }]} 
          onPress={handleStartRound}
        >
          <Text style={styles.startButtonText}>🚀 EMPEZAR RONDA</Text>
        </TouchableOpacity>

        <View style={styles.footer}>
          <Text style={styles.footerText}>
            ¡Que comience la diversión! 🎉
          </Text>
        </View>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  content: {
    flex: 1,
    padding: 24,
    justifyContent: 'space-between',
  },
  header: {
    alignItems: 'center',
    marginTop: 40,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#2C3E50',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 18,
    color: '#7F8C8D',
    textAlign: 'center',
  },
  teamContainer: {
    borderRadius: 20,
    padding: 32,
    alignItems: 'center',
    marginVertical: 32,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  teamLabel: {
    fontSize: 18,
    color: 'white',
    opacity: 0.9,
    marginBottom: 8,
  },
  teamName: {
    fontSize: 36,
    fontWeight: 'bold',
    color: 'white',
    textAlign: 'center',
    marginBottom: 8,
  },
  roundInfo: {
    fontSize: 16,
    color: 'white',
    opacity: 0.9,
  },
  instructionsContainer: {
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 24,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  instructionsTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2C3E50',
    marginBottom: 16,
  },
  instructionText: {
    fontSize: 16,
    color: '#2C3E50',
    marginBottom: 8,
    lineHeight: 22,
  },
  startButton: {
    borderRadius: 16,
    padding: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  startButtonText: {
    color: 'white',
    fontSize: 20,
    fontWeight: 'bold',
  },
  footer: {
    alignItems: 'center',
    marginBottom: 20,
  },
  footerText: {
    fontSize: 16,
    color: '#95A5A6',
    textAlign: 'center',
  },
}); 