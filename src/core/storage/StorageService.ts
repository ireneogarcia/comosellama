import AsyncStorage from '@react-native-async-storage/async-storage';

export interface GameStats {
  totalRoundsPlayed: number;
  totalWordsCorrect: number;
  hasUserDonated: boolean;
  bestScore: number;
  averageScore: number;
}

export class StorageService {
  private static readonly GAME_STATS_KEY = '@deslizas_game_stats';
  private static readonly USER_DONATION_KEY = '@deslizas_user_donated';

  async getGameStats(): Promise<GameStats> {
    try {
      const statsJson = await AsyncStorage.getItem(StorageService.GAME_STATS_KEY);
      if (statsJson) {
        return JSON.parse(statsJson);
      }
    } catch (error) {
      console.error('Error al obtener estadísticas del juego:', error);
    }

    // Valores por defecto
    return {
      totalRoundsPlayed: 0,
      totalWordsCorrect: 0,
      hasUserDonated: false,
      bestScore: 0,
      averageScore: 0,
    };
  }

  async saveGameStats(stats: GameStats): Promise<void> {
    try {
      await AsyncStorage.setItem(StorageService.GAME_STATS_KEY, JSON.stringify(stats));
    } catch (error) {
      console.error('Error al guardar estadísticas del juego:', error);
    }
  }

  async updateStatsAfterRound(score: number): Promise<void> {
    const stats = await this.getGameStats();
    
    stats.totalRoundsPlayed++;
    stats.totalWordsCorrect += score;
    stats.bestScore = Math.max(stats.bestScore, score);
    stats.averageScore = stats.totalWordsCorrect / stats.totalRoundsPlayed;

    await this.saveGameStats(stats);
  }

  async getUserDonationStatus(): Promise<boolean> {
    try {
      const donated = await AsyncStorage.getItem(StorageService.USER_DONATION_KEY);
      return donated === 'true';
    } catch (error) {
      console.error('Error al obtener estado de donación:', error);
      return false;
    }
  }

  async setUserDonationStatus(donated: boolean): Promise<void> {
    try {
      await AsyncStorage.setItem(StorageService.USER_DONATION_KEY, donated.toString());
      
      // También actualizar en las estadísticas
      const stats = await this.getGameStats();
      stats.hasUserDonated = donated;
      await this.saveGameStats(stats);
    } catch (error) {
      console.error('Error al guardar estado de donación:', error);
    }
  }

  async clearAllData(): Promise<void> {
    try {
      await AsyncStorage.multiRemove([
        StorageService.GAME_STATS_KEY,
        StorageService.USER_DONATION_KEY,
      ]);
    } catch (error) {
      console.error('Error al limpiar datos:', error);
    }
  }
} 