import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { colors, spacing, borderRadius } from '../styles/theme';

interface HomeScreenProps {
  onNavigate: (screen: 'tts' | 'image' | 'video') => void;
}

export default function HomeScreen({ onNavigate }: HomeScreenProps) {
  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <StatusBar style="dark" />
      <ScrollView contentContainerStyle={styles.container}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Snow Edge</Text>
          <Text style={styles.subtitle}>AI-Powered Creative Tools</Text>
        </View>

        {/* Feature Cards */}
        <View style={styles.cardsContainer}>
          {/* Free TTS Card */}
          <TouchableOpacity
            style={[styles.card, styles.cardActive]}
            onPress={() => onNavigate('tts')}
            activeOpacity={0.8}
          >
            <View style={styles.cardHeader}>
              <Text style={styles.cardIcon}>🎙️</Text>
              <View style={styles.badge}>
                <Text style={styles.badgeText}>FREE</Text>
              </View>
            </View>
            <Text style={styles.cardTitle}>Text to Speech</Text>
            <Text style={styles.cardDescription}>
              Convert text to natural-sounding speech with multiple voices
            </Text>
          </TouchableOpacity>

          {/* Image Creation Card */}
          <TouchableOpacity
            style={[styles.card, styles.cardDisabled]}
            activeOpacity={0.6}
            disabled
          >
            <View style={styles.cardHeader}>
              <Text style={styles.cardIcon}>🎨</Text>
              <View style={[styles.badge, styles.badgeComingSoon]}>
                <Text style={styles.badgeText}>SOON</Text>
              </View>
            </View>
            <Text style={styles.cardTitle}>Image Creation</Text>
            <Text style={styles.cardDescription}>
              Generate stunning images from text descriptions
            </Text>
          </TouchableOpacity>

          {/* Video Generation Card */}
          <TouchableOpacity
            style={[styles.card, styles.cardDisabled]}
            activeOpacity={0.6}
            disabled
          >
            <View style={styles.cardHeader}>
              <Text style={styles.cardIcon}>🎬</Text>
              <View style={[styles.badge, styles.badgeComingSoon]}>
                <Text style={styles.badgeText}>SOON</Text>
              </View>
            </View>
            <Text style={styles.cardTitle}>Video Generation</Text>
            <Text style={styles.cardDescription}>
              Create videos from text and images
            </Text>
          </TouchableOpacity>
        </View>

        {/* Footer */}
        <View style={styles.footer}>
          <Text style={styles.footerText}>
            Powered by cutting-edge AI technology
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.bgSecondary,
  },
  container: {
    padding: spacing.xxl,
  },
  header: {
    marginTop: spacing.xxxl,
    marginBottom: spacing.xxxl,
    alignItems: 'center',
  },
  title: {
    fontSize: 56,
    fontWeight: '700',
    color: colors.textPrimary,
    letterSpacing: -1,
    marginBottom: spacing.sm,
  },
  subtitle: {
    fontSize: 18,
    color: colors.textSecondary,
    fontWeight: '400',
  },
  cardsContainer: {
    gap: spacing.lg,
  },
  card: {
    backgroundColor: colors.bgPrimary,
    borderRadius: borderRadius.xl,
    padding: spacing.xl,
    borderWidth: 2,
    borderColor: colors.borderLight,
  },
  cardActive: {
    borderColor: colors.yellowPrimary,
  },
  cardDisabled: {
    opacity: 0.6,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  cardIcon: {
    fontSize: 40,
  },
  badge: {
    backgroundColor: colors.yellowPrimary,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: borderRadius.full,
  },
  badgeComingSoon: {
    backgroundColor: colors.bgTertiary,
  },
  badgeText: {
    fontSize: 12,
    fontWeight: '700',
    color: colors.textPrimary,
  },
  cardTitle: {
    fontSize: 24,
    fontWeight: '600',
    color: colors.textPrimary,
    marginBottom: spacing.xs,
  },
  cardDescription: {
    fontSize: 14,
    color: colors.textSecondary,
    lineHeight: 20,
  },
  footer: {
    marginTop: spacing.xxxl,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 14,
    color: colors.textTertiary,
  },
});
