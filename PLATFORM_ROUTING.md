# Platform-Based Routing Implementation

## Overview
The app now uses **platform-aware routing** to show different interfaces based on the device type:

- **📱 Mobile App** → Client interface (Self-Assessment + Book Appointment)
- **💻 Web/Desktop** → Admin/Counselor login and dashboard

## Architecture

### Entry Point Flow
```
main.dart
  └─> PlatformRouterScreen
       ├─> Mobile? → ClientHomeScreen (Client Interface)
       └─> Desktop/Web? → AdminLoginScreen (Admin Interface)
```

### Platform Detection
```dart
bool get _isDesktopOrWeb {
  if (kIsWeb) return true;  // Web browser
  
  try {
    // Desktop platforms
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  } catch (e) {
    return false;  // Mobile (Android/iOS)
  }
}
```

## User Flows

### 📱 Mobile Users (Clients)
1. **Open App** → See `ClientHomeScreen`
2. **Two Options:**
   - **Self-Assessment** → Take mental health assessment
   - **Book Appointment** → Schedule counseling session
3. **No Admin Access** → Admin login not visible on mobile

### 💻 Desktop/Web Users (Admin/Counselors)
1. **Open App** → See `AdminLoginScreen`
2. **Login Required** → Must authenticate
3. **After Login** → Access full admin dashboard
4. **Features:**
   - View appointments
   - Manage time slots
   - Review assessments
   - Analytics

## File Structure

```
lib/
├── main.dart                          # App entry point
├── screens/
│   ├── platform_router_screen.dart    # Platform detection & routing
│   ├── client/
│   │   ├── client_home_screen.dart    # NEW: Mobile home screen
│   │   ├── assessment_screen.dart     # Self-assessment
│   │   ├── booking_form_screen.dart   # Book appointment
│   │   └── ...
│   └── admin/
│       ├── login_screen.dart          # Admin login
│       ├── enhanced_dashboard_screen.dart
│       └── ...
```

## Benefits

### ✅ Security
- Clients **cannot access** admin login on mobile
- Admin features only on desktop/web
- Clear separation of concerns

### ✅ User Experience
- **Mobile**: Simple, focused interface for clients
- **Desktop**: Full-featured admin dashboard
- No confusion about which interface to use

### ✅ Responsive Design
- Flutter automatically handles sizing
- Desktop mode works on mobile browsers (if needed)
- Mobile app optimized for touch

## Testing

### Test on Mobile (Android/iOS)
```bash
# Run on mobile device/emulator
flutter run
```
**Expected:** See `ClientHomeScreen` with two buttons

### Test on Web
```bash
# Run on Chrome
flutter run -d chrome
```
**Expected:** See `AdminLoginScreen`

### Test on Desktop
```bash
# Linux
flutter run -d linux

# Windows
flutter run -d windows

# macOS
flutter run -d macos
```
**Expected:** See `AdminLoginScreen`

## Deployment

### Mobile App (Clients)
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```
**Distribution:** Google Play Store, Apple App Store

### Web App (Admin)
```bash
flutter build web --release
```
**Hosting:** Deploy to web server (same as current setup)

### Desktop App (Admin - Optional)
```bash
# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

## Configuration

### Force Platform (For Testing)
If you want to test admin interface on mobile or vice versa, modify `platform_router_screen.dart`:

```dart
// Force mobile view
return const ClientHomeScreen();

// Force desktop view
return const AdminLoginScreen();
```

## Client Home Screen Features

### Self-Assessment Button
- Navigates to assessment questionnaire
- 3 sections of questions
- Generates stress level report
- Option to book appointment after results

### Book Appointment Button
- Direct booking without assessment
- Fill in personal details
- Select counselor and time slot
- Receive confirmation

### Design
- **Color Scheme:** MSU Maroon & Gold
- **Icons:** Material Design
- **Layout:** Card-based, touch-friendly
- **Accessibility:** High contrast, readable fonts

## Future Enhancements

### Possible Additions:
1. **QR Code Login** - Admin can scan QR to login on mobile
2. **Emergency Contact** - Quick access to crisis hotline
3. **Resources** - Mental health articles and tips
4. **Appointment History** - Clients can check their bookings
5. **Push Notifications** - Appointment reminders

## Troubleshooting

### Issue: Wrong screen shows on platform
**Solution:** Check platform detection logic in `platform_router_screen.dart`

### Issue: Mobile app shows admin login
**Solution:** Ensure you're building for mobile target, not web

### Issue: Desktop shows client home
**Solution:** Platform detection might be failing, check imports

## Summary

✅ **Mobile App** = Client interface only (no admin access)
✅ **Web/Desktop** = Admin interface only (login required)
✅ **Automatic** = Platform detection handles routing
✅ **Secure** = Clients can't accidentally access admin features
✅ **Simple** = Clean, focused user experience for each platform
