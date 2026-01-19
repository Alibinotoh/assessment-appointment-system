# 📱 Mobile Deployment Guide

## Overview

This system is designed as a **mobile-first application**:
- **Students & Employees:** Use mobile app (Android/iOS)
- **Counselors/Admin:** Can use mobile app OR web browser on PC

---

## 🎯 Platform Support

### ✅ Fully Supported Platforms

| Platform | Target Users | Status |
|----------|--------------|--------|
| **Android** | Students, Employees, Counselors | ✅ Ready |
| **iOS** | Students, Employees, Counselors | ✅ Ready |
| **Web (Chrome)** | Counselors (PC/Laptop) | ✅ Ready |
| **Linux Desktop** | Development/Testing | ✅ Ready |

---

## 📦 Building the Mobile App

### For Android (APK)

```bash
cd flutter_app

# Build release APK
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

**Distribution Options:**
1. **Direct Installation:** Share APK file via email/USB
2. **Google Play Store:** Upload to Play Console (requires developer account)
3. **Internal Distribution:** Use Firebase App Distribution or similar

### For iOS (IPA)

```bash
cd flutter_app

# Build iOS app
flutter build ios --release

# Then open in Xcode for signing
open ios/Runner.xcworkspace
```

**Distribution Options:**
1. **TestFlight:** Beta testing for internal users
2. **App Store:** Public distribution (requires Apple Developer account)
3. **Enterprise Distribution:** For MSU internal deployment

---

## 🌐 Web Deployment (for Counselors)

### Build for Production

```bash
cd flutter_app

# Build web version
flutter build web --release

# Output: build/web/
```

### Deploy to Hosting

**Option 1: Firebase Hosting**
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy
```

**Option 2: Netlify**
```bash
cd build/web
netlify deploy --prod
```

**Option 3: Your Own Server**
```bash
# Copy build/web/ to your web server
scp -r build/web/* user@server:/var/www/counseling-app/
```

---

## 🔧 Backend Deployment

### Recommended: Railway

```bash
cd backend

# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

### Alternative: Render, DigitalOcean, or AWS

See `DEPLOYMENT_GUIDE.md` for detailed instructions.

---

## 📱 App Configuration

### Update API Endpoint

**For Development (Local Testing):**
```dart
// lib/config/api_config.dart
static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
static const String baseUrl = 'http://localhost:8000'; // iOS Simulator
```

**For Production:**
```dart
// lib/config/api_config.dart
static const String baseUrl = 'https://your-backend-url.com';
```

### Update App Name & Icon

**App Name:**
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="MSU Counseling"
    ...>
```

Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleName</key>
<string>MSU Counseling</string>
```

**App Icon:**
Replace icons in:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Or use: `flutter pub run flutter_launcher_icons`

---

## 🎨 Branding

### Add MSU Assets

1. **Logo:** Place in `assets/images/logo.png`
2. **Background:** Place in `assets/images/background.jpg`
3. **Splash Screen:** Configure in `flutter_native_splash.yaml`

### Colors (Already Configured)

- **Primary Maroon:** `#8B1538` (MSU Maroon)
- **Gold Accent:** `#FFD700` (MSU Gold)
- **Background:** `#F5F5F5`

---

## 📊 Testing Strategy

### 1. Local Testing

**Android Emulator:**
```bash
flutter emulators --launch <emulator_id>
flutter run
```

**Physical Device:**
```bash
# Enable USB debugging on device
flutter devices
flutter run -d <device_id>
```

### 2. Beta Testing

**Android:**
- Use Google Play Console Internal Testing
- Or Firebase App Distribution

**iOS:**
- Use TestFlight for beta testing

### 3. Web Testing

```bash
flutter run -d chrome
# Test at http://localhost:3000
```

---

## 🔐 Security Considerations

### For Mobile Apps

1. **API Security:**
   - Use HTTPS for production backend
   - Implement certificate pinning (optional)

2. **Data Storage:**
   - Sensitive data uses `flutter_secure_storage`
   - JWT tokens stored securely

3. **Permissions:**
   - Minimal permissions requested
   - No unnecessary data collection

### For Web Version

1. **CORS Configuration:**
   ```python
   # backend/main.py
   ALLOWED_ORIGINS = ["https://counseling.msu.edu.ph"]
   ```

2. **HTTPS Only:**
   - Enforce HTTPS in production
   - Use SSL certificates

---

## 📋 Pre-Launch Checklist

### Backend
- [ ] Deploy to production server
- [ ] Configure environment variables
- [ ] Test all API endpoints
- [ ] Set up monitoring/logging
- [ ] Configure CORS for production domains

### Mobile App
- [ ] Update API endpoint to production
- [ ] Add real MSU logo and images
- [ ] Test on physical devices (Android & iOS)
- [ ] Configure app signing
- [ ] Build release APK/IPA
- [ ] Test installation on clean devices

### Web App
- [ ] Build production web version
- [ ] Deploy to hosting service
- [ ] Test on different browsers
- [ ] Verify responsive design
- [ ] Test admin login flow

### Database
- [ ] Verify Neo4j Aura is running
- [ ] Change default counselor password
- [ ] Create additional counselor accounts
- [ ] Set up backup strategy

---

## 🚀 Distribution Strategy

### Phase 1: Internal Beta (Week 1-2)
- Deploy to 5-10 counselors
- Test with limited student group
- Gather feedback

### Phase 2: Soft Launch (Week 3-4)
- Deploy to all counselors
- Announce to specific departments
- Monitor performance

### Phase 3: Full Launch
- University-wide announcement
- App available on Play Store/App Store
- Web version for counselor access

---

## 📱 User Access Methods

### Students & Employees
1. **Download App:**
   - Android: Google Play Store or direct APK
   - iOS: App Store or TestFlight

2. **Use App:**
   - No login required for assessment
   - Book appointment with personal details

### Counselors
1. **Mobile App:**
   - Download same app as students
   - Access "Counselor Login" button
   - Full dashboard on mobile

2. **Web Browser (PC):**
   - Visit: https://counseling.msu.edu.ph
   - Login with credentials
   - Desktop-optimized interface

---

## 🔄 Updates & Maintenance

### App Updates
- **Android:** Push updates via Play Store
- **iOS:** Submit updates to App Store
- **Web:** Deploy new build (instant update)

### Backend Updates
- Zero-downtime deployment
- Database migrations as needed
- Monitor error logs

---

## 📞 Support

### For Students
- In-app help section
- Email: counseling@msu.edu.ph
- Walk-in support at Guidance Office

### For Counselors
- Admin training session
- Technical support contact
- User manual provided

---

## 🎯 Success Metrics

Track these metrics:
- Number of assessments completed
- Appointment booking rate
- Counselor response time
- App crash rate
- User satisfaction

---

**Your mobile-first counseling system is ready for deployment!** 🎉

For technical deployment details, see `DEPLOYMENT_GUIDE.md`
