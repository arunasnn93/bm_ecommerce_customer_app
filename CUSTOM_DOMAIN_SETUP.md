# Custom Domain Setup for Beena Mart Web App

## Steps to Configure Custom Domain

### 1. Add Custom Domain in Firebase Console
1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Enter your domain (e.g., `app.beenamart.com`)
4. Follow the verification steps

### 2. Configure DNS Records
Add these DNS records to your domain provider:

#### For Root Domain (beenamart.com):
```
Type: A
Name: @
Value: 151.101.1.195
TTL: 3600

Type: A
Name: @
Value: 151.101.65.195
TTL: 3600
```

#### For Subdomain (app.beenamart.com):
```
Type: CNAME
Name: app
Value: beena-mart-customer-app.web.app
TTL: 3600
```

### 3. SSL Certificate
Firebase automatically provides SSL certificates for custom domains.

### 4. Update Firebase Configuration
After domain verification, update your firebase.json:

```json
{
  "hosting": {
    "public": "build/web",
    "site": "beena-mart-customer-app",
    "customDomain": "app.beenamart.com",
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### 5. Redeploy
```bash
firebase deploy
```

## Domain Examples
- `app.beenamart.com`
- `customer.beenamart.com`
- `shop.beenamart.com`
- `web.beenamart.com`
