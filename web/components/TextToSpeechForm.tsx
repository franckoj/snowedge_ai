'use client';

import { useState, FormEvent } from 'react';
import styles from './TextToSpeechForm.module.css';

interface TextToSpeechFormProps {
  onAudioGenerated: (audioUrl: string) => void;
}

const VOICE_STYLES = [
  { id: 'F1', name: 'Female', gender: 'female' },
  { id: 'M1', name: 'Male', gender: 'male' },
];

export default function TextToSpeechForm({ onAudioGenerated }: TextToSpeechFormProps) {
  const [text, setText] = useState('');
  const [voiceGender, setVoiceGender] = useState<'female' | 'male'>('female');
  const [quality, setQuality] = useState(5);
  const [speed, setSpeed] = useState(1.05);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setIsLoading(true);

    try {
      const voiceStyle = voiceGender === 'female' ? 'F1' : 'M1';
      
      const formData = new FormData();
      formData.append('text', text);
      formData.append('voice_style', voiceStyle);
      formData.append('total_step', quality.toString());
      formData.append('speed', speed.toString());

      const response = await fetch('http://localhost:8000/api/tts', {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({ detail: 'Unknown error' }));
        throw new Error(errorData.detail || 'Failed to generate speech');
      }

      const audioBlob = await response.blob();
      const audioUrl = URL.createObjectURL(audioBlob);
      onAudioGenerated(audioUrl);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  const characterCount = text.length;
  const maxCharacters = 5000;

  return (
    <form onSubmit={handleSubmit} className={styles.form}>
      <div className={styles.layout}>
        <div className={styles.textArea}>
          <textarea
            className="textarea"
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="Enter text to synthesize..."
            required
            maxLength={maxCharacters}
          />
          <div className={styles.charCount}>
            {characterCount} characters
          </div>
        </div>

        <div className={styles.controls}>
          <div className={styles.controlGroup}>
            <label className={styles.label}>Voice:</label>
            <div className="toggle-group">
              <button
                type="button"
                className={`toggle-btn ${voiceGender === 'female' ? 'active' : ''}`}
                onClick={() => setVoiceGender('female')}
              >
                Female
              </button>
              <button
                type="button"
                className={`toggle-btn ${voiceGender === 'male' ? 'active' : ''}`}
                onClick={() => setVoiceGender('male')}
              >
                Male
              </button>
            </div>
          </div>

          <div className={styles.controlGroup}>
            <div className={styles.labelRow}>
              <label className={styles.label}>Quality (Steps):</label>
              <span className={styles.value}>{quality}</span>
            </div>
            <input
              type="range"
              className="slider"
              min="5"
              max="15"
              step="1"
              value={quality}
              onChange={(e) => setQuality(Number(e.target.value))}
            />
            <div className={styles.sliderLabels}>
              <span className="text-xs">Higher = Better quality, slower inference</span>
            </div>
          </div>

          <div className={styles.controlGroup}>
            <div className={styles.labelRow}>
              <label className={styles.label}>Speech Length:</label>
              <span className={styles.value}>{speed.toFixed(2)}x</span>
            </div>
            <input
              type="range"
              className="slider"
              min="0.9"
              max="1.5"
              step="0.05"
              value={speed}
              onChange={(e) => setSpeed(Number(e.target.value))}
            />
            <div className={styles.sliderLabels}>
              <span className="text-xs">Higher = Longer speech duration</span>
            </div>
          </div>

          {error && (
            <div className={styles.error}>
              ⚠️ {error}
            </div>
          )}

          <button
            type="submit"
            className="btn btn-primary"
            disabled={isLoading || !text.trim()}
            style={{ width: '100%', padding: '0.875rem 1.5rem' }}
          >
            {isLoading ? (
              <>
                <span className="spinner" />
                Generating Speech...
              </>
            ) : (
              'Generate Speech'
            )}
          </button>
        </div>
      </div>
    </form>
  );
}
