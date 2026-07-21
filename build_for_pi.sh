#!/bin/bash

# HomePod Assistant - Raspberry Pi Build Script
# This script builds the Flutter app for Raspberry Pi deployment

echo "🍓 Building HomePod Assistant for Raspberry Pi..."

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for Linux (Raspberry Pi)
echo "🔨 Building for Linux..."
flutter build linux --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📁 Build location: build/linux/x64/release/bundle/"
    echo ""
    echo "🚀 To deploy to Raspberry Pi:"
    echo "1. Copy the bundle folder to your Raspberry Pi:"
    echo "   scp -r build/linux/x64/release/bundle/ pi@your-pi-ip:/home/pi/homepod_assistant/"
    echo ""
    echo "2. SSH into your Raspberry Pi and make it executable:"
    echo "   ssh pi@your-pi-ip"
    echo "   chmod +x /home/pi/homepod_assistant/homepod_assistant"
    echo ""
    echo "3. Run the app:"
    echo "   /home/pi/homepod_assistant/homepod_assistant"
    echo ""
    echo "📖 See RASPBERRY_PI_DEPLOYMENT.md for detailed setup instructions."
else
    echo "❌ Build failed!"
    exit 1
fi 