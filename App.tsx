import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import 'react-native-gesture-handler';

// Core services
import { WordRepository } from './src/core/password/WordRepository';
import { RoundService } from './src/core/password/RoundService';
import { AdsService } from './src/core/ads/AdsService';
import { StorageService } from './src/core/storage/StorageService';
import { RoundPloc } from './src/core/presentation/RoundPloc';

// Screens
import { HomeScreen } from './src/ui/screens/HomeScreen';
import { CategoryScreen } from './src/ui/screens/CategoryScreen';
import { GameScreen } from './src/ui/screens/GameScreen';
import { StatsScreen } from './src/ui/screens/StatsScreen';
import { SettingsScreen } from './src/ui/screens/SettingsScreen';
import { TeamSetupScreen } from './src/ui/screens/TeamSetupScreen';
import { TeamResultsScreen } from './src/ui/screens/TeamResultsScreen';
import { TeamTransitionScreen } from './src/ui/screens/TeamTransitionScreen';

const Stack = createStackNavigator();

// Dependency injection setup
const wordRepository = new WordRepository();
const roundService = new RoundService(wordRepository);
const adsService = new AdsService();
const storageService = new StorageService();
const roundPloc = new RoundPloc(roundService, adsService, storageService);

const App: React.FC = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Home"
        screenOptions={{
          headerShown: false,
          gestureEnabled: true,
          cardStyleInterpolator: ({ current, layouts }) => {
            return {
              cardStyle: {
                transform: [
                  {
                    translateX: current.progress.interpolate({
                      inputRange: [0, 1],
                      outputRange: [layouts.screen.width, 0],
                    }),
                  },
                ],
              },
            };
          },
        }}
      >
        <Stack.Screen name="Home">
          {(props) => <HomeScreen {...props} storageService={storageService} />}
        </Stack.Screen>
        
        <Stack.Screen name="Categories">
          {(props) => (
            <CategoryScreen 
              {...props} 
              categories={wordRepository.getCategories()} 
            />
          )}
        </Stack.Screen>
        
        <Stack.Screen name="TeamSetup">
          {(props) => <TeamSetupScreen {...props} />}
        </Stack.Screen>
        
        <Stack.Screen name="TeamTransition">
          {(props) => <TeamTransitionScreen {...props} roundPloc={roundPloc} />}
        </Stack.Screen>
        
        <Stack.Screen name="TeamResults">
          {(props) => <TeamResultsScreen {...props} />}
        </Stack.Screen>
        
        <Stack.Screen name="Game">
          {(props) => <GameScreen {...props} roundPloc={roundPloc} />}
        </Stack.Screen>
        
        <Stack.Screen name="Stats">
          {(props) => <StatsScreen {...props} storageService={storageService} />}
        </Stack.Screen>
        
        <Stack.Screen name="Settings">
          {(props) => <SettingsScreen {...props} storageService={storageService} />}
        </Stack.Screen>
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default App; 