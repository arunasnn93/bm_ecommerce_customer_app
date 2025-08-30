# API Integration Guide - Beena Mart

This guide explains how to integrate real APIs with the Beena Mart mobile application.

## 🚀 **Quick Setup**

### 1. **Configure Environment**

Edit `lib/core/config/app_config.dart` to set your environment:

```dart
// For Development (Demo Mode)
static Environment environment = Environment.development;

// For Staging (Real API)
static Environment environment = Environment.staging;

// For Production (Real API)
static Environment environment = Environment.production;
```

### 2. **Update API Base URL**

Update the base URLs in `lib/core/config/app_config.dart`:

```dart
static String get baseUrl {
  switch (environment) {
    case Environment.development:
      return 'http://localhost:3000'; // Your local development server
    case Environment.staging:
      return 'https://your-staging-api.com';
    case Environment.production:
      return 'https://your-production-api.com';
  }
}
```

## 📡 **API Endpoints Required**

### Authentication Endpoints

#### 1. **Send OTP**
```
POST /auth/send-otp
```

**Request Body:**
```json
{
  "mobile": "8089560306"
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "mobile": "+918089560306"
  },
  "timestamp": "2025-08-27T18:23:14.819Z"
}
```

#### 2. **Verify OTP**
```
POST /auth/verify-otp
```

**Request Body:**
```json
{
  "mobile": "8089560306",
  "otp": "532593",
  "name": "John Doe",
  "fcm_token": "fcm_token_here"
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Account created successfully",
  "data": {
    "user": {
      "id": "84518d13-1e08-4a48-b9d9-96b3237b6790",
      "mobile": "+918089560306",
      "name": "John Doe",
      "role": "customer",
      "isNewUser": true
    },
    "session": {
      "properties": {
        "action_link": "https://fitobjouvvxbpqdcgxvg.supabase.co/auth/v1/verify?token=093437de71a7548d4e73ac5765f9b6ad78032a53beb1750f1a9754d2&type=magiclink&redirect_to=http://localhost:3000",
        "email_otp": "800890",
        "hashed_token": "093437de71a7548d4e73ac5765f9b6ad78032a53beb1750f1a9754d2",
        "redirect_to": "http://localhost:3000",
        "verification_type": "magiclink"
      },
      "user": {
        "id": "84518d13-1e08-4a48-b9d9-96b3237b6790",
        "aud": "authenticated",
        "role": "authenticated",
        "email": "918089560306@temp.com",
        "email_confirmed_at": "2025-08-27T14:02:14.243627Z",
        "phone": "918089560306",
        "phone_confirmed_at": "2025-08-27T14:02:14.249542Z",
        "confirmed_at": "2025-08-27T14:02:14.243627Z",
        "recovery_sent_at": "2025-08-27T14:02:14.616602049Z",
        "app_metadata": {
          "provider": "email",
          "providers": ["email", "phone"]
        },
        "user_metadata": {
          "email_verified": true
        },
        "identities": [...],
        "created_at": "2025-08-27T14:02:14.204718Z",
        "updated_at": "2025-08-27T14:02:14.6197Z",
        "is_anonymous": false
      }
    }
  },
  "timestamp": "2025-08-27T14:02:13.785Z"
}
```

**Note:** The `name` field is required for first-time users. For existing users, the `name` field can be omitted.

## 🔧 **Implementation Details**

### Current Implementation

The app is already set up with:

1. **API Models**: Request/Response models in `lib/features/auth/data/models/`
2. **Data Sources**: Remote and demo data sources
3. **Error Handling**: Comprehensive error handling for different HTTP status codes
4. **Configuration**: Environment-based configuration

### Demo Mode vs Real API

- **Demo Mode**: Uses simulated responses for development
- **Real API**: Makes actual HTTP requests to your server

### Error Handling

The app handles these HTTP status codes:

- `400`: Bad Request (Invalid input)
- `401`: Unauthorized (Invalid/expired OTP)
- `404`: Not Found (Invalid mobile number)
- `429`: Too Many Requests (Rate limiting)
- `500`: Server Error

## 🧪 **Testing**

### 1. **Test with Demo Mode**
```dart
// In app_config.dart
static Environment environment = Environment.development;
```

### 2. **Test with Real API**
```dart
// In app_config.dart
static Environment environment = Environment.staging;
```

### 3. **API Testing Tools**
- Use Postman or similar tools to test your API endpoints
- Ensure all endpoints return the expected response format

## 🔐 **Security Considerations**

### 1. **HTTPS Only**
- Always use HTTPS in production
- Never send sensitive data over HTTP

### 2. **Token Management**
- Store tokens securely using SharedPreferences
- Implement token refresh mechanism
- Clear tokens on logout

### 3. **Input Validation**
- Validate mobile numbers on both client and server
- Implement rate limiting for OTP requests
- Sanitize all user inputs

## 📱 **Mobile App Features**

### Current Features
- ✅ Mobile number validation
- ✅ OTP input with auto-focus
- ✅ Loading states
- ✅ Error handling
- ✅ Local storage for tokens
- ✅ Demo mode for development

### Upcoming Features
- 🔄 Token refresh
- 🔄 User profile management
- 🔄 Push notifications
- 🔄 Offline support

## 🚀 **Deployment Checklist**

### Before Production
- [ ] Update API base URLs
- [ ] Test all endpoints
- [ ] Configure error monitoring
- [ ] Set up logging
- [ ] Test on real devices
- [ ] Performance testing

### Production Configuration
```dart
// Set to production
static Environment environment = Environment.production;

// Disable demo mode
static bool get useDemoMode => false;

// Disable debug logging
static bool get enableLogging => false;
```

## 📞 **Support**

If you need help with API integration:

1. Check the console logs for detailed error messages
2. Verify your API endpoints are working with Postman
3. Ensure response format matches the expected structure
4. Check network connectivity and firewall settings

## 🔄 **Next Steps**

1. **Implement your API endpoints** following the specifications above
2. **Update the base URLs** in the configuration
3. **Test the integration** with your staging environment
4. **Deploy to production** when ready

The app is designed to be easily configurable and ready for real API integration!
