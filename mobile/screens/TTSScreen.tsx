import React, { useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  ScrollView,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaView } from 'react-native-safe-area-context';
import VoiceSelector from '../components/VoiceSelector';
import QualitySlider from '../components/QualitySlider';
import AudioPlayer from '../components/AudioPlayer';
import TextInput from '../components/TextInput';
import GenerateButton from '../components/GenerateButton';
import BackButton from '../components/BackButton';
import { ttsService } from '../services/tts';
import { colors, spacing, borderRadius, shadows } from '../styles/theme';

interface TTSScreenProps {
  onBack: () => void;
}

export default function TTSScreen({ onBack }: TTSScreenProps) {
  const [text, setText] = useState('');
  const [voiceGender, setVoiceGender] = useState<'female' | 'male'>('female');
  const [quality, setQuality] = useState(5);
  const [speed, setSpeed] = useState(1.05);
  const [isLoading, setIsLoading] = useState(false);
  const [audioUri, setAudioUri] = useState<string | null>(null);

  const handleGenerate = async () => {
    if (!text.trim()) {
      Alert.alert('Error', 'Please enter some text');
      return;
    }

    if (text.length > 5000) {
      Alert.alert('Error', 'Text is too long (max 5000 characters)');
      return;
    }

    setIsLoading(true);
    setAudioUri(null);

    try {
      const voiceStyle = voiceGender === 'female' ? 'F1' : 'M1';
      
      const audioBlob = await ttsService.generateSpeech({
        text,
        voice_style: voiceStyle,
        total_step: quality,
        speed,
      });

      const dataUri = await ttsService.saveAudioToFile(audioBlob);
      setAudioUri(dataUri);
    } catch (error: any) {
      console.error('TTS Error:', error);
      Alert.alert(
        'Generation Failed',
        error.response?.data?.detail || error.message || 'Failed to generate speech'
      );
    } finally {
      setIsLoading(false);
    }
  };

  const characterCount = text.length;
  const maxCharacters = 5000;

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <KeyboardAvoidingView
        style={styles.container}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        <StatusBar style="dark" />
      
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Back Button */}
        <BackButton onPress={onBack} />
        
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Text to Speech</Text>
        </View>

        {/* Section Labels */}
        <View style={styles.sectionLabels}>
          <Text style={styles.sectionTitle}>Text</Text>
          <Text style={styles.sectionTitle}>Speech</Text>
        </View>

        {/* Main Card */}
        <View style={styles.card}>
          {/* Text Input */}
          <View style={styles.section}>
            <TextInput
              value={text}
              onChangeText={setText}
              placeholder="Enter text to synthesize..."
              multiline
              maxLength={maxCharacters}
              characterCount={characterCount}
            />
          </View>

          {/* Controls */}
          <View style={styles.section}>
            <VoiceSelector selectedGender={voiceGender} onSelect={setVoiceGender} />
            <QualitySlider
              quality={quality}
              speed={speed}
              onQualityChange={setQuality}
              onSpeedChange={setSpeed}
            />

            <GenerateButton
              onPress={handleGenerate}
              isLoading={isLoading}
              disabled={isLoading || !text.trim()}
              style={styles.generateButton}
            />
          </View>
        </View>

        {/* Audio Player */}
        {audioUri && <AudioPlayer audioUri={audioUri} />}
      </ScrollView>
    </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.bgSecondary,
  },
  container: {
    flex: 1,
    backgroundColor: colors.bgSecondary,
  },
  scrollContent: {
    padding: spacing.xxl,
  },
  header: {
    marginTop: spacing.xxxl,
    marginBottom: spacing.xxl,
  },
  title: {
    fontSize: 28,
    fontWeight: '400',
    color: colors.textPrimary,
    letterSpacing: -0.5,
    textAlign: 'center',
    lineHeight: 36,
  },
  sectionLabels: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: spacing.xl,
    paddingBottom: spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: colors.borderLight,
  },
  sectionTitle: {
    fontSize: 32,
    fontWeight: '600',
    color: colors.textPrimary,
    letterSpacing: -0.5,
  },
  card: {
    backgroundColor: colors.bgPrimary,
    borderRadius: borderRadius.lg,
    borderWidth: 1,
    borderColor: colors.borderLight,
    padding: spacing.xl,
    ...shadows.sm,
  },
  section: {
    marginBottom: spacing.xl,
  },
  generateButton: {
    marginTop: spacing.lg,
  },
});
