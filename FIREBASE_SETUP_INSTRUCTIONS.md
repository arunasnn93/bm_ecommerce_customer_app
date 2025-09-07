# 🔥 Firebase Setup Instructions

## Method 1: Create Project in Console (Recommended)

### 1. Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Create a project" or "Add project"
3. Enter project name: `beena-mart-customer-app`
4. Enable Google Analytics (optional)
5. Click "Create project"
6. **Note the Project ID** (e.g., `beena-mart-customer-app-abc123`)

### 2. Update Configuration Files
Replace `YOUR_PROJECT_ID_HERE` in these files with your actual Project ID:

**`.firebaserc`:**
```json
{
  "projects": {
    "default": "your-actual-project-id"
  }
}
```

**`.github/workflows/deploy.yml`:**
```yaml
projectId: your-actual-project-id
```

### 3. Initialize Firebase
```bash
firebase init hosting
```

## Method 2: Let Firebase Auto-Detect

### 1. Initialize Firebase (will show available projects)
```bash
firebase init hosting
```

### 2. Select from Available Projects
- Firebase will show you all available projects
- Select the one you want to use
- Or create a new one from the list

### 3. Configure Hosting
- Public directory: `build/web`
- Single-page app: `Yes`
- Overwrite index.html: `No`

## Method 3: Use Existing Project

If you already have a Firebase project:

### 1. List Available Projects
```bash
firebase projects:list
```

### 2. Use Existing Project
```bash
firebase use your-existing-project-id
```

### 3. Initialize Hosting
```bash
firebase init hosting
```

## After Setup

### 1. Test Configuration
```bash
firebase projects:list
firebase use --list
```

### 2. Build and Deploy
```bash
flutter build web --release --web-renderer canvaskit
firebase deploy
```

## Troubleshooting

### Project Not Found
- Make sure you're logged in: `firebase login`
- Check project exists in console
- Verify project ID is correct

### Permission Issues
- Make sure you have Owner/Editor role on the project
- Check Firebase Console → Project Settings → Users and permissions

### Multiple Projects
- Use `firebase use project-id` to switch projects
- Use `firebase use --list` to see all configured projects
