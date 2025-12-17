"""
Snow Edge AI - Quantized INT8 Inference Test
Uses backend helper.py for robust inference with quantized models.
"""

import os
import sys
import time
import soundfile as sf
import io
from pathlib import Path

# Add current directory to path to import helper
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from helper import load_text_to_speech, load_voice_style

# Config
BASE_DIR = Path(__file__).parent
ASSETS_DIR = BASE_DIR / "assets"
ONNX_DIR = ASSETS_DIR / "onnx"
VOICE_STYLES_DIR = ASSETS_DIR / "voice_styles"

TEST_TEXT = (
    "Hello! This is the INT8 offline version of Supertonic speaking. "
    "Everything you hear right now is running fully offline."
)

def main():
    print("="*60)
    print("INT8 QUANTIZED INFERENCE TEST (via helper.py)")
    print("="*60)

    # 1. Load Models
    print("🔄 Loading models...")
    start_load = time.time()
    try:
        # helper.py expects files named *.onnx in the directory
        tts = load_text_to_speech(str(ONNX_DIR), use_gpu=False)
        print(f"✅ Models loaded in {time.time() - start_load:.2f}s")
    except Exception as e:
        print(f"❌ Failed to load models: {e}")
        return

    # 2. Load Voice Style
    voice_name = "M1"
    style_path = VOICE_STYLES_DIR / f"{voice_name}.json"
    if not style_path.exists():
        print(f"❌ Voice style not found: {style_path}")
        return

    print(f"Loading voice: {voice_name}")
    style = load_voice_style([str(style_path)])

    # 3. Run Inference
    print(f"\n🎙️  Synthesizing: '{TEST_TEXT}'")
    start_inf = time.time()
    
    try:
        # Run inference
        wav, duration = tts(
            text=TEST_TEXT,
            style=style,
            total_step=10,  # Standard quality
            speed=1.0
        )
        
        elapsed = time.time() - start_inf
        print(f"✅ Inference complete in {elapsed:.2f}s")
        print(f"   Audio Duration: {duration[0]:.2f}s")
        print(f"   Real-time Factor: {duration[0]/elapsed:.2f}x")

        # 4. Save Output
        out_file = "output_int8_helper.wav"
        
        # Trim to actual duration
        audio_trimmed = wav[0, : int(tts.sample_rate * duration[0])]
        
        sf.write(out_file, audio_trimmed, tts.sample_rate)
        print(f"💾 Saved: {out_file}")
        
    except Exception as e:
        print(f"❌ Inference failed: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
