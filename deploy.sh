#!/bin/bash

# Beena Mart Web App Deployment Script
echo "🚀 Starting Beena Mart Web App Deployment..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🔨 Building for web..."
flutter build web --release --web-renderer canvaskit

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Deploy to Firebase
    echo "🔥 Deploying to Firebase..."
    firebase deploy
    
    if [ $? -eq 0 ]; then
        echo "🎉 Deployment successful!"
        echo "🌐 Your app is now live at: https://beena-mart-customer-app.web.app"
    else
        echo "❌ Firebase deployment failed!"
        exit 1
    fi
else
    echo "❌ Build failed!"
    exit 1
fi
