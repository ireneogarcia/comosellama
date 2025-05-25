import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { StorageService, GameStats } from '../../core/storage/StorageService';

interface HomeScreenProps {
  navigation: any;
  storageService: StorageService;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({ navigation, storageService }) => {
  const [stats, setStats] = useState<GameStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      const gameStats = await storageService.getGameStats();
      setStats(gameStats);
    } catch (error) {
      console.error('Error al cargar estadísticas:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleStartGame = () => {
    navigation.navigate('Categories');
  };

  const handleQuickPlay = () => {
    navigation.navigate('Game', { selectedCategory: undefined });
  };

  const handleTeamPlay = () => {
    navigation.navigate('TeamSetup', { selectedCategory: undefined });
  };

  const handleDonate = () => {
    Alert.alert(
      '¡Gracias por tu apoyo!',
      '¿Quieres donar para eliminar los anuncios y apoyar el desarrollo?',
      [
        {
          text: 'Cancelar',
          style: 'cancel',
        },
        {
          text: 'Donar',
          onPress: async () => {
            await storageService.setUserDonationStatus(true);
            Alert.alert('¡Gracias!', 'Has donado exitosamente. Los anuncios han sido eliminados.');
            loadStats(); // Recargar estadísticas
          },
        },
      ]
    );
  };

  const handleViewStats = () => {
    navigation.navigate('Stats');
  };

  const handleSettings = () => {
    navigation.navigate('Settings');
  };

  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#4A90E2" />
          <Text style={styles.loadingText}>Cargando...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.header}>
          <View style={styles.titleContainer}>
            <Text style={styles.title}>Deslizas</Text>
            <Text style={styles.subtitle}>El juego de las palabras</Text>
          </View>
          <TouchableOpacity style={styles.settingsButton} onPress={handleSettings}>
            <Text style={styles.settingsIcon}>⚙️</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.statsContainer}>
          <Text style={styles.statsTitle}>Tus estadísticas</Text>
          <View style={styles.statsRow}>
            <Text style={styles.statsLabel}>Rondas jugadas:</Text>
            <Text style={styles.statsValue}>{stats?.totalRoundsPlayed || 0}</Text>
          </View>
          <View style={styles.statsRow}>
            <Text style={styles.statsLabel}>Mejor puntuación:</Text>
            <Text style={styles.statsValue}>{stats?.bestScore || 0}/5</Text>
          </View>
          <View style={styles.statsRow}>
            <Text style={styles.statsLabel}>Promedio:</Text>
            <Text style={styles.statsValue}>
              {stats?.averageScore ? stats.averageScore.toFixed(1) : '0.0'}/5
            </Text>
          </View>
          {stats?.hasUserDonated && (
            <View style={styles.donatedBadge}>
              <Text style={styles.donatedText}>✨ Donador ✨</Text>
            </View>
          )}
        </View>

        <View style={styles.buttonContainer}>
          <TouchableOpacity style={styles.playButton} onPress={handleStartGame}>
            <Text style={styles.playButtonText}>Elegir categoría</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.quickPlayButton} onPress={handleQuickPlay}>
            <Text style={styles.quickPlayButtonText}>Juego rápido (mixto)</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.teamPlayButton} onPress={handleTeamPlay}>
            <Text style={styles.teamPlayButtonText}>🏆 Jugar por equipos</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.statsButton} onPress={handleViewStats}>
            <Text style={styles.statsButtonText}>Ver estadísticas</Text>
          </TouchableOpacity>

          {!stats?.hasUserDonated && (
            <TouchableOpacity style={styles.donateButton} onPress={handleDonate}>
              <Text style={styles.donateButtonText}>Donar (Sin anuncios)</Text>
            </TouchableOpacity>
          )}
        </View>

        <View style={styles.footer}>
          <Text style={styles.footerText}>
            Toca ✓ si aciertan o ✗ si fallan cada palabra
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
  content: {
    flex: 1,
    padding: 24,
    justifyContent: 'space-between',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 40,
    paddingHorizontal: 24,
  },
  titleContainer: {
    alignItems: 'center',
    flex: 1,
  },
  title: {
    fontSize: 48,
    fontWeight: 'bold',
    color: '#2C3E50',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 18,
    color: '#7F8C8D',
    textAlign: 'center',
  },
  statsContainer: {
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 24,
    marginVertical: 32,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  statsTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2C3E50',
    marginBottom: 16,
    textAlign: 'center',
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  statsLabel: {
    fontSize: 16,
    color: '#7F8C8D',
  },
  statsValue: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2C3E50',
  },
  donatedBadge: {
    backgroundColor: '#F39C12',
    borderRadius: 20,
    paddingVertical: 8,
    paddingHorizontal: 16,
    alignSelf: 'center',
    marginTop: 16,
  },
  donatedText: {
    color: 'white',
    fontWeight: '600',
    fontSize: 14,
  },
  buttonContainer: {
    gap: 16,
  },
  playButton: {
    backgroundColor: '#4A90E2',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    shadowColor: '#4A90E2',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 6,
  },
  playButtonText: {
    color: 'white',
    fontSize: 20,
    fontWeight: '600',
  },
  statsButton: {
    backgroundColor: 'white',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#4A90E2',
  },
  statsButtonText: {
    color: '#4A90E2',
    fontSize: 16,
    fontWeight: '600',
  },
  donateButton: {
    backgroundColor: '#E74C3C',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
  },
  donateButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  footer: {
    alignItems: 'center',
    marginBottom: 20,
  },
  footerText: {
    fontSize: 14,
    color: '#95A5A6',
    textAlign: 'center',
    lineHeight: 20,
  },
  quickPlayButton: {
    backgroundColor: 'white',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#27AE60',
  },
  quickPlayButtonText: {
    color: '#27AE60',
    fontSize: 16,
    fontWeight: '600',
  },
  teamPlayButton: {
    backgroundColor: '#9B59B6',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    shadowColor: '#9B59B6',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 6,
  },
  teamPlayButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  settingsButton: {
    padding: 8,
  },
  settingsIcon: {
    fontSize: 24,
  },
}); 