# MSU Guidance and Counseling - Flutter App

Mobile/Web application for anonymous self-assessment and appointment booking.

## Features

### Client Features (No Authentication)
- Anonymous self-assessment (3 sections, 30 questions)
- Real-time score calculation
- Stress level determination
- Direct appointment booking with personal details
- Appointment status tracking via email

### Counselor/Admin Features (JWT Authentication)
- Secure login
- Dashboard with appointment overview
- View detailed appointment information
- Access linked assessment results
- Confirm/Reject appointments
- Add counselor notes

## Setup

### 1. Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### 2. Install Dependencies

```bash
cd flutter_app
flutter pub get
```

### 3. Configure API Endpoint

Edit `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://your-backend-url:8000';
```

For local development:
- Android Emulator: `http://10.0.2.2:8000`
- iOS Simulator: `http://localhost:8000`
- Physical Device: `http://YOUR_COMPUTER_IP:8000`

### 4. Add Assets

Place the following files in the `assets/images/` directory:
- `logo.png` - MSU logo
- `background.jpg` - Student Center building image

Update `pubspec.yaml` if needed.

### 5. Run the App

```bash
# For mobile
flutter run

# For web
flutter run -d chrome

# For release build
flutter build apk  # Android
flutter build ios  # iOS
flutter build web  # Web
```

## Project Structure

```
lib/
├── config/
│   ├── api_config.dart       # API endpoints
│   └── theme_config.dart     # App theme & colors
├── models/
│   ├── assessment.dart       # Assessment data models
│   └── appointment.dart      # Appointment data models
├── providers/
│   ├── assessment_provider.dart  # Assessment state management
│   └── auth_provider.dart        # Authentication state
├── screens/
│   ├── client/
│   │   ├── welcome_screen.dart
│   │   ├── assessment_screen.dart
│   │   ├── results_screen.dart
│   │   └── booking_form_screen.dart
│   └── admin/
│       ├── login_screen.dart
│       ├── dashboard_screen.dart
│       └── appointment_detail_screen.dart
├── services/
│   └── api_service.dart      # HTTP API calls
├── widgets/
│   ├── custom_button.dart    # Animated button
│   └── error_dialog.dart     # Error/Success dialogs
└── main.dart
```

## Key Dependencies

- **flutter_riverpod**: State management
- **http**: API communication
- **google_fonts**: Typography
- **flutter_animate**: Animations
- **shared_preferences**: Local storage
- **intl**: Date formatting

## Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## Building for Production

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Then open in Xcode for signing and distribution
```

### Web
```bash
flutter build web --release
# Output: build/web/
```

## Troubleshooting

### Network Error
- Check API endpoint in `api_config.dart`
- Ensure backend is running
- Check firewall settings

### Assets Not Loading
- Run `flutter pub get`
- Verify assets exist in `assets/images/`
- Check `pubspec.yaml` asset declarations

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```
