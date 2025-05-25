import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { StorageService, GameStats } from '../../core/storage/StorageService';

interface StatsScreenProps {
  navigation: any;
  storageService: StorageService;
}

export const StatsScreen: React.FC<StatsScreenProps> = ({ navigation, storageService }) => {
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

  const handleResetStats = () => {
    Alert.alert(
      'Reiniciar estadísticas',
      '¿Estás seguro de que quieres borrar todas las estadísticas? Esta acción no se puede deshacer.',
      [
        {
          text: 'Cancelar',
          style: 'cancel',
        },
        {
          text: 'Reiniciar',
          style: 'destructive',
          onPress: async () => {
            await storageService.clearAllData();
            Alert.alert('Estadísticas reiniciadas', 'Todas las estadísticas han sido borradas.');
            loadStats();
          },
        },
      ]
    );
  };

  const getPerformanceLevel = (average: number): { level: string; color: string; emoji: string } => {
    if (average >= 4.5) return { level: 'Excelente', color: '#27AE60', emoji: '🏆' };
    if (average >= 3.5) return { level: 'Muy bueno', color: '#2ECC71', emoji: '🌟' };
    if (average >= 2.5) return { level: 'Bueno', color: '#F39C12', emoji: '👍' };
    if (average >= 1.5) return { level: 'Regular', color: '#E67E22', emoji: '📈' };
    return { level: 'Principiante', color: '#E74C3C', emoji: '🎯' };
  };

  const calculateAccuracy = (): number => {
    if (!stats || stats.totalRoundsPlayed === 0) return 0;
    return (stats.totalWordsCorrect / (stats.totalRoundsPlayed * 5)) * 100;
  };

  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#4A90E2" />
          <Text style={styles.loadingText}>Cargando estadísticas...</Text>
        </View>
      </SafeAreaView>
    );
  }

  if (!stats) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>Error al cargar las estadísticas</Text>
        </View>
      </SafeAreaView>
    );
  }

  const performance = getPerformanceLevel(stats.averageScore);
  const accuracy = calculateAccuracy();

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <TouchableOpacity
            style={styles.backButton}
            onPress={() => navigation.goBack()}
          >
            <Text style={styles.backButtonText}>← Volver</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Estadísticas</Text>
        </View>

        {/* Resumen general */}
        <View style={styles.summaryCard}>
          <Text style={styles.cardTitle}>Resumen general</Text>
          <View style={styles.summaryGrid}>
            <View style={styles.summaryItem}>
              <Text style={styles.summaryNumber}>{stats.totalRoundsPlayed}</Text>
              <Text style={styles.summaryLabel}>Rondas jugadas</Text>
            </View>
            <View style={styles.summaryItem}>
              <Text style={styles.summaryNumber}>{stats.totalWordsCorrect}</Text>
              <Text style={styles.summaryLabel}>Palabras acertadas</Text>
            </View>
          </View>
        </View>

        {/* Rendimiento */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Rendimiento</Text>
          
          <View style={styles.performanceContainer}>
            <Text style={styles.performanceEmoji}>{performance.emoji}</Text>
            <Text style={[styles.performanceLevel, { color: performance.color }]}>
              {performance.level}
            </Text>
          </View>

          <View style={styles.statRow}>
            <Text style={styles.statLabel}>Mejor puntuación:</Text>
            <Text style={styles.statValue}>{stats.bestScore}/5</Text>
          </View>

          <View style={styles.statRow}>
            <Text style={styles.statLabel}>Promedio por ronda:</Text>
            <Text style={styles.statValue}>
              {stats.averageScore ? stats.averageScore.toFixed(1) : '0.0'}/5
            </Text>
          </View>

          <View style={styles.statRow}>
            <Text style={styles.statLabel}>Precisión general:</Text>
            <Text style={styles.statValue}>{accuracy.toFixed(1)}%</Text>
          </View>
        </View>

        {/* Progreso visual */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Progreso visual</Text>
          
          <View style={styles.progressItem}>
            <Text style={styles.progressLabel}>Promedio de aciertos</Text>
            <View style={styles.progressBarContainer}>
              <View style={styles.progressBar}>
                <View 
                  style={[
                    styles.progressFill, 
                    { 
                      width: `${(stats.averageScore / 5) * 100}%`,
                      backgroundColor: performance.color 
                    }
                  ]} 
                />
              </View>
              <Text style={styles.progressText}>
                {stats.averageScore ? stats.averageScore.toFixed(1) : '0.0'}/5
              </Text>
            </View>
          </View>

          <View style={styles.progressItem}>
            <Text style={styles.progressLabel}>Precisión general</Text>
            <View style={styles.progressBarContainer}>
              <View style={styles.progressBar}>
                <View 
                  style={[
                    styles.progressFill, 
                    { 
                      width: `${accuracy}%`,
                      backgroundColor: accuracy >= 70 ? '#27AE60' : accuracy >= 50 ? '#F39C12' : '#E74C3C'
                    }
                  ]} 
                />
              </View>
              <Text style={styles.progressText}>{accuracy.toFixed(1)}%</Text>
            </View>
          </View>
        </View>

        {/* Estado de donación */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Estado de la cuenta</Text>
          <View style={styles.donationStatus}>
            {stats.hasUserDonated ? (
              <>
                <Text style={styles.donationEmoji}>✨</Text>
                <Text style={styles.donationText}>¡Gracias por tu donación!</Text>
                <Text style={styles.donationSubtext}>Disfrutas de la versión sin anuncios</Text>
              </>
            ) : (
              <>
                <Text style={styles.donationEmoji}>💝</Text>
                <Text style={styles.donationText}>Considera hacer una donación</Text>
                <Text style={styles.donationSubtext}>Apoya el desarrollo y elimina los anuncios</Text>
              </>
            )}
          </View>
        </View>

        {/* Botones de acción */}
        <View style={styles.actionButtons}>
          <TouchableOpacity style={styles.playButton} onPress={() => navigation.navigate('Game')}>
            <Text style={styles.playButtonText}>Jugar nueva ronda</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.resetButton} onPress={handleResetStats}>
            <Text style={styles.resetButtonText}>Reiniciar estadísticas</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.bottomPadding} />
      </ScrollView>
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
  scrollView: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 24,
    paddingBottom: 16,
  },
  backButton: {
    marginRight: 16,
  },
  backButtonText: {
    fontSize: 16,
    color: '#4A90E2',
    fontWeight: '500',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2C3E50',
  },
  summaryCard: {
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 24,
    marginHorizontal: 24,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  card: {
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 24,
    marginHorizontal: 24,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  cardTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2C3E50',
    marginBottom: 20,
    textAlign: 'center',
  },
  summaryGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  summaryItem: {
    alignItems: 'center',
  },
  summaryNumber: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#4A90E2',
    marginBottom: 4,
  },
  summaryLabel: {
    fontSize: 14,
    color: '#7F8C8D',
    textAlign: 'center',
  },
  performanceContainer: {
    alignItems: 'center',
    marginBottom: 24,
  },
  performanceEmoji: {
    fontSize: 48,
    marginBottom: 8,
  },
  performanceLevel: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  statRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  statLabel: {
    fontSize: 16,
    color: '#7F8C8D',
  },
  statValue: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2C3E50',
  },
  progressItem: {
    marginBottom: 20,
  },
  progressLabel: {
    fontSize: 16,
    color: '#7F8C8D',
    marginBottom: 8,
  },
  progressBarContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  progressBar: {
    flex: 1,
    height: 12,
    backgroundColor: '#E9ECEF',
    borderRadius: 6,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    borderRadius: 6,
  },
  progressText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2C3E50',
    minWidth: 50,
  },
  donationStatus: {
    alignItems: 'center',
  },
  donationEmoji: {
    fontSize: 48,
    marginBottom: 12,
  },
  donationText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2C3E50',
    marginBottom: 4,
  },
  donationSubtext: {
    fontSize: 14,
    color: '#7F8C8D',
    textAlign: 'center',
  },
  actionButtons: {
    paddingHorizontal: 24,
    gap: 12,
  },
  playButton: {
    backgroundColor: '#4A90E2',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
  },
  playButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: '600',
  },
  resetButton: {
    backgroundColor: 'white',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#E74C3C',
  },
  resetButtonText: {
    color: '#E74C3C',
    fontSize: 16,
    fontWeight: '600',
  },
  bottomPadding: {
    height: 40,
  },
}); 