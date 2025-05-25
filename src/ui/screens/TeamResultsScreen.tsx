import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import { Team } from '../../core/teams/TeamGame';

interface TeamResultsScreenProps {
  navigation: any;
  route: any;
}

export const TeamResultsScreen: React.FC<TeamResultsScreenProps> = ({ navigation, route }) => {
  const { ranking, winners } = route.params;

  const handleNewGame = () => {
    navigation.reset({
      index: 1,
      routes: [
        { name: 'Home' },
        { 
          name: 'TeamSetup', 
          params: { 
            selectedCategory: route.params?.selectedCategory,
            previousTeams: ranking,
            numberOfRounds: route.params?.numberOfRounds,
            timePerRound: route.params?.timePerRound
          } 
        }
      ],
    });
  };

  const handleHome = () => {
    navigation.reset({
      index: 0,
      routes: [{ name: 'Home' }],
    });
  };

  const renderPodium = () => {
    const topThree = ranking.slice(0, 3);
    
    return (
      <View style={styles.podiumContainer}>
        {topThree.map((team: Team, index: number) => (
          <View key={team.id} style={[styles.podiumPlace, getPodiumStyle(index)]}>
            <View style={[styles.podiumRank, { backgroundColor: team.color }]}>
              <Text style={styles.podiumRankText}>
                {index + 1}
              </Text>
            </View>
            <Text style={[styles.podiumTeamName, getTeamNameStyle(index)]}>
              {team.name}
            </Text>
            <Text style={[styles.podiumScore, getScoreStyle(index)]}>
              {team.score} puntos
            </Text>
            {index === 0 && (
              <Text style={styles.crownIcon}>👑</Text>
            )}
          </View>
        ))}
      </View>
    );
  };

  const getPodiumStyle = (index: number) => {
    switch (index) {
      case 0: return styles.firstPlace;
      case 1: return styles.secondPlace;
      case 2: return styles.thirdPlace;
      default: return {};
    }
  };

  const getTeamNameStyle = (index: number) => {
    return index === 0 ? styles.firstTeamName : styles.otherTeamName;
  };

  const getScoreStyle = (index: number) => {
    return index === 0 ? styles.firstScore : styles.otherScore;
  };

  const renderFullRanking = () => {
    return (
      <View style={styles.rankingContainer}>
        <Text style={styles.rankingTitle}>Clasificación completa</Text>
        {ranking.map((team: Team, index: number) => (
          <View key={team.id} style={styles.rankingRow}>
            <View style={[styles.rankingPosition, { backgroundColor: team.color }]}>
              <Text style={styles.rankingPositionText}>{index + 1}</Text>
            </View>
            <Text style={styles.rankingTeamName}>{team.name}</Text>
            <Text style={styles.rankingScore}>{team.score}</Text>
          </View>
        ))}
      </View>
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <Text style={styles.title}>🏆 Resultados Finales</Text>
          {winners.length === 1 ? (
            <Text style={styles.winnerText}>
              ¡{winners[0].name} ha ganado!
            </Text>
          ) : (
            <Text style={styles.winnerText}>
              ¡Empate entre {winners.map((w: Team) => w.name).join(' y ')}!
            </Text>
          )}
        </View>

        {renderPodium()}
        {renderFullRanking()}

        <View style={styles.actionsContainer}>
          <TouchableOpacity style={styles.newGameButton} onPress={handleNewGame}>
            <Text style={styles.newGameButtonText}>🔄 Nuevo Juego</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.homeButton} onPress={handleHome}>
            <Text style={styles.homeButtonText}>🏠 Volver al Inicio</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: 24,
  },
  header: {
    alignItems: 'center',
    marginBottom: 32,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#2C3E50',
    marginBottom: 16,
  },
  winnerText: {
    fontSize: 20,
    fontWeight: '600',
    color: '#F39C12',
    textAlign: 'center',
  },
  podiumContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'end',
    marginBottom: 32,
    gap: 16,
  },
  podiumPlace: {
    alignItems: 'center',
    padding: 16,
    borderRadius: 16,
    minWidth: 100,
    position: 'relative',
  },
  firstPlace: {
    backgroundColor: '#F1C40F',
    transform: [{ scale: 1.1 }],
  },
  secondPlace: {
    backgroundColor: '#BDC3C7',
  },
  thirdPlace: {
    backgroundColor: '#CD7F32',
  },
  podiumRank: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  podiumRankText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
  },
  podiumTeamName: {
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
    marginBottom: 4,
  },
  firstTeamName: {
    color: '#2C3E50',
  },
  otherTeamName: {
    color: '#2C3E50',
  },
  podiumScore: {
    fontSize: 14,
    fontWeight: '500',
  },
  firstScore: {
    color: '#2C3E50',
  },
  otherScore: {
    color: '#2C3E50',
  },
  crownIcon: {
    fontSize: 24,
    position: 'absolute',
    top: -12,
    right: -8,
  },
  rankingContainer: {
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 20,
    marginBottom: 32,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  rankingTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2C3E50',
    marginBottom: 16,
    textAlign: 'center',
  },
  rankingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#E9ECEF',
  },
  rankingPosition: {
    width: 30,
    height: 30,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  rankingPositionText: {
    color: 'white',
    fontWeight: 'bold',
    fontSize: 14,
  },
  rankingTeamName: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: '#2C3E50',
  },
  rankingScore: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#4A90E2',
  },
  actionsContainer: {
    gap: 16,
  },
  newGameButton: {
    backgroundColor: '#27AE60',
    borderRadius: 12,
    padding: 20,
    alignItems: 'center',
  },
  newGameButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  homeButton: {
    backgroundColor: '#95A5A6',
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
  },
  homeButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
}); 