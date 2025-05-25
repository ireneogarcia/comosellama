import { Round } from './Round';
import { WordRepository } from './WordRepository';

export class RoundService {
  private wordRepository: WordRepository;

  constructor(wordRepository: WordRepository) {
    this.wordRepository = wordRepository;
  }

  async createNewRound(categoryName?: string): Promise<Round> {
    const words = await this.wordRepository.getWordsForRound(categoryName);
    return new Round(words);
  }

  getAvailableCategories() {
    return this.wordRepository.getCategories();
  }
} 