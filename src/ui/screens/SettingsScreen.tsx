import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  Switch,
  Alert,
} from 'react-native';
import { StorageService } from '../../core/storage/StorageService';

interface SettingsScreenProps {
  navigation: any;
  storageService: StorageService;
}

interface AppSettings {
  soundEnabled: boolean;
  vibrationEnabled: boolean;
  showWordPreview: boolean;
  autoAdvanceWords: boolean;
}

export const SettingsScreen: React.FC<SettingsScreenProps> = ({ navigation, storageService }) => {
  const [settings, setSettings] = useState<AppSettings>({
    soundEnabled: true,
    vibrationEnabled: true,
    showWordPreview: true,
    autoAdvanceWords: false,
  });

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    // Por ahora usamos valores por defecto, pero podrías implementar
    // persistencia de configuraciones en StorageService
    setSettings({
      soundEnabled: true,
      vibrationEnabled: true,
      showWordPreview: true,
      autoAdvanceWords: false,
    });
  };

  const updateSetting = (key: keyof AppSettings, value: boolean) => {
    setSettings(prev => ({ ...prev, [key]: value }));
    // Aquí podrías guardar la configuración en AsyncStorage
  };

  const handleResetApp = () => {
    Alert.alert(
      'Reiniciar aplicación',
      '¿Estás seguro de que quieres borrar todos los datos de la aplicación? Esto incluye estadísticas, configuraciones y estado de donación.',
      [
        {
          text: 'Cancelar',
          style: 'cancel',
        },
        {
          text: 'Reiniciar',
          style: 'destructive',
          onPress: async () => {
            await storageService.clearAllData();
            Alert.alert(
              'Aplicación reiniciada',
              'Todos los datos han sido borrados. La aplicación se reiniciará.',
              [
                {
                  text: 'OK',
                  onPress: () => navigation.navigate('Home'),
                },
              ]
            );
          },
        },
      ]
    );
  };

  const renderSettingItem = (
    title: string,
    description: string,
    value: boolean,
    onValueChange: (value: boolean) => void,
    disabled: boolean = false
  ) => (
    <View style={[styles.settingItem, disabled && styles.disabledItem]}>
      <View style={styles.settingInfo}>
        <Text style={[styles.settingTitle, disabled && styles.disabledText]}>
          {title}
        </Text>
        <Text style={[styles.settingDescription, disabled && styles.disabledText]}>
          {description}
        </Text>
      </View>
      <Switch
        value={value}
        onValueChange={onValueChange}
        disabled={disabled}
        trackColor={{ false: '#E9ECEF', true: '#4A90E2' }}
        thumbColor={value ? '#FFFFFF' : '#FFFFFF'}
      />
    </View>
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
        <Text style={styles.title}>Configuración</Text>
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Audio y Vibración</Text>
          
          {renderSettingItem(
            'Sonidos',
            'Reproducir efectos de sonido durante el juego',
            settings.soundEnabled,
            (value) => updateSetting('soundEnabled', value),
            true // Deshabilitado por ahora
          )}

          {renderSettingItem(
            'Vibración',
            'Vibrar al deslizar palabras',
            settings.vibrationEnabled,
            (value) => updateSetting('vibrationEnabled', value),
            true // Deshabilitado por ahora
          )}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Experiencia de Juego</Text>
          
          {renderSettingItem(
            'Vista previa de palabras',
            'Mostrar lista de palabras durante el juego',
            settings.showWordPreview,
            (value) => updateSetting('showWordPreview', value)
          )}

          {renderSettingItem(
            'Avance automático',
            'Avanzar automáticamente después de cada palabra',
            settings.autoAdvanceWords,
            (value) => updateSetting('autoAdvanceWords', value),
            true // Deshabilitado por ahora
          )}
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Información</Text>
          
          <View style={styles.infoCard}>
            <Text style={styles.infoTitle}>Deslizas v1.0.0</Text>
            <Text style={styles.infoDescription}>
              El juego de las palabras inspirado en Password
            </Text>
            <Text style={styles.infoDescription}>
              Desarrollado con ❤️ para la comunidad
            </Text>
          </View>
        </View>

        <View style={styles.dangerSection}>
          <TouchableOpacity style={styles.dangerButton} onPress={handleResetApp}>
            <Text style={styles.dangerButtonText}>Reiniciar aplicación</Text>
          </TouchableOpacity>
          <Text style={styles.dangerDescription}>
            Esto borrará todos los datos incluyendo estadísticas y configuraciones
          </Text>
        </View>

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
  section: {
    marginBottom: 32,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2C3E50',
    marginBottom: 16,
  },
  settingItem: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 20,
    marginBottom: 12,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  disabledItem: {
    opacity: 0.5,
  },
  settingInfo: {
    flex: 1,
    marginRight: 16,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#2C3E50',
    marginBottom: 4,
  },
  settingDescription: {
    fontSize: 14,
    color: '#7F8C8D',
    lineHeight: 20,
  },
  disabledText: {
    color: '#BDC3C7',
  },
  infoCard: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  infoTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2C3E50',
    marginBottom: 8,
  },
  infoDescription: {
    fontSize: 14,
    color: '#7F8C8D',
    textAlign: 'center',
    marginBottom: 4,
  },
  dangerSection: {
    marginTop: 20,
    alignItems: 'center',
  },
  dangerButton: {
    backgroundColor: '#E74C3C',
    borderRadius: 12,
    paddingVertical: 16,
    paddingHorizontal: 32,
    marginBottom: 12,
  },
  dangerButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  dangerDescription: {
    fontSize: 12,
    color: '#7F8C8D',
    textAlign: 'center',
    lineHeight: 16,
  },
  bottomPadding: {
    height: 40,
  },
}); 