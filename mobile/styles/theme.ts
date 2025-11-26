// Light theme matching web design
export const colors = {
  // Backgrounds
  bgPrimary: '#ffffff',
  bgSecondary: '#f8f9fa',
  bgTertiary: '#e9ecef',
  
  // Text
  textPrimary: '#212529',
  textSecondary: '#6c757d',
  textTertiary: '#adb5bd',
  
  // Yellow accent
  yellowPrimary: '#ffd60a',
  yellowDark: '#ffc300',
  yellowLight: '#ffef9f',
  
  // Borders
  borderLight: '#dee2e6',
  borderMedium: '#ced4da',
  borderDark: '#adb5bd',
};

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 32,
  xxxl: 48,
};

export const typography = {
  h1: {
    fontSize: 48,
    fontWeight: '600' as const,
    letterSpacing: -0.5,
  },
  h2: {
    fontSize: 32,
    fontWeight: '500' as const,
  },
  h3: {
    fontSize: 24,
    fontWeight: '500' as const,
  },
  body: {
    fontSize: 16,
    lineHeight: 24,
  },
  bodySmall: {
    fontSize: 14,
    lineHeight: 20,
  },
  caption: {
    fontSize: 12,
    lineHeight: 16,
  },
};

export const borderRadius = {
  sm: 6,
  md: 8,
  lg: 12,
  xl: 16,
  full: 9999,
};

export const shadows = {
  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 6,
    elevation: 3,
  },
  lg: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.1,
    shadowRadius: 15,
    elevation: 5,
  },
};
