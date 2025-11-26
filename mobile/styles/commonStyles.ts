import { StyleSheet } from 'react-native';
import { colors, borderRadius, shadows, spacing } from './theme';

export const commonStyles = StyleSheet.create({
  // Cards
  card: {
    backgroundColor: colors.bgPrimary,
    borderRadius: borderRadius.lg,
    borderWidth: 1,
    borderColor: colors.borderLight,
    padding: spacing.lg,
    ...shadows.sm,
  },

  // Buttons
  button: {
    paddingHorizontal: spacing.xl,
    paddingVertical: spacing.md,
    borderRadius: borderRadius.md,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
  },

  buttonPrimary: {
    backgroundColor: colors.yellowPrimary,
  },

  buttonSecondary: {
    backgroundColor: colors.bgTertiary,
    borderWidth: 1,
    borderColor: colors.borderMedium,
  },

  buttonText: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.textPrimary,
  },

  // Text
  title: {
    fontSize: 48,
    fontWeight: '400',
    color: colors.textPrimary,
    letterSpacing: -0.5,
    textAlign: 'center',
  },

  sectionTitle: {
    fontSize: 48,
    fontWeight: '600',
    color: colors.textPrimary,
    letterSpacing: -0.5,
    textAlign: 'center',
  },

  label: {
    fontSize: 14,
    fontWeight: '500',
    color: colors.textSecondary,
    marginBottom: spacing.xs,
  },

  // Input
  input: {
    backgroundColor: colors.bgPrimary,
    borderWidth: 1,
    borderColor: colors.borderMedium,
    borderRadius: borderRadius.md,
    padding: spacing.md,
    fontSize: 15,
    color: colors.textPrimary,
  },

  textArea: {
    minHeight: 150,
    textAlignVertical: 'top',
  },

  // Layout
  container: {
    flex: 1,
    backgroundColor: colors.bgSecondary,
  },

  contentContainer: {
    padding: spacing.xl,
  },

  row: {
    flexDirection: 'row',
    alignItems: 'center',
  },

  spaceBetween: {
    justifyContent: 'space-between',
  },
});
