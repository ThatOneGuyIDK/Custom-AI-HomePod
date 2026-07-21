#!/bin/bash

# 🍓 HomePod Assistant - Linux Testing Script
# This script sets up a Linux environment for testing Raspberry Pi compatibility

echo "🚀 Setting up Linux testing environment for HomePod Assistant..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential dependencies
echo "🔧 Installing essential dependencies..."
sudo apt install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    libgtk-3-dev \
    libx11-dev \
    libxcursor-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxi-dev \
    libxext-dev \
    libxfixes-dev \
    libxrender-dev \
    libxss-dev \
    libxtst-dev \
    libxrandr2 \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    ca-certificates \
    fonts-liberation \
    libappindicator1 \
    libnss3 \
    lsb-release \
    xdg-utils \
    wget \
    cmake \
    build-essential \
    pkg-config

# Install Flutter for Linux
echo "📱 Installing Flutter for Linux..."
if [ ! -d "$HOME/flutter" ]; then
    cd $HOME
    git clone https://github.com/flutter/flutter.git -b stable
    export PATH="$PATH:$HOME/flutter/bin"
    echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
else
    echo "Flutter already installed, updating..."
    cd $HOME/flutter
    git pull
fi

# Set up Flutter environment
export PATH="$PATH:$HOME/flutter/bin"
flutter doctor

# Install additional testing tools
echo "🧪 Installing testing tools..."
sudo apt install -y \
    valgrind \
    gdb \
    strace \
    htop \
    iotop \
    nethogs

# Test Flutter Linux build
echo "🔨 Testing Flutter Linux build..."
cd /mnt/c/Users/thoma/Documents/HomePod/homepod_assistant
flutter clean
flutter pub get
flutter build linux --debug

echo "✅ Linux testing environment setup complete!"
echo "🎯 Next steps:"
echo "   1. Run: flutter run -d linux"
echo "   2. Test all widgets"
echo "   3. Check performance and compatibility" 