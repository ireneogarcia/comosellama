import { WordRepository } from '../../../src/core/password/WordRepository';

describe('WordRepository', () => {
  let wordRepository: WordRepository;

  beforeEach(() => {
    wordRepository = new WordRepository();
  });

  describe('getCategories', () => {
    it('should return all available categories', () => {
      const categories = wordRepository.getCategories();
      
      expect(categories).toHaveLength(7);
      expect(categories.map(cat => cat.name)).toEqual([
        'animals', 'objects', 'food', 'professions', 'sports', 'colors', 'emotions'
      ]);
    });

    it('should return categories with correct structure', () => {
      const categories = wordRepository.getCategories();
      
      categories.forEach(category => {
        expect(category).toHaveProperty('name');
        expect(category).toHaveProperty('displayName');
        expect(category).toHaveProperty('words');
        expect(Array.isArray(category.words)).toBe(true);
        expect(category.words.length).toBeGreaterThan(0);
      });
    });
  });

  describe('getRandomWords', () => {
    it('should return requested number of words', async () => {
      const words = await wordRepository.getRandomWords(5);
      expect(words).toHaveLength(5);
    });

    it('should return words from specific category', async () => {
      const animalWords = await wordRepository.getRandomWords(3, 'animals');
      const categories = wordRepository.getCategories();
      const animalCategory = categories.find(cat => cat.name === 'animals');
      
      expect(animalWords).toHaveLength(3);
      animalWords.forEach(word => {
        expect(animalCategory?.words).toContain(word);
      });
    });

    it('should return mixed words when category does not exist', async () => {
      const words = await wordRepository.getRandomWords(5, 'nonexistent');
      expect(words).toHaveLength(5);
    });

    it('should return mixed words when no category specified', async () => {
      const words = await wordRepository.getRandomWords(5);
      expect(words).toHaveLength(5);
    });
  });

  describe('getWordsForRound', () => {
    it('should return exactly 5 words', async () => {
      const words = await wordRepository.getWordsForRound();
      expect(words).toHaveLength(5);
    });

    it('should return 5 words from specific category', async () => {
      const words = await wordRepository.getWordsForRound('colors');
      const categories = wordRepository.getCategories();
      const colorCategory = categories.find(cat => cat.name === 'colors');
      
      expect(words).toHaveLength(5);
      words.forEach(word => {
        expect(colorCategory?.words).toContain(word);
      });
    });
  });

  describe('category content validation', () => {
    it('should have animals category with expected words', () => {
      const categories = wordRepository.getCategories();
      const animalCategory = categories.find(cat => cat.name === 'animals');
      
      expect(animalCategory?.displayName).toBe('Animales');
      expect(animalCategory?.words).toContain('perro');
      expect(animalCategory?.words).toContain('gato');
      expect(animalCategory?.words).toContain('elefante');
    });

    it('should have food category with expected words', () => {
      const categories = wordRepository.getCategories();
      const foodCategory = categories.find(cat => cat.name === 'food');
      
      expect(foodCategory?.displayName).toBe('Comida');
      expect(foodCategory?.words).toContain('manzana');
      expect(foodCategory?.words).toContain('pizza');
      expect(foodCategory?.words).toContain('café');
    });
  });
}); 