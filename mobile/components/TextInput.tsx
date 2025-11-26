import React from 'react';
import {
  View,
  TextInput as RNTextInput,
  Text,
  StyleSheet,
  TextInputProps,
} from 'react-native';
import { colors, spacing, borderRadius } from '../styles/theme';

interface TextInputPropsExtended extends TextInputProps {
  label?: string;
  characterCount?: number;
  maxCharacters?: number;
}

export default function TextInput({
  label,
  characterCount,
  maxCharacters,
  style,
  ...props
}: TextInputPropsExtended) {
  return (
    <View style={styles.container}>
      {label && <Text style={styles.label}>{label}</Text>}
      <RNTextInput
        style={[styles.input, style]}
        placeholderTextColor={colors.textTertiary}
        textAlignVertical="top"
        {...props}
      />
      {characterCount !== undefined && (
        <Text style={styles.charCount}>
          {characterCount}
          {maxCharacters ? ` / ${maxCharacters}` : ''} characters
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: spacing.md,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: colors.textSecondary,
    marginBottom: spacing.xs,
  },
  input: {
    backgroundColor: colors.bgPrimary,
    borderWidth: 1,
    borderColor: colors.borderMedium,
    borderRadius: borderRadius.md,
    padding: spacing.md,
    fontSize: 15,
    color: colors.textPrimary,
    minHeight: 150,
  },
  charCount: {
    fontSize: 14,
    color: colors.textTertiary,
    textAlign: 'right',
    marginTop: spacing.xs,
  },
});
