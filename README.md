# Snow Edge - AI Creative Tools Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A unified platform for AI-powered creative tools including text-to-speech, image generation, and video creation.

## 🎯 Features

### Text-to-Speech (Active)
- 🎙️ Natural-sounding speech synthesis
- 🎨 Multiple voice styles (M1, M2, F1, F2)
- ⚡ 167× faster than real-time
- 🎛️ Quality and speed controls
- 📱 Web and mobile apps

### Coming Soon
- 🖼️ Image Creation
- 🎬 Video Generation

## 📁 Project Structure

```
snowedge_ai/
├── backend/    # Python FastAPI server
├── web/        # Next.js browser app
└── mobile/     # React Native iOS/Android
```

## 🚀 Quick Start

### Backend
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
./setup.sh  # Download models (one-time)
python main.py
```

### Web App
```bash
cd web
npm install
npm run dev
# Open http://localhost:3000
```

### Mobile App
```bash
cd mobile
npm install
npx expo start
# Scan QR code with Expo Go
```

## 🛠️ Tech Stack

- **Backend**: Python, FastAPI, ONNX Runtime
- **Web**: Next.js 15, React 19, TypeScript
- **Mobile**: React Native, Expo
- **AI**: Supertonic TTS (official implementation)

## 📱 Mobile App

**Snow Edge** mobile app features:
- Landing page with feature cards
- Text-to-Speech interface
- Native iOS and Android support
- Cloud-based architecture

## 🌐 Deployment

### Backend
Deploy to Railway, Render, or DigitalOcean:
```bash
# Update mobile/config/tts.ts with your URL
cloudApiUrl: 'https://your-api.com'
```

### Mobile
```bash
cd mobile
eas build --platform all
```

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- [Supertonic](https://github.com/supertone-inc/supertonic) - Official TTS implementation
- [ONNX Runtime](https://onnxruntime.ai/) - High-performance inference

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

---

**Built with ❤️ using cutting-edge AI technology**
