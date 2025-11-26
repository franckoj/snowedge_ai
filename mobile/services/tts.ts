import axios from 'axios';
import { getApiUrl } from '../config/tts';

// Get API URL from configuration
const API_URL = getApiUrl();

export interface TTSRequest {
  text: string;
  voice_style: 'F1' | 'F2' | 'M1' | 'M2';
  total_step: number;
  speed: number;
}

export interface Voice {
  id: string;
  name: string;
  gender: string;
}

export const ttsService = {
  /**
   * Generate speech from text
   */
  async generateSpeech(params: TTSRequest): Promise<Blob> {
    const formData = new FormData();
    formData.append('text', params.text);
    formData.append('voice_style', params.voice_style);
    formData.append('total_step', params.total_step.toString());
    formData.append('speed', params.speed.toString());

    const response = await axios.post(`${API_URL}/api/tts`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      responseType: 'blob',
    });

    return response.data;
  },

  /**
   * Get list of available voices
   */
  async getVoices(): Promise<Voice[]> {
    const response = await axios.get<{ voices: Voice[] }>(`${API_URL}/api/voices`);
    return response.data.voices;
  },

  /**
   * Save audio blob to local URI
   */
  async saveAudioToFile(blob: Blob): Promise<string> {
    // Convert blob to base64
    const reader = new FileReader();
    
    return new Promise((resolve, reject) => {
      reader.onloadend = () => {
        const base64data = reader.result as string;
        resolve(base64data);
      };
      reader.onerror = reject;
      reader.readAsDataURL(blob);
    });
  },
};
