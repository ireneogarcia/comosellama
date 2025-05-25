import { AdsService } from '../../../src/core/ads/AdsService';

describe('AdsService', () => {
  let adsService: AdsService;

  beforeEach(() => {
    adsService = new AdsService();
  });

  describe('donation status', () => {
    it('should start with user not donated', () => {
      expect(adsService.hasUserDonated()).toBe(false);
    });

    it('should update donation status', () => {
      adsService.setUserDonated(true);
      expect(adsService.hasUserDonated()).toBe(true);

      adsService.setUserDonated(false);
      expect(adsService.hasUserDonated()).toBe(false);
    });
  });

  describe('rounds tracking', () => {
    it('should start with 0 rounds played', () => {
      expect(adsService.getRoundsPlayed()).toBe(0);
    });

    it('should increment rounds played', () => {
      adsService.incrementRoundsPlayed();
      expect(adsService.getRoundsPlayed()).toBe(1);

      adsService.incrementRoundsPlayed();
      expect(adsService.getRoundsPlayed()).toBe(2);
    });

    it('should reset rounds count', () => {
      adsService.incrementRoundsPlayed();
      adsService.incrementRoundsPlayed();
      adsService.incrementRoundsPlayed();
      
      expect(adsService.getRoundsPlayed()).toBe(3);
      
      adsService.resetRoundsCount();
      expect(adsService.getRoundsPlayed()).toBe(0);
    });
  });

  describe('shouldShowAd', () => {
    it('should not show ad if user has donated', () => {
      adsService.setUserDonated(true);
      adsService.incrementRoundsPlayed();
      adsService.incrementRoundsPlayed();
      adsService.incrementRoundsPlayed();
      
      expect(adsService.shouldShowAd()).toBe(false);
    });

    it('should not show ad on first round', () => {
      expect(adsService.shouldShowAd()).toBe(false);
    });

    it('should not show ad before 3 rounds', () => {
      adsService.incrementRoundsPlayed();
      expect(adsService.shouldShowAd()).toBe(false);

      adsService.incrementRoundsPlayed();
      expect(adsService.shouldShowAd()).toBe(false);
    });

    it('should show ad every 3 rounds', () => {
      // First 3 rounds
      adsService.incrementRoundsPlayed();
      adsService.incrementRoundsPlayed();
      adsService.incrementRoundsPlayed();
      expect(adsService.shouldShowAd()).toBe(true);

      // Next 3 rounds
      adsService.incrementRoundsPlayed();
      adsService.incrementRoundsPlayed();
      expect(adsService.shouldShowAd()).toBe(false);
      
      adsService.incrementRoundsPlayed();
      expect(adsService.shouldShowAd()).toBe(true);
    });

    it('should not show ad if user donates after playing rounds', () => {
      adsService.incrementRoundsPlayed();
      adsService.incrementRoundsPlayed();
      adsService.incrementRoundsPlayed();
      
      expect(adsService.shouldShowAd()).toBe(true);
      
      adsService.setUserDonated(true);
      expect(adsService.shouldShowAd()).toBe(false);
    });
  });

  describe('showInterstitialAd', () => {
    it('should resolve after showing ad', async () => {
      const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
      
      const promise = adsService.showInterstitialAd();
      
      expect(consoleSpy).toHaveBeenCalledWith('Mostrando anuncio intersticial...');
      
      await promise;
      
      expect(consoleSpy).toHaveBeenCalledWith('Anuncio completado');
      
      consoleSpy.mockRestore();
    });
  });
}); 