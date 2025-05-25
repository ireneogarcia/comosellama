export class Round {
  private words: string[];
  private results: (boolean | null)[];
  private currentIndex: number;

  constructor(words: string[]) {
    if (words.length !== 5) {
      throw new Error('Una ronda debe tener exactamente 5 palabras');
    }
    this.words = words;
    this.results = new Array(5).fill(null);
    this.currentIndex = 0;
  }

  getCurrentWord(): string {
    return this.words[this.currentIndex];
  }

  getCurrentIndex(): number {
    return this.currentIndex;
  }

  getWords(): string[] {
    return [...this.words];
  }

  getResults(): (boolean | null)[] {
    return [...this.results];
  }

  markCurrentWord(isCorrect: boolean): void {
    if (this.currentIndex < this.words.length) {
      this.results[this.currentIndex] = isCorrect;
      this.currentIndex++;
    }
  }

  markWordAtIndex(index: number, isCorrect: boolean): void {
    if (index >= 0 && index < this.words.length) {
      this.results[index] = isCorrect;
    }
  }

  isCompleted(): boolean {
    return this.results.every(result => result !== null);
  }

  getScore(): number {
    return this.results.filter(result => result === true).length;
  }

  reset(): void {
    this.results = new Array(5).fill(null);
    this.currentIndex = 0;
  }
} 