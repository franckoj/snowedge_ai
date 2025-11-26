import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Animated } from 'react-native';
import { colors, spacing, borderRadius } from '../styles/theme';

interface VoiceSelectorProps {
  selectedGender: 'female' | 'male';
  onSelect: (gender: 'female' | 'male') => void;
}

export default function VoiceSelector({ selectedGender, onSelect }: VoiceSelectorProps) {
  const scaleAnim = React.useRef(new Animated.Value(1)).current;

  const handlePress = (gender: 'female' | 'male') => {
    // Scale animation on press
    Animated.sequence([
      Animated.timing(scaleAnim, {
        toValue: 0.98,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.timing(scaleAnim, {
        toValue: 1,
        duration: 100,
        useNativeDriver: true,
      }),
    ]).start();

    onSelect(gender);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.label}>Voice:</Text>
      <View style={styles.toggleGroup}>
        <TouchableOpacity
          style={[
            styles.toggleBtn,
            styles.toggleBtnLeft,
            selectedGender === 'female' && styles.toggleBtnActive,
          ]}
          onPress={() => handlePress('female')}
          activeOpacity={0.7}
        >
          <Text
            style={[
              styles.toggleText,
              selectedGender === 'female' && styles.toggleTextActive,
            ]}
          >
            Female
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[
            styles.toggleBtn,
            styles.toggleBtnRight,
            selectedGender === 'male' && styles.toggleBtnActive,
          ]}
          onPress={() => handlePress('male')}
          activeOpacity={0.7}
        >
          <Text
            style={[
              styles.toggleText,
              selectedGender === 'male' && styles.toggleTextActive,
            ]}
          >
            Male
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: spacing.lg,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: colors.textSecondary,
    marginBottom: spacing.sm,
  },
  toggleGroup: {
    flexDirection: 'row',
    borderWidth: 1,
    borderColor: colors.borderMedium,
    borderRadius: borderRadius.md,
    overflow: 'hidden',
    backgroundColor: colors.bgPrimary,
  },
  toggleBtn: {
    flex: 1,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.lg,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'transparent',
  },
  toggleBtnLeft: {
    borderRightWidth: 1,
    borderRightColor: colors.borderLight,
  },
  toggleBtnRight: {},
  toggleBtnActive: {
    backgroundColor: colors.textPrimary,
  },
  toggleText: {
    fontSize: 14,
    fontWeight: '500',
    color: colors.textSecondary,
  },
  toggleTextActive: {
    color: colors.bgPrimary,
  },
});
