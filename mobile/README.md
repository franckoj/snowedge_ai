# Snow Edge AI - Mobile App

React Native mobile application for AI-powered creative tools including text-to-speech.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Update backend URL:
Edit `services/tts.ts` and update `API_URL` with your backend URL.

**Already configured for your network:**
- Current setting: `http://192.168.68.108:8000`
- This matches your computer's local IP address

If your IP changes, find it with:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

## Running the App

### iOS Simulator
```bash
npm run ios
```

To run on a specific simulator (e.g., iPhone 15 Pro):
```bash
npm run ios -- --device "iPhone 15 Pro"
```

### Android Emulator
```bash
npm run android
```

### Expo Go (Quick Testing)
To generate a QR code for your physical device:
```bash
npx expo start
```
Then scan the QR code with the Expo Go app (Android) or Camera app (iOS).

### iOS Simulator
```bash
npm run ios
```

- ✅ Text-to-speech generation
- ✅ Female/Male voice selection
- ✅ Quality control (5-15 steps)
- ✅ Speech speed adjustment
- ✅ Audio playback with progress bar
- ✅ Light theme matching web design
- ✅ Smooth animations and interactions

## Tech Stack

- React Native + Expo
- TypeScript
- expo-av (audio playback)
- axios (API requests)
- @react-native-community/slider

## Configuration

Update `API_URL` in `services/tts.ts` to point to your backend:
- Local: `http://192.168.x.x:8000`
- Production: Your deployed backend URL
