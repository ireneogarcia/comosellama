import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  TextInput,
  TouchableOpacity,
  Alert,
  ScrollView,
} from 'react-native';

interface TeamSetupScreenProps {
  navigation: any;
  route: any;
}

interface Team {
  id: number;
  name: string;
  score: number;
  color: string;
}

const TEAM_COLORS = [
  '#E74C3C', // Rojo
  '#3498DB', // Azul
  '#27AE60', // Verde
  '#F39C12', // Naranja
  '#9B59B6', // Morado
  '#E67E22', // Naranja oscuro
];

export const TeamSetupScreen: React.FC<TeamSetupScreenProps> = ({ navigation, route }) => {
  // Función para inicializar equipos con nombres previos si están disponibles
  const initializeTeams = (): Team[] => {
    const previousTeams = route.params?.previousTeams;
    
    if (previousTeams && previousTeams.length >= 2) {
      // Usar los equipos previos manteniendo sus nombres y colores
      return previousTeams.map((team: any, index: number) => ({
        id: index + 1,
        name: team.name,
        score: 0, // Resetear puntuación
        color: team.color || TEAM_COLORS[index % TEAM_COLORS.length],
      }));
    }
    
    // Si no hay equipos previos, usar configuración por defecto
    return [
      { id: 1, name: '', score: 0, color: TEAM_COLORS[0] },
      { id: 2, name: '', score: 0, color: TEAM_COLORS[1] },
    ];
  };

  const [teams, setTeams] = useState<Team[]>(initializeTeams());
  const [numberOfRounds, setNumberOfRounds] = useState<number>(
    route.params?.numberOfRounds || 3
  );

  const updateTeamName = (teamId: number, name: string) => {
    setTeams(prevTeams =>
      prevTeams.map(team =>
        team.id === teamId ? { ...team, name } : team
      )
    );
  };

  const addTeam = () => {
    if (teams.length >= 6) {
      Alert.alert('Límite alcanzado', 'Máximo 6 equipos permitidos');
      return;
    }
    
    const newTeam: Team = {
      id: teams.length + 1,
      name: '',
      score: 0,
      color: TEAM_COLORS[teams.length % TEAM_COLORS.length],
    };
    setTeams([...teams, newTeam]);
  };

  const removeTeam = (teamId: number) => {
    if (teams.length <= 2) {
      Alert.alert('Mínimo requerido', 'Se necesitan al menos 2 equipos');
      return;
    }
    
    setTeams(prevTeams => prevTeams.filter(team => team.id !== teamId));
  };

  const startGame = () => {
    const validTeams = teams.filter(team => team.name.trim() !== '');
    
    if (validTeams.length < 2) {
      Alert.alert('Error', 'Se necesitan al menos 2 equipos con nombres válidos');
      return;
    }

    // Navegar al juego con la configuración de equipos
    navigation.navigate('Game', {
      ...route.params,
      teams: validTeams,
      gameMode: 'teams',
      numberOfRounds
    });
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <Text style={styles.title}>Configurar Equipos</Text>
          <Text style={styles.subtitle}>
            Ingresa los nombres de los equipos que van a jugar
          </Text>
        </View>

        <View style={styles.roundsContainer}>
          <Text style={styles.roundsLabel}>Número de rondas:</Text>
          <View style={styles.roundsSelector}>
            {[1, 2, 3, 4, 5].map((rounds) => (
              <TouchableOpacity
                key={rounds}
                style={[
                  styles.roundsButton,
                  numberOfRounds === rounds && styles.roundsButtonSelected
                ]}
                onPress={() => setNumberOfRounds(rounds)}
              >
                <Text style={[
                  styles.roundsButtonText,
                  numberOfRounds === rounds && styles.roundsButtonTextSelected
                ]}>
                  {rounds}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        <View style={styles.teamsContainer}>
          {teams.map((team, index) => (
            <View key={team.id} style={styles.teamCard}>
              <View style={styles.teamHeader}>
                <View style={styles.teamLabelContainer}>
                  <View style={[styles.teamColorIndicator, { backgroundColor: team.color }]} />
                  <Text style={styles.teamLabel}>Equipo {index + 1}</Text>
                </View>
                {teams.length > 2 && (
                  <TouchableOpacity
                    style={styles.removeButton}
                    onPress={() => removeTeam(team.id)}
                  >
                    <Text style={styles.removeButtonText}>✕</Text>
                  </TouchableOpacity>
                )}
              </View>
              
              <TextInput
                style={styles.teamInput}
                placeholder={`Nombre del equipo ${index + 1}`}
                value={team.name}
                onChangeText={(text) => updateTeamName(team.id, text)}
                maxLength={20}
              />
            </View>
          ))}
        </View>

        <View style={styles.actionsContainer}>
          {teams.length < 6 && (
            <TouchableOpacity style={styles.addTeamButton} onPress={addTeam}>
              <Text style={styles.addTeamButtonText}>+ Agregar Equipo</Text>
            </TouchableOpacity>
          )}

          <TouchableOpacity style={styles.startButton} onPress={startGame}>
            <Text style={styles.startButtonText}>Comenzar Juego</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.backButton}
            onPress={() => navigation.goBack()}
          >
            <Text style={styles.backButtonText}>Volver</Text>
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
    marginBottom: 32,
    alignItems: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2C3E50',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#7F8C8D',
    textAlign: 'center',
    lineHeight: 22,
  },
  roundsContainer: {
    marginBottom: 32,
  },
  roundsLabel: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2C3E50',
    marginBottom: 8,
  },
  roundsSelector: {
    flexDirection: 'row',
    gap: 8,
  },
  roundsButton: {
    backgroundColor: '#3498DB',
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
  },
  roundsButtonSelected: {
    backgroundColor: '#27AE60',
  },
  roundsButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  roundsButtonTextSelected: {
    fontWeight: 'bold',
  },
  teamsContainer: {
    marginBottom: 32,
  },
  teamCard: {
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 20,
    marginBottom: 16,
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
  teamHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  teamLabelContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  teamColorIndicator: {
    width: 20,
    height: 20,
    borderRadius: 10,
    marginRight: 8,
  },
  teamLabel: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2C3E50',
  },
  removeButton: {
    width: 30,
    height: 30,
    borderRadius: 15,
    backgroundColor: '#E74C3C',
    justifyContent: 'center',
    alignItems: 'center',
  },
  removeButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  teamInput: {
    borderWidth: 2,
    borderColor: '#E9ECEF',
    borderRadius: 12,
    padding: 16,
    fontSize: 16,
    backgroundColor: '#F8F9FA',
  },
  actionsContainer: {
    gap: 16,
  },
  addTeamButton: {
    backgroundColor: '#3498DB',
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
  },
  addTeamButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  startButton: {
    backgroundColor: '#27AE60',
    borderRadius: 12,
    padding: 20,
    alignItems: 'center',
  },
  startButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  backButton: {
    backgroundColor: '#95A5A6',
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
  },
  backButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
}); 