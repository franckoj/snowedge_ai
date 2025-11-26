"""
FastAPI backend for Supertonic TTS
Uses official Supertonic helper classes for inference
"""

import io
import os
from pathlib import Path

import soundfile as sf
from fastapi import FastAPI, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response

# Import official Supertonic helper functions
from helper import load_text_to_speech, load_voice_style, Style


# Initialize FastAPI app
app = FastAPI(
    title="Supertonic TTS API",
    description="Lightning-fast text-to-speech API using Supertonic ONNX models",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:3001"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Model paths
ASSETS_DIR = Path(__file__).parent / "assets"
ONNX_DIR = ASSETS_DIR / "onnx"
VOICE_STYLES_DIR = ASSETS_DIR / "voice_styles"

# Global TTS model
text_to_speech = None
voice_styles_cache = {}


def load_models():
    """Load ONNX models into memory using official helper"""
    global text_to_speech
    
    if not ASSETS_DIR.exists():
        raise RuntimeError(
            f"Assets directory not found at {ASSETS_DIR}. "
            "Please run setup.sh to download the models."
        )
    
    print("🔄 Loading ONNX models...")
    
    # Use official loader - it handles everything
    text_to_speech = load_text_to_speech(str(ONNX_DIR), use_gpu=False)
    
    print("✅ Models loaded successfully!")


@app.on_event("startup")
async def startup_event():
    """Load models when the API starts"""
    load_models()


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "message": "Supertonic TTS API is running",
        "status": "healthy",
        "models_loaded": text_to_speech is not None
    }


@app.post("/api/tts")
async def text_to_speech_endpoint(
    text: str = Form(...),
    voice_style: str = Form(default="M1"),
    total_step: int = Form(default=5, ge=1, le=20),
    speed: float = Form(default=1.05, ge=0.5, le=2.0)
):
    """
    Convert text to speech using official Supertonic implementation
    
    Parameters:
    - text: Input text to synthesize
    - voice_style: Voice style (M1, M2, F1, F2)
    - total_step: Number of denoising steps (1-20, default: 5)
    - speed: Speech speed multiplier (0.5-2.0, default: 1.05)
    
    Returns:
    - WAV audio file
    """
    try:
        # Validate inputs
        if not text or len(text.strip()) == 0:
            raise HTTPException(status_code=400, detail="Text cannot be empty")
        
        if len(text) > 5000:
            raise HTTPException(
                status_code=400,
                detail="Text is too long (max 5000 characters)"
            )
        
        # Load voice style (cache for performance)
        style_path = str(VOICE_STYLES_DIR / f"{voice_style}.json")
        
        if not os.path.exists(style_path):
            raise HTTPException(
                status_code=400,
                detail=f"Voice style '{voice_style}' not found. Available: M1, M2, F1, F2"
            )
        
        # Load or get cached style
        if voice_style not in voice_styles_cache:
            print(f"📥 Loading voice style: {voice_style}")
            voice_styles_cache[voice_style] = load_voice_style([style_path], verbose=False)
        
        style = voice_styles_cache[voice_style]
        
        print(f"🎙️  Synthesizing: {text[:50]}...")
        
        # Use official TextToSpeech implementation
        # This handles chunking, preprocessing, and everything
        wav, duration = text_to_speech(text, style, total_step, speed)
        
        # Trim to actual duration
        audio_trimmed = wav[0, : int(text_to_speech.sample_rate * duration[0].item())]
        
        # Convert to WAV format
        buffer = io.BytesIO()
        sf.write(buffer, audio_trimmed, text_to_speech.sample_rate, format='WAV')
        buffer.seek(0)
        
        print(f"✅ Generated {duration[0].item():.2f}s of audio")
        
        return Response(
            content=buffer.getvalue(),
            media_type="audio/wav",
            headers={
                "Content-Disposition": "attachment; filename=speech.wav"
            }
        )
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error during synthesis: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Synthesis failed: {str(e)}")


@app.get("/api/voices")
async def list_voices():
    """Get list of available voice styles"""
    if not VOICE_STYLES_DIR.exists():
        return {"voices": []}
    
    voices = []
    for file in VOICE_STYLES_DIR.glob("*.json"):
        voice_name = file.stem
        voices.append({
            "id": voice_name,
            "name": voice_name.upper(),
            "gender": "Male" if voice_name.startswith("M") else "Female"
        })
    
    return {"voices": voices}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
