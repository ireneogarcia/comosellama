export interface WordCategory {
  name: string;
  displayName: string;
  words: string[];
}

export class WordRepository {
  private categories: WordCategory[] = [
    {
      name: 'animals',
      displayName: 'Animales',
      words: [
        'perro', 'gato', 'elefante', 'león', 'tigre', 'oso', 'lobo', 'zorro', 'conejo', 'ratón',
        'caballo', 'vaca', 'cerdo', 'oveja', 'cabra', 'pollo', 'pato', 'ganso', 'pavo', 'águila',
        'halcón', 'búho', 'cuervo', 'paloma', 'canario', 'loro', 'pingüino', 'delfín', 'ballena', 'tiburón'
      ]
    },
    {
      name: 'objects',
      displayName: 'Objetos',
      words: [
        'mesa', 'silla', 'cama', 'sofá', 'televisión', 'teléfono', 'ordenador', 'libro', 'lápiz', 'papel',
        'coche', 'bicicleta', 'avión', 'barco', 'tren', 'autobús', 'moto', 'camión', 'casa', 'edificio',
        'puerta', 'ventana', 'escalera', 'ascensor', 'puente', 'carretera', 'semáforo', 'parque', 'jardín', 'árbol'
      ]
    },
    {
      name: 'food',
      displayName: 'Comida',
      words: [
        'manzana', 'naranja', 'plátano', 'fresa', 'uva', 'pera', 'melocotón', 'sandía', 'melón', 'piña',
        'pan', 'queso', 'leche', 'huevo', 'carne', 'pescado', 'pollo', 'arroz', 'pasta', 'pizza',
        'hamburguesa', 'ensalada', 'sopa', 'café', 'té', 'agua', 'zumo', 'vino', 'cerveza', 'helado'
      ]
    },
    {
      name: 'professions',
      displayName: 'Profesiones',
      words: [
        'médico', 'profesor', 'ingeniero', 'abogado', 'policía', 'bombero', 'cocinero', 'camarero', 'vendedor', 'conductor',
        'piloto', 'marinero', 'soldado', 'artista', 'músico', 'actor', 'escritor', 'periodista', 'fotógrafo', 'dentista'
      ]
    },
    {
      name: 'sports',
      displayName: 'Deportes',
      words: [
        'fútbol', 'baloncesto', 'tenis', 'natación', 'atletismo', 'ciclismo', 'boxeo', 'golf', 'esquí', 'surf',
        'voleibol', 'balonmano', 'hockey', 'rugby', 'béisbol', 'ping-pong', 'badminton', 'escalada', 'yoga', 'karate'
      ]
    },
    {
      name: 'colors',
      displayName: 'Colores',
      words: [
        'rojo', 'azul', 'verde', 'amarillo', 'naranja', 'morado', 'rosa', 'negro', 'blanco', 'gris',
        'marrón', 'violeta', 'turquesa', 'dorado', 'plateado', 'beige', 'coral', 'índigo', 'magenta', 'cian'
      ]
    },
    {
      name: 'emotions',
      displayName: 'Emociones',
      words: [
        'alegría', 'tristeza', 'miedo', 'ira', 'sorpresa', 'amor', 'odio', 'esperanza', 'nostalgia', 'ansiedad',
        'felicidad', 'melancolía', 'euforia', 'tranquilidad', 'nerviosismo', 'confianza', 'vergüenza', 'orgullo', 'envidia', 'gratitud'
      ]
    }
  ];

  private getAllWords(): string[] {
    return this.categories.flatMap(category => category.words);
  }

  getCategories(): WordCategory[] {
    return [...this.categories];
  }

  async getRandomWords(count: number, categoryName?: string): Promise<string[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        let wordsPool: string[];
        
        if (categoryName) {
          const category = this.categories.find(cat => cat.name === categoryName);
          wordsPool = category ? category.words : this.getAllWords();
        } else {
          wordsPool = this.getAllWords();
        }
        
        const shuffled = [...wordsPool].sort(() => Math.random() - 0.5);
        resolve(shuffled.slice(0, count));
      }, 100);
    });
  }

  async getWordsForRound(categoryName?: string): Promise<string[]> {
    return this.getRandomWords(5, categoryName);
  }
} 