# 🍓 HomePod Assistant - Linux Testing Guide

This guide helps you test the HomePod Assistant app on Linux to ensure it works correctly on Raspberry Pi OS.

## 🚀 Quick Start

### **Option 1: WSL2 (Recommended for Windows)**
```bash
# Install WSL2 and Ubuntu
wsl --install

# Launch Ubuntu
wsl -d Ubuntu

# Run the testing script
cd /mnt/c/Users/thoma/Documents/HomePod/homepod_assistant
chmod +x test_linux_setup.sh
./test_linux_setup.sh
```

### **Option 2: Native Linux**
```bash
# Clone the project
git clone <your-repo>
cd homepod_assistant

# Run the testing script
chmod +x test_linux_setup.sh
./test_linux_setup.sh
```

### **Option 3: Docker (Isolated Testing)**
```bash
# Create Docker container
docker run -it --rm -v $(pwd):/app ubuntu:20.04

# Inside container
apt update && apt install -y bash curl git
cd /app
chmod +x test_linux_setup.sh
./test_linux_setup.sh
```

## 🔧 Testing Environment Setup

### **System Requirements**
- **OS**: Ubuntu 20.04+ or Debian 11+
- **Architecture**: x86_64 (for testing), ARM64/ARM32 (for Pi)
- **Memory**: 4GB+ RAM
- **Storage**: 10GB+ free space
- **Display**: X11 or Wayland support

### **Dependencies Installed**
- **Flutter**: Latest stable version
- **System Libraries**: GTK3, X11, ALSA, OpenGL
- **Development Tools**: CMake, GCC, Make
- **Testing Tools**: Valgrind, GDB, strace

## 🧪 Testing Checklist

### **1. Build Testing**
```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Test Linux build
flutter build linux --debug
flutter build linux --release

# Check binary size and dependencies
ls -la build/linux/x64/release/bundle/
ldd build/linux/x64/release/bundle/homepod_assistant
```

### **2. Runtime Testing**
```bash
# Run in debug mode
flutter run -d linux

# Run in release mode
flutter run -d linux --release

# Test with different display configurations
export DISPLAY=:0
flutter run -d linux
```

### **3. Widget Testing**
Test each widget individually:

#### **🌤️ Weather Widget**
- [ ] Loads mock data correctly
- [ ] Displays temperature and conditions
- [ ] Tap to refresh works
- [ ] Animations are smooth

#### **🎵 Spotify Widget**
- [ ] Mock connection established
- [ ] Play/pause button responds
- [ ] Skip buttons work
- [ ] Album art rotation animation

#### **🏠 Smart Home Widget**
- [ ] Mock MQTT connection
- [ ] Device grid displays correctly
- [ ] Tap to toggle devices
- [ ] Connection status indicator

#### **📰 News Widget**
- [ ] Sample news loads
- [ ] Auto-rotation works
- [ ] Navigation arrows function
- [ ] Content transitions smooth

#### **⚙️ Settings Widget**
- [ ] Expand/collapse animation
- [ ] Form fields are accessible
- [ ] Settings save/load correctly
- [ ] Local storage works

### **4. Performance Testing**
```bash
# Monitor system resources
htop
iotop
nethogs

# Profile with Valgrind
valgrind --tool=callgrind build/linux/x64/release/bundle/homepod_assistant

# Check memory usage
ps aux | grep homepod_assistant
```

### **5. Compatibility Testing**
```bash
# Test different screen resolutions
xrandr --output HDMI-1 --mode 1920x1080
xrandr --output HDMI-1 --mode 800x600

# Test audio output
speaker-test -t wav -c 2 -f 1000

# Test network connectivity
ping -c 4 8.8.8.8
```

## 🐛 Common Issues & Solutions

### **Build Issues**
```bash
# Missing dependencies
sudo apt install -y libgtk-3-dev libx11-dev

# CMake version too old
sudo apt install -y cmake3
sudo ln -s /usr/bin/cmake3 /usr/bin/cmake

# Flutter path issues
export PATH="$PATH:$HOME/flutter/bin"
flutter doctor
```

### **Runtime Issues**
```bash
# Display issues
export DISPLAY=:0
xhost +local:

# Audio issues
pulseaudio --start
export PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native

# Permission issues
sudo chmod +x build/linux/x64/release/bundle/homepod_assistant
```

### **Performance Issues**
```bash
# Enable hardware acceleration
export LIBGL_ALWAYS_SOFTWARE=0
export MESA_GL_VERSION_OVERRIDE=3.3

# Reduce animations for testing
export FLUTTER_ANIMATION_SCALE=0.5
```

## 📊 Testing Results Template

```markdown
## Test Results - [Date]

### Environment
- **OS**: Ubuntu 20.04
- **Flutter**: 3.32.5
- **Architecture**: x86_64
- **Display**: 1920x1080

### Build Status
- [ ] Debug build: ✅/❌
- [ ] Release build: ✅/❌
- [ ] Binary size: ___ MB
- [ ] Dependencies: ___ libraries

### Widget Testing
- [ ] Weather: ✅/❌
- [ ] Spotify: ✅/❌
- [ ] Smart Home: ✅/❌
- [ ] News: ✅/❌
- [ ] Settings: ✅/❌

### Performance
- [ ] Startup time: ___ seconds
- [ ] Memory usage: ___ MB
- [ ] CPU usage: ___ %
- [ ] Frame rate: ___ FPS

### Issues Found
1. [Issue description]
2. [Issue description]

### Recommendations
- [Recommendation]
- [Recommendation]
```

## 🎯 Next Steps

After successful Linux testing:

1. **Deploy to Raspberry Pi**
2. **Test on actual Pi hardware**
3. **Optimize for Pi performance**
4. **Set up auto-start on boot**
5. **Configure round display**

## 🔗 Useful Commands

```bash
# Check system info
uname -a
cat /etc/os-release
lscpu

# Check display info
xrandr
xdpyinfo

# Check audio info
aplay -l
pactl list short sinks

# Check network info
ip addr show
nmcli device status

# Monitor system
watch -n 1 'free -h && echo "---" && df -h'
```

---

**Happy testing! 🚀** 