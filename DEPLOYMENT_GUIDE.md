# 🚀 Beena Mart Web App - Firebase Deployment Guide

## Prerequisites
- Node.js installed
- Flutter SDK installed
- Firebase account
- Git repository

## Quick Deployment (Recommended)

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Project name: `beena-mart-customer-app`
4. Enable Google Analytics (optional)
5. Create project

### 4. Initialize Firebase
```bash
firebase init hosting
```
- Select your project: `beena-mart-customer-app`
- Public directory: `build/web`
- Single-page app: `Yes`
- Overwrite index.html: `No`

### 5. Deploy
```bash
# Make script executable (macOS/Linux)
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

## Manual Deployment Steps

### 1. Clean and Build
```bash
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit
```

### 2. Deploy to Firebase
```bash
firebase deploy
```

## Automated Deployment with GitHub Actions

### 1. Set up Firebase Service Account
1. Go to Firebase Console → Project Settings → Service Accounts
2. Generate new private key
3. Copy the JSON content

### 2. Add GitHub Secrets
1. Go to your GitHub repository → Settings → Secrets
2. Add secret: `FIREBASE_SERVICE_ACCOUNT_BEENA_MART_CUSTOMER_APP`
3. Paste the JSON content as the value

### 3. Push to Main Branch
```bash
git add .
git commit -m "Deploy to Firebase"
git push origin main
```

## Post-Deployment

### Your App URLs
- **Firebase URL**: `https://beena-mart-customer-app.web.app`
- **Custom Domain**: `https://app.beenamart.com` (after setup)

### Features Available
- ✅ Responsive design for mobile and desktop
- ✅ PWA support (installable)
- ✅ Offline functionality
- ✅ Fast loading with CDN
- ✅ SSL certificate
- ✅ Custom domain support

### Monitoring
- Firebase Console → Hosting → Analytics
- Google Analytics (if enabled)
- Performance monitoring

## Troubleshooting

### Build Issues
```bash
# Clear Flutter cache
flutter clean
flutter pub cache clean
flutter pub get
```

### Firebase Issues
```bash
# Re-login to Firebase
firebase logout
firebase login
```

### Domain Issues
- Check DNS propagation (can take 24-48 hours)
- Verify SSL certificate status in Firebase Console
- Check domain verification status

## Performance Optimization

### Build Optimizations
```bash
# Use CanvasKit renderer for better performance
flutter build web --release --web-renderer canvaskit

# Enable tree shaking
flutter build web --release --tree-shake-icons
```

### Firebase Hosting Optimizations
- Automatic CDN distribution
- Gzip compression
- Browser caching
- HTTP/2 support

## Security Considerations

### HTTPS
- Automatic SSL certificates
- HTTP to HTTPS redirects
- HSTS headers

### CORS Configuration
- API endpoints should allow your domain
- Configure CORS in your backend

## Support
- Firebase Documentation: https://firebase.google.com/docs/hosting
- Flutter Web: https://flutter.dev/web
- Issues: Create GitHub issue in your repository
