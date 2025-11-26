import React, { useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import HomeScreen from './screens/HomeScreen';
import TTSScreen from './screens/TTSScreen';

type Screen = 'home' | 'tts' | 'image' | 'video';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('home');

  const handleNavigate = (screen: 'tts' | 'image' | 'video') => {
    setCurrentScreen(screen);
  };

  const handleBack = () => {
    setCurrentScreen('home');
  };

  if (currentScreen === 'home') {
    return <HomeScreen onNavigate={handleNavigate} />;
  }

  if (currentScreen === 'tts') {
    return <TTSScreen onBack={handleBack} />;
  }

  // Placeholder for future screens
  return <HomeScreen onNavigate={handleNavigate} />;
}
