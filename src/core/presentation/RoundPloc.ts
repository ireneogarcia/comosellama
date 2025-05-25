import { Round } from '../password/Round';
import { RoundService } from '../password/RoundService';
import { AdsService } from '../ads/AdsService';
import { StorageService } from '../storage/StorageService';
import { TeamGame, Team } from '../teams/TeamGame';

export enum GameState {
  LOADING = 'loading',
  PLAYING = 'playing',
  ROUND_COMPLETED = 'round_completed',
  SHOWING_AD = 'showing_ad',
  ERROR = 'error',
  TEAM_GAME_FINISHED = 'team_game_finished',
  TEAM_TRANSITION = 'team_transition',
}

export interface RoundPlocState {
  gameState: GameState;
  currentRound: Round | null;
  currentWord: string;
  currentIndex: number;
  score: number;
  totalRounds: number;
  error: string | null;
  isAdShowing: boolean;
  selectedCategory?: string;
  categoryDisplayName?: string;
  // Propiedades para modo equipos
  gameMode: 'single' | 'teams';
  teamGame?: TeamGame;
  currentTeam?: Team;
  roundNumber?: number;
  maxRounds?: number;
}

export class RoundPloc {
  private state: RoundPlocState;
  private listeners: Array<(state: RoundPlocState) => void> = [];
  
  constructor(
    private roundService: RoundService,
    private adsService: AdsService,
    private storageService: StorageService
  ) {
    this.state = {
      gameState: GameState.LOADING,
      currentRound: null,
      currentWord: '',
      currentIndex: 0,
      score: 0,
      totalRounds: 0,
      error: null,
      isAdShowing: false,
      gameMode: 'single',
    };
  }

  getState(): RoundPlocState {
    return { ...this.state };
  }

  subscribe(listener: (state: RoundPlocState) => void): () => void {
    this.listeners.push(listener);
    return () => {
      const index = this.listeners.indexOf(listener);
      if (index > -1) {
        this.listeners.splice(index, 1);
      }
    };
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this.getState()));
  }

  private updateState(updates: Partial<RoundPlocState>): void {
    this.state = { ...this.state, ...updates };
    this.notifyListeners();
  }

  async initialize(selectedCategory?: string, teams?: Team[], numberOfRounds?: number): Promise<void> {
    try {
      this.updateState({ gameState: GameState.LOADING });
      
      // Cargar estado de donación
      const hasUserDonated = await this.storageService.getUserDonationStatus();
      this.adsService.setUserDonated(hasUserDonated);
      
      // Cargar estadísticas
      const stats = await this.storageService.getGameStats();
      this.updateState({ totalRounds: stats.totalRoundsPlayed });
      
      // Configurar categoría seleccionada
      if (selectedCategory) {
        const categories = this.roundService.getAvailableCategories();
        const category = categories.find(cat => cat.name === selectedCategory);
        this.updateState({
          selectedCategory,
          categoryDisplayName: category?.displayName || 'Categoría Mixta'
        });
      } else {
        this.updateState({
          selectedCategory: undefined,
          categoryDisplayName: 'Categoría Mixta'
        });
      }
      
      // Configurar modo de juego
      if (teams && teams.length >= 2) {
        const rounds = numberOfRounds || 3; // 3 rondas por defecto
        const teamGame = new TeamGame(teams, rounds);
        this.updateState({
          gameMode: 'teams',
          teamGame,
          currentTeam: teamGame.getCurrentTeam(),
          roundNumber: teamGame.getRoundNumber(),
          maxRounds: teamGame.getMaxRounds(),
          gameState: GameState.TEAM_TRANSITION,
        });
      } else {
        this.updateState({
          gameMode: 'single',
          teamGame: undefined,
          currentTeam: undefined,
          roundNumber: undefined,
          maxRounds: undefined,
        });
        
        await this.startNewRound();
      }
    } catch (error) {
      this.updateState({
        gameState: GameState.ERROR,
        error: 'Error al inicializar el juego'
      });
    }
  }

  async startNewRound(): Promise<void> {
    try {
      this.updateState({ gameState: GameState.LOADING });
      
      const round = await this.roundService.createNewRound(this.state.selectedCategory);
      
      this.updateState({
        gameState: GameState.PLAYING,
        currentRound: round,
        currentWord: round.getCurrentWord(),
        currentIndex: round.getCurrentIndex(),
        score: 0,
        error: null,
      });
    } catch (error) {
      this.updateState({
        gameState: GameState.ERROR,
        error: 'Error al crear nueva ronda'
      });
    }
  }

  async markCurrentWord(isCorrect: boolean): Promise<void> {
    if (!this.state.currentRound || this.state.gameState !== GameState.PLAYING) {
      return;
    }

    const round = this.state.currentRound;
    round.markCurrentWord(isCorrect);

    if (round.isCompleted()) {
      const finalScore = round.getScore();
      
      // En modo equipos, agregar puntos al equipo actual
      if (this.state.gameMode === 'teams' && this.state.teamGame) {
        this.state.teamGame.addScoreToCurrentTeam(finalScore);
        
        this.updateState({
          gameState: GameState.ROUND_COMPLETED,
          score: finalScore,
          currentTeam: this.state.teamGame.getCurrentTeam(),
        });
      } else {
        // Modo individual
        await this.storageService.updateStatsAfterRound(finalScore);
        this.adsService.incrementRoundsPlayed();
        
        this.updateState({
          gameState: GameState.ROUND_COMPLETED,
          score: finalScore,
          totalRounds: this.state.totalRounds + 1,
        });

        // Verificar si debe mostrar anuncio
        if (this.adsService.shouldShowAd()) {
          await this.showAd();
        }
      }
    } else {
      this.updateState({
        currentWord: round.getCurrentWord(),
        currentIndex: round.getCurrentIndex(),
      });
    }
  }

  async markWordAtIndex(index: number, isCorrect: boolean): Promise<void> {
    if (!this.state.currentRound || this.state.gameState !== GameState.PLAYING) {
      return;
    }

    const round = this.state.currentRound;
    round.markWordAtIndex(index, isCorrect);

    if (round.isCompleted()) {
      const finalScore = round.getScore();
      
      // En modo equipos, agregar puntos al equipo actual
      if (this.state.gameMode === 'teams' && this.state.teamGame) {
        this.state.teamGame.addScoreToCurrentTeam(finalScore);
        
        this.updateState({
          gameState: GameState.ROUND_COMPLETED,
          score: finalScore,
          currentTeam: this.state.teamGame.getCurrentTeam(),
        });
      } else {
        // Modo individual
        await this.storageService.updateStatsAfterRound(finalScore);
        this.adsService.incrementRoundsPlayed();
        
        this.updateState({
          gameState: GameState.ROUND_COMPLETED,
          score: finalScore,
          totalRounds: this.state.totalRounds + 1,
        });

        // Verificar si debe mostrar anuncio
        if (this.adsService.shouldShowAd()) {
          await this.showAd();
        }
      }
    } else {
      // Actualizar el estado para reflejar los cambios
      this.updateState({
        currentWord: round.getCurrentWord(),
        currentIndex: round.getCurrentIndex(),
      });
    }
  }

  async nextTeamTurn(): Promise<void> {
    if (this.state.gameMode !== 'teams' || !this.state.teamGame) {
      return;
    }

    this.state.teamGame.nextTeam();

    if (this.state.teamGame.isGameFinished()) {
      this.updateState({
        gameState: GameState.TEAM_GAME_FINISHED,
        currentTeam: this.state.teamGame.getCurrentTeam(),
        roundNumber: this.state.teamGame.getRoundNumber(),
      });
    } else {
      this.updateState({
        gameState: GameState.TEAM_TRANSITION,
        currentTeam: this.state.teamGame.getCurrentTeam(),
        roundNumber: this.state.teamGame.getRoundNumber(),
      });
    }
  }

  async startTeamRound(): Promise<void> {
    if (this.state.gameMode !== 'teams') {
      return;
    }
    
    await this.startNewRound();
  }

  private async showAd(): Promise<void> {
    this.updateState({
      gameState: GameState.SHOWING_AD,
      isAdShowing: true,
    });

    try {
      await this.adsService.showInterstitialAd();
    } catch (error) {
      console.error('Error al mostrar anuncio:', error);
    } finally {
      this.updateState({
        gameState: GameState.ROUND_COMPLETED,
        isAdShowing: false,
      });
    }
  }

  async setUserDonated(donated: boolean): Promise<void> {
    await this.storageService.setUserDonationStatus(donated);
    this.adsService.setUserDonated(donated);
  }

  getCurrentWords(): string[] {
    return this.state.currentRound?.getWords() || [];
  }

  getCurrentResults(): (boolean | null)[] {
    return this.state.currentRound?.getResults() || [];
  }

  async getGameStats() {
    return await this.storageService.getGameStats();
  }

  getAvailableCategories() {
    return this.roundService.getAvailableCategories();
  }

  // Métodos específicos para modo equipos
  getAllTeams(): Team[] {
    return this.state.teamGame?.getAllTeams() || [];
  }

  getTeamRanking(): Team[] {
    return this.state.teamGame?.getTeamRanking() || [];
  }

  getWinningTeams(): Team[] {
    return this.state.teamGame?.getWinningTeams() || [];
  }
} 