import { Round } from '../../../src/core/password/Round';

describe('Round', () => {
  const testWords = ['perro', 'gato', 'casa', 'árbol', 'agua'];

  describe('constructor', () => {
    it('should create a round with 5 words', () => {
      const round = new Round(testWords);
      expect(round.getWords()).toEqual(testWords);
      expect(round.getCurrentIndex()).toBe(0);
      expect(round.isCompleted()).toBe(false);
    });

    it('should throw error if not exactly 5 words', () => {
      expect(() => new Round(['word1', 'word2'])).toThrow('Una ronda debe tener exactamente 5 palabras');
      expect(() => new Round(['word1', 'word2', 'word3', 'word4', 'word5', 'word6'])).toThrow('Una ronda debe tener exactamente 5 palabras');
    });
  });

  describe('getCurrentWord', () => {
    it('should return the first word initially', () => {
      const round = new Round(testWords);
      expect(round.getCurrentWord()).toBe('perro');
    });

    it('should return the correct word after marking previous words', () => {
      const round = new Round(testWords);
      round.markCurrentWord(true);
      expect(round.getCurrentWord()).toBe('gato');
      
      round.markCurrentWord(false);
      expect(round.getCurrentWord()).toBe('casa');
    });
  });

  describe('markCurrentWord', () => {
    it('should mark word as correct and advance index', () => {
      const round = new Round(testWords);
      round.markCurrentWord(true);
      
      expect(round.getCurrentIndex()).toBe(1);
      expect(round.getResults()[0]).toBe(true);
    });

    it('should mark word as incorrect and advance index', () => {
      const round = new Round(testWords);
      round.markCurrentWord(false);
      
      expect(round.getCurrentIndex()).toBe(1);
      expect(round.getResults()[0]).toBe(false);
    });

    it('should not advance beyond the last word', () => {
      const round = new Round(testWords);
      
      // Mark all 5 words
      for (let i = 0; i < 5; i++) {
        round.markCurrentWord(true);
      }
      
      expect(round.getCurrentIndex()).toBe(5);
      expect(round.isCompleted()).toBe(true);
      
      // Try to mark another word
      round.markCurrentWord(true);
      expect(round.getCurrentIndex()).toBe(5); // Should not advance further
    });
  });

  describe('getScore', () => {
    it('should return 0 initially', () => {
      const round = new Round(testWords);
      expect(round.getScore()).toBe(0);
    });

    it('should return correct score after marking words', () => {
      const round = new Round(testWords);
      
      round.markCurrentWord(true);  // 1 correct
      round.markCurrentWord(false); // 1 incorrect
      round.markCurrentWord(true);  // 2 correct
      
      expect(round.getScore()).toBe(2);
    });

    it('should return 5 for perfect score', () => {
      const round = new Round(testWords);
      
      for (let i = 0; i < 5; i++) {
        round.markCurrentWord(true);
      }
      
      expect(round.getScore()).toBe(5);
    });
  });

  describe('reset', () => {
    it('should reset the round to initial state', () => {
      const round = new Round(testWords);
      
      // Mark some words
      round.markCurrentWord(true);
      round.markCurrentWord(false);
      round.markCurrentWord(true);
      
      // Reset
      round.reset();
      
      expect(round.getCurrentIndex()).toBe(0);
      expect(round.getScore()).toBe(0);
      expect(round.isCompleted()).toBe(false);
      expect(round.getCurrentWord()).toBe('perro');
      expect(round.getResults()).toEqual([false, false, false, false, false]);
    });
  });

  describe('isCompleted', () => {
    it('should return false initially', () => {
      const round = new Round(testWords);
      expect(round.isCompleted()).toBe(false);
    });

    it('should return true after marking all words', () => {
      const round = new Round(testWords);
      
      for (let i = 0; i < 5; i++) {
        round.markCurrentWord(i % 2 === 0); // Alternate correct/incorrect
      }
      
      expect(round.isCompleted()).toBe(true);
    });
  });
}); 