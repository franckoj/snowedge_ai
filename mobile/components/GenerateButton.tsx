import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  ViewStyle,
} from 'react-native';
import { colors, spacing, borderRadius, shadows } from '../styles/theme';

interface GenerateButtonProps {
  onPress: () => void;
  isLoading: boolean;
  disabled?: boolean;
  style?: ViewStyle;
}

export default function GenerateButton({
  onPress,
  isLoading,
  disabled,
  style,
}: GenerateButtonProps) {
  return (
    <TouchableOpacity
      style={[
        styles.button,
        disabled && styles.buttonDisabled,
        style,
      ]}
      onPress={onPress}
      disabled={disabled}
      activeOpacity={0.8}
    >
      {isLoading ? (
        <>
          <ActivityIndicator size="small" color={colors.textPrimary} />
          <Text style={styles.text}>Generating Speech...</Text>
        </>
      ) : (
        <Text style={styles.text}>Generate Speech</Text>
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  button: {
    backgroundColor: colors.yellowPrimary,
    paddingVertical: spacing.lg,
    borderRadius: borderRadius.md,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    gap: spacing.sm,
    ...shadows.md,
  },
  buttonDisabled: {
    opacity: 0.5,
    ...shadows.sm,
  },
  text: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.textPrimary,
  },
});
