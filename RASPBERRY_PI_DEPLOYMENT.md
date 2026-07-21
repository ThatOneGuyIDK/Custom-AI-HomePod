# 🍓 Raspberry Pi Deployment Guide

## Overview
This guide will help you deploy the HomePod Assistant to a Raspberry Pi with a 6-inch Waveshare round touchscreen display.

## Hardware Requirements

### Required Hardware
- **Raspberry Pi 4** (4GB or 8GB RAM recommended)
- **6-inch Waveshare Round Touchscreen** (model: 6inch Round LCD with Capacitive Touch)
- **MicroSD Card** (32GB+ Class 10)
- **Power Supply** (5V/3A minimum)
- **Case/Enclosure** (optional but recommended)

### Optional Hardware
- **USB Microphone** (for better voice input)
- **USB Speaker** or **Bluetooth Speaker** (for audio output)
- **USB WiFi Adapter** (if using Pi Zero W)
- **Heat Sinks** (for better thermal management)

## Software Setup

### 1. Install Raspberry Pi OS

1. **Download Raspberry Pi OS** (Desktop version with recommended software)
   - Go to https://www.raspberrypi.org/software/
   - Download "Raspberry Pi OS with desktop and recommended software"

2. **Flash to MicroSD Card**
   - Use Raspberry Pi Imager or Balena Etcher
   - Enable SSH during setup
   - Set up WiFi credentials

3. **First Boot Setup**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Enable required interfaces
   sudo raspi-config
   # Enable: SSH, SPI, I2C, Serial
   ```

### 2. Install Flutter on Raspberry Pi

```bash
# Install dependencies
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa

# Download Flutter
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"

# Add to .bashrc
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Install Flutter
flutter doctor
flutter config --enable-linux-desktop
```

### 3. Install Display Drivers

```bash
# Install Waveshare display drivers
sudo apt install -y python3-pip
pip3 install waveshare-lcd

# Configure display (specific to your model)
# Check Waveshare documentation for your specific display model
```

### 4. Install Audio Dependencies

```bash
# Install audio packages
sudo apt install -y pulseaudio pulseaudio-utils
sudo apt install -y alsa-utils
sudo apt install -y libasound2-dev

# Configure audio
sudo usermod -a -G audio $USER
```

## Application Deployment

### 1. Build for Linux

On your development machine:
```bash
# Navigate to project
cd homepod_assistant

# Build for Linux
flutter build linux --release

# The build will be in: build/linux/x64/release/bundle/
```

### 2. Deploy to Raspberry Pi

```bash
# Copy build to Raspberry Pi
scp -r build/linux/x64/release/bundle/ pi@your-pi-ip:/home/pi/homepod_assistant/

# SSH into Raspberry Pi
ssh pi@your-pi-ip

# Make executable
chmod +x /home/pi/homepod_assistant/homepod_assistant
```

### 3. Configure Auto-Start

Create a desktop entry for auto-start:
```bash
# Create desktop entry
cat > ~/.config/autostart/homepod-assistant.desktop << EOF
[Desktop Entry]
Type=Application
Name=HomePod Assistant
Exec=/home/pi/homepod_assistant/homepod_assistant
Terminal=false
X-GNOME-Autostart-enabled=true
EOF
```

## Display Configuration

### 1. Configure for Round Display

Edit `/boot/config.txt`:
```bash
sudo nano /boot/config.txt

# Add these lines for Waveshare display:
dtoverlay=waveshare-6inch-round
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=87
hdmi_cvt=480 480 60 6 0 0 0
```

### 2. Configure Touch Input

```bash
# Install touch calibration tools
sudo apt install -y xinput-calibrator

# Calibrate touch screen
xinput_calibrator

# Save calibration to /etc/X11/xorg.conf.d/99-calibration.conf
```

### 3. Fullscreen Configuration

Create a script to run the app in fullscreen:
```bash
# Create startup script
cat > /home/pi/start_homepod.sh << 'EOF'
#!/bin/bash
export DISPLAY=:0
xset s off
xset -dpms
xset s noblank
/home/pi/homepod_assistant/homepod_assistant
EOF

chmod +x /home/pi/start_homepod.sh
```

## Performance Optimization

### 1. Disable Unnecessary Services

```bash
# Disable services you don't need
sudo systemctl disable bluetooth
sudo systemctl disable avahi-daemon
sudo systemctl disable triggerhappy
```

### 2. GPU Memory Split

Edit `/boot/config.txt`:
```bash
# Increase GPU memory for better graphics performance
gpu_mem=256
```

### 3. CPU Governor

```bash
# Set CPU governor for better performance
echo 'GOVERNOR="performance"' | sudo tee -a /etc/default/cpufrequtils
sudo systemctl enable cpufrequtils
```

## Troubleshooting

### Common Issues

1. **Display Not Working**
   ```bash
   # Check display drivers
   lsmod | grep waveshare
   
   # Check HDMI output
   tvservice -s
   ```

2. **Touch Not Working**
   ```bash
   # Check touch input
   xinput list
   
   # Recalibrate touch
   xinput_calibrator
   ```

3. **Audio Issues**
   ```bash
   # Check audio devices
   aplay -l
   
   # Test audio
   speaker-test -t wav -c 2
   ```

4. **Performance Issues**
   ```bash
   # Monitor system resources
   htop
   
   # Check temperature
   vcgencmd measure_temp
   ```

## Development Workflow

### 1. Remote Development

Set up VS Code for remote development:
1. Install "Remote - SSH" extension
2. Connect to your Raspberry Pi
3. Open the project folder
4. Install Flutter extension on remote

### 2. Hot Reload

For development with hot reload:
```bash
# On Raspberry Pi
cd /home/pi/homepod_assistant
flutter run -d linux
```

### 3. Debugging

```bash
# Enable debug logging
export FLUTTER_LOG_LEVEL=debug
flutter run -d linux --verbose
```

## Security Considerations

### 1. Firewall Configuration

```bash
# Install and configure firewall
sudo apt install -y ufw
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 1883  # MQTT
```

### 2. Regular Updates

```bash
# Set up automatic updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

## Monitoring and Maintenance

### 1. System Monitoring

```bash
# Install monitoring tools
sudo apt install -y htop iotop

# Create monitoring script
cat > /home/pi/monitor.sh << 'EOF'
#!/bin/bash
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "Memory: $(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')"
echo "Temperature: $(vcgencmd measure_temp | cut -d'=' -f2)"
EOF

chmod +x /home/pi/monitor.sh
```

### 2. Log Rotation

```bash
# Configure log rotation for the app
sudo nano /etc/logrotate.d/homepod-assistant
```

## Next Steps

1. **Test the deployment** with basic functionality
2. **Configure voice assistant** integration
3. **Set up smart home** connections
4. **Add weather API** integration
5. **Implement Spotify** connectivity
6. **Add security features**

## Support

- Check the main README.md for general project information
- Review HomePod_Assistant_Checklist.md for feature roadmap
- Create issues in the GitHub repository for bugs
- Check Waveshare documentation for display-specific issues 