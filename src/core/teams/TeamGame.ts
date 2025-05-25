export interface Team {
  id: number;
  name: string;
  score: number;
  color: string;
}

export interface TeamGameState {
  teams: Team[];
  currentTeamIndex: number;
  roundNumber: number;
  isGameFinished: boolean;
  maxRounds: number;
}

export class TeamGame {
  private state: TeamGameState;

  constructor(teams: Team[], maxRounds: number = 3) {
    this.state = {
      teams: teams.map(team => ({ ...team, score: 0 })),
      currentTeamIndex: 0,
      roundNumber: 1,
      isGameFinished: false,
      maxRounds,
    };
  }

  getCurrentTeam(): Team {
    return this.state.teams[this.state.currentTeamIndex];
  }

  getAllTeams(): Team[] {
    return [...this.state.teams];
  }

  getCurrentTeamIndex(): number {
    return this.state.currentTeamIndex;
  }

  getRoundNumber(): number {
    return this.state.roundNumber;
  }

  getMaxRounds(): number {
    return this.state.maxRounds;
  }

  isGameFinished(): boolean {
    return this.state.isGameFinished;
  }

  addScoreToCurrentTeam(points: number): void {
    this.state.teams[this.state.currentTeamIndex].score += points;
  }

  nextTeam(): void {
    this.state.currentTeamIndex = (this.state.currentTeamIndex + 1) % this.state.teams.length;
    
    // Si volvemos al primer equipo, incrementamos la ronda
    if (this.state.currentTeamIndex === 0) {
      this.state.roundNumber++;
      
      // Verificar si el juego ha terminado
      if (this.state.roundNumber > this.state.maxRounds) {
        this.state.isGameFinished = true;
      }
    }
  }

  getWinningTeams(): Team[] {
    const maxScore = Math.max(...this.state.teams.map(team => team.score));
    return this.state.teams.filter(team => team.score === maxScore);
  }

  getTeamRanking(): Team[] {
    return [...this.state.teams].sort((a, b) => b.score - a.score);
  }

  reset(): void {
    this.state = {
      teams: this.state.teams.map(team => ({ ...team, score: 0 })),
      currentTeamIndex: 0,
      roundNumber: 1,
      isGameFinished: false,
      maxRounds: this.state.maxRounds,
    };
  }

  getState(): TeamGameState {
    return {
      teams: [...this.state.teams],
      currentTeamIndex: this.state.currentTeamIndex,
      roundNumber: this.state.roundNumber,
      isGameFinished: this.state.isGameFinished,
      maxRounds: this.state.maxRounds,
    };
  }
} 