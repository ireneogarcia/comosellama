export class AdsService {
  private roundsPlayed: number = 0;
  private hasUserDonated: boolean = false;
  private readonly ROUNDS_BETWEEN_ADS = 3;

  setUserDonated(donated: boolean): void {
    this.hasUserDonated = donated;
  }

  hasUserDonated(): boolean {
    return this.hasUserDonated;
  }

  incrementRoundsPlayed(): void {
    this.roundsPlayed++;
  }

  shouldShowAd(): boolean {
    if (this.hasUserDonated) {
      return false;
    }
    return this.roundsPlayed > 0 && this.roundsPlayed % this.ROUNDS_BETWEEN_ADS === 0;
  }

  getRoundsPlayed(): number {
    return this.roundsPlayed;
  }

  resetRoundsCount(): void {
    this.roundsPlayed = 0;
  }

  async showInterstitialAd(): Promise<void> {
    // Simular la carga y muestra de un anuncio intersticial
    return new Promise((resolve) => {
      console.log('Mostrando anuncio intersticial...');
      setTimeout(() => {
        console.log('Anuncio completado');
        resolve();
      }, 2000);
    });
  }
} 