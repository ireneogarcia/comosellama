import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  FlatList,
} from 'react-native';
import { WordCategory } from '../../core/password/WordRepository';

interface CategoryScreenProps {
  navigation: any;
  categories: WordCategory[];
}

export const CategoryScreen: React.FC<CategoryScreenProps> = ({ navigation, categories }) => {
  const handleCategorySelect = (categoryName?: string) => {
    navigation.navigate('Game', { selectedCategory: categoryName });
  };

  const renderCategoryItem = ({ item }: { item: WordCategory }) => (
    <TouchableOpacity
      style={styles.categoryCard}
      onPress={() => handleCategorySelect(item.name)}
    >
      <Text style={styles.categoryTitle}>{item.displayName}</Text>
      <Text style={styles.categoryCount}>{item.words.length} palabras</Text>
      <View style={styles.categoryPreview}>
        {item.words.slice(0, 3).map((word, index) => (
          <Text key={index} style={styles.previewWord}>
            {word}
          </Text>
        ))}
        {item.words.length > 3 && (
          <Text style={styles.previewMore}>...</Text>
        )}
      </View>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.backButtonText}>← Volver</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Elige una categoría</Text>
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Opción de categoría mixta */}
        <TouchableOpacity
          style={[styles.categoryCard, styles.mixedCategory]}
          onPress={() => handleCategorySelect()}
        >
          <Text style={styles.categoryTitle}>🎲 Categoría Mixta</Text>
          <Text style={styles.categoryCount}>Todas las palabras</Text>
          <Text style={styles.categoryDescription}>
            Palabras de todas las categorías mezcladas
          </Text>
        </TouchableOpacity>

        {/* Lista de categorías específicas */}
        <FlatList
          data={categories}
          renderItem={renderCategoryItem}
          keyExtractor={(item) => item.name}
          scrollEnabled={false}
          showsVerticalScrollIndicator={false}
        />

        <View style={styles.bottomPadding} />
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 24,
    paddingBottom: 16,
  },
  backButton: {
    marginRight: 16,
  },
  backButtonText: {
    fontSize: 16,
    color: '#4A90E2',
    fontWeight: '500',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2C3E50',
  },
  content: {
    flex: 1,
    paddingHorizontal: 24,
  },
  categoryCard: {
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 20,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  mixedCategory: {
    borderWidth: 2,
    borderColor: '#4A90E2',
    backgroundColor: '#F0F7FF',
  },
  categoryTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2C3E50',
    marginBottom: 8,
  },
  categoryCount: {
    fontSize: 14,
    color: '#7F8C8D',
    marginBottom: 12,
  },
  categoryDescription: {
    fontSize: 14,
    color: '#7F8C8D',
    fontStyle: 'italic',
  },
  categoryPreview: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  previewWord: {
    fontSize: 12,
    color: '#4A90E2',
    backgroundColor: '#E3F2FD',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  previewMore: {
    fontSize: 12,
    color: '#7F8C8D',
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  bottomPadding: {
    height: 40,
  },
}); 