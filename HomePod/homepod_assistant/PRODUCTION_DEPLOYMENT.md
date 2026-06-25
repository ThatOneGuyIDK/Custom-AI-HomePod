# Production Deployment Guide

## Option 1: Native Linux App (RECOMMENDED)

### Why Native Over Web:
- ✅ Direct microphone access (no browser limitations)
- ✅ Offline speech recognition possible
- ✅ Better performance
- ✅ No HTTPS/CORS issues
- ✅ Full system integration

### Step 1: Build for Linux
```bash
# On development machine
flutter config --enable-linux-desktop
flutter build linux --release

# Transfer to Raspberry Pi
scp -r build/linux/x64/release/bundle/ pi@raspberrypi.local:~/homepod_assistant/
```

### Step 2: Install Dependencies on Raspberry Pi
```bash
# Audio system
sudo apt update
sudo apt install -y pulseaudio alsa-utils libasound2-dev

# Speech recognition (offline)
sudo apt install -y espeak espeak-data libespeak-dev
sudo apt install -y pocketsphinx pocketsphinx-utils

# Flutter Linux dependencies
sudo apt install -y libgtk-3-dev libblkid-dev liblzma-dev
```

### Step 3: Configure Audio
```bash
# Test microphone
arecord -l
aplay -l

# Configure PulseAudio
pulseaudio --start
pactl set-default-source 1  # Adjust based on mic index
```

### Step 4: Run Native App
```bash
cd ~/homepod_assistant/bundle
./homepod_assistant
```

---

## Option 2: Web App with Enhanced Speech Recognition

### Implementation Details:

#### A. Direct Web Speech API (Browser Native)
- Uses browser's built-in speech recognition
- Works offline in some browsers
- No external dependencies

#### B. WebRTC-based Solution
- Direct audio capture
- Send to local speech processing server
- Can work entirely offline

#### C. WebAssembly Speech Engine
- Compile speech recognition to WASM
- Run entirely in browser
- Completely offline

---

## Option 3: Hybrid Architecture

### Local Speech Server + Web UI
- Raspberry Pi runs local speech recognition server
- Web UI communicates via WebSocket
- Best of both worlds

### Architecture:
```
[Web UI] ←→ [WebSocket] ←→ [Local Speech Server] ←→ [Microphone]
```

---

## Recommended Production Stack:

### For Raspberry Pi:
1. **Native Flutter Linux App** (primary)
2. **Local Speech Recognition** (Vosk, SpeechRecognition, or OpenAI Whisper)
3. **Direct Audio System Integration**
4. **Offline TTS** (eSpeak or Festival)

### Benefits:
- ✅ Works without internet
- ✅ No browser limitations
- ✅ Better performance
- ✅ Full hardware access
- ✅ Production-ready reliability