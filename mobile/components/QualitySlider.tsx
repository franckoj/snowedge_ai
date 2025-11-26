import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Slider from '@react-native-community/slider';
import { colors, spacing } from '../styles/theme';

interface QualitySliderProps {
  quality: number;
  speed: number;
  onQualityChange: (value: number) => void;
  onSpeedChange: (value: number) => void;
}

export default function QualitySlider({
  quality,
  speed,
  onQualityChange,
  onSpeedChange,
}: QualitySliderProps) {
  return (
    <View style={styles.container}>
      {/* Quality Slider */}
      <View style={styles.sliderContainer}>
        <View style={styles.labelRow}>
          <Text style={styles.label}>Quality (Steps):</Text>
          <Text style={styles.value}>{quality}</Text>
        </View>
        <Slider
          style={styles.slider}
          minimumValue={5}
          maximumValue={15}
          step={1}
          value={quality}
          onValueChange={onQualityChange}
          minimumTrackTintColor={colors.textPrimary}
          maximumTrackTintColor={colors.bgTertiary}
          thumbTintColor={colors.textPrimary}
        />
        <Text style={styles.hint}>Higher = Better quality, slower inference</Text>
      </View>

      {/* Speed Slider */}
      <View style={styles.sliderContainer}>
        <View style={styles.labelRow}>
          <Text style={styles.label}>Speech Length:</Text>
          <Text style={styles.value}>{speed.toFixed(2)}x</Text>
        </View>
        <Slider
          style={styles.slider}
          minimumValue={0.9}
          maximumValue={1.5}
          step={0.05}
          value={speed}
          onValueChange={onSpeedChange}
          minimumTrackTintColor={colors.textPrimary}
          maximumTrackTintColor={colors.bgTertiary}
          thumbTintColor={colors.textPrimary}
        />
        <Text style={styles.hint}>Higher = Longer speech duration</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    gap: spacing.lg,
  },
  sliderContainer: {
    marginBottom: spacing.md,
  },
  labelRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: colors.textSecondary,
  },
  value: {
    fontSize: 14,
    fontWeight: '500',
    color: colors.textPrimary,
  },
  slider: {
    width: '100%',
    height: 40,
  },
  hint: {
    fontSize: 12,
    color: colors.textTertiary,
    marginTop: spacing.xs,
  },
});
