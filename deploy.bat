@echo off
REM Beena Mart Web App Deployment Script for Windows

echo 🚀 Starting Beena Mart Web App Deployment...

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Build for web
echo 🔨 Building for web...
flutter build web --release --web-renderer canvaskit

REM Check if build was successful
if %errorlevel% equ 0 (
    echo ✅ Build successful!
    
    REM Deploy to Firebase
    echo 🔥 Deploying to Firebase...
    firebase deploy
    
    if %errorlevel% equ 0 (
        echo 🎉 Deployment successful!
        echo 🌐 Your app is now live at: https://beena-mart-customer-app.web.app
    ) else (
        echo ❌ Firebase deployment failed!
        exit /b 1
    )
) else (
    echo ❌ Build failed!
    exit /b 1
)
