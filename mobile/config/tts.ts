/**
 * Configuration for TTS service
 * 
 * MODE:
 * - 'cloud': Use cloud-hosted FastAPI backend (for production)
 * - 'local': Use local development server
 */

export type TTSMode = 'cloud' | 'local';

interface TTSConfig {
  mode: TTSMode;
  cloudApiUrl?: string;
  localApiUrl?: string;
}

// Configuration
const config: TTSConfig = {
  // Current mode: 'local' for development, 'cloud' for production
  mode: 'local',
  
  // Cloud API URL (deploy your FastAPI backend here)
  cloudApiUrl: 'https://api.snowedge.com',
  
  // Local development URL
  localApiUrl: 'http://192.168.68.108:8000',
};

/**
 * Get the active API URL based on current mode
 */
export function getApiUrl(): string {
  switch (config.mode) {
    case 'cloud':
      return config.cloudApiUrl || 'https://api.snowedge.com';
    
    case 'local':
    default:
      return config.localApiUrl || 'http://192.168.68.108:8000';
  }
}

/**
 * Switch TTS mode (useful for settings screen)
 */
export function setTTSMode(mode: TTSMode) {
  config.mode = mode;
}

/**
 * Get current TTS mode
 */
export function getTTSMode(): TTSMode {
  return config.mode;
}

export default config;
