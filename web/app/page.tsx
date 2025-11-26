'use client';

import { useState } from 'react';
import TextToSpeechForm from '@/components/TextToSpeechForm';
import AudioPlayer from '@/components/AudioPlayer';
import styles from './page.module.css';

export default function Home() {
  const [audioUrl, setAudioUrl] = useState<string | null>(null);

  return (
    <main className={styles.main}>
      <div className="container">
        <header className={styles.header}>
          <h1 className={styles.title}>
            Generate speech directly in your device offline
          </h1>
        </header>

        <div className={`${styles.content} card`}>
          <div className={styles.split}>
            <div className={styles.textSection}>
              <h2 className={styles.sectionTitle}>Text</h2>
            </div>
            
            <div className={styles.speechSection}>
              <h2 className={styles.sectionTitle}>Speech</h2>
            </div>
          </div>

          <div className={styles.formContent}>
            <TextToSpeechForm onAudioGenerated={setAudioUrl} />
          </div>

          {audioUrl && (
            <div className={styles.playerSection}>
              <AudioPlayer audioUrl={audioUrl} />
            </div>
          )}
        </div>

        <footer className={styles.footer}>
          <p className={styles.footerText}>
            Powered by{' '}
            <a 
              href="https://huggingface.co/Supertone/supertonic" 
              target="_blank" 
              rel="noopener noreferrer"
              className={styles.link}
            >
              Supertonic
            </a>
            {' '}• Lightning-fast on-device TTS
          </p>
        </footer>
      </div>
    </main>
  );
}
