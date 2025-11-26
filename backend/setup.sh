#!/bin/bash

# Supertonic Assets Setup Script
# This script downloads the ONNX models and voice styles from HuggingFace

set -e

echo "🚀 Setting up Supertonic TTS assets..."

# Check if Git LFS is installed
if ! command -v git-lfs &> /dev/null; then
    echo "⚠️  Git LFS is not installed."
    echo "📦 Installing Git LFS..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install git-lfs
        else
            echo "❌ Homebrew not found. Please install Git LFS manually:"
            echo "   Visit: https://git-lfs.com"
            exit 1
        fi
    else
        echo "❌ Please install Git LFS manually:"
        echo "   Visit: https://git-lfs.com"
        exit 1
    fi
fi

# Initialize Git LFS
echo "🔧 Initializing Git LFS..."
git lfs install

# Clone the Supertonic assets if not already present
if [ -d "assets" ]; then
    echo "📁 Assets directory already exists. Pulling latest changes..."
    cd assets
    git pull
    cd ..
else
    echo "📥 Cloning Supertonic assets from HuggingFace..."
    git clone https://huggingface.co/Supertone/supertonic assets
fi

# Verify the assets are downloaded
if [ -d "assets/voice_styles" ] && [ -f "assets/tts_text_encoder.onnx" ]; then
    echo "✅ Assets successfully downloaded!"
    echo ""
    echo "📂 Available voice styles:"
    ls -1 assets/voice_styles/
    echo ""
    echo "🎉 Setup complete! You can now run the backend."
else
    echo "❌ Asset download failed. Please check your internet connection and try again."
    exit 1
fi
