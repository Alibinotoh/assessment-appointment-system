# Guidance and Counseling System - Complete Architecture

## System Overview
- **Backend**: FastAPI + Neo4j Aura
- **Frontend**: Flutter (Web/Mobile)
- **Authentication**: JWT (Counselor/Admin only)
- **Client Access**: Anonymous (no auth required)

---

## Scoring Logic

### Section 1: Mental Health Quality (10 items)
- **Valence**: Positive (Excellent=1, Poor=5)
- **Score**: Sum all answers / 10

### Section 2: University Life (10 items)
- **Valence**: Positive (YES=1, NO=5)
- **Score**: Sum all answers / 10

### Section 3: Self Assessment (10 items)
- **Valence**: Negative (Not at all=1, Very Much=5)
- **EXCEPTION**: Q8 "Do you feel calmness and happiness?" is REVERSED
  - Not at all/Never = 5 (worst)
  - Very Much/Always = 1 (best)
- **Score**: Sum all answers / 10

### Overall Score
```
Overall = (Section1 + Section2 + Section3) / 3
```

### Stress Levels
- **Low**: 1.0 - 2.33
- **Moderate**: 2.34 - 3.66
- **High**: 3.67 - 5.0

---

## Flutter App Structure

```
lib/
├── main.dart
├── config/
│   ├── api_config.dart (API base URL)
│   └── theme_config.dart (Colors, fonts)
├── models/
│   ├── assessment.dart
│   ├── appointment.dart
│   └── counselor.dart
├── providers/ (Riverpod)
│   ├── assessment_provider.dart
│   ├── appointment_provider.dart
│   └── auth_provider.dart
├── screens/
│   ├── client/
│   │   ├── welcome_screen.dart
│   │   ├── assessment_screen.dart
│   │   ├── results_screen.dart
│   │   ├── booking_form_screen.dart
│   │   └── booking_status_screen.dart
│   └── admin/
│       ├── login_screen.dart
│       ├── dashboard_screen.dart
│       └── appointment_detail_screen.dart
├── services/
│   ├── api_service.dart
│   └── notification_service.dart
├── widgets/
│   ├── custom_button.dart (with animation)
│   ├── loading_indicator.dart
│   └── error_dialog.dart
└── assets/
    ├── images/
    │   ├── logo.png (Mindanao State University logo)
    │   └── background.jpg (Student Center building)
    └── animations/
```

### Key UI/UX Features
1. **Assets**: Use provided logo and background image
2. **Animations**: Button press effects, page transitions
3. **Error Handling**: Network error dialogs, retry mechanisms
4. **Real-time**: WebSocket/polling for appointment status updates
5. **Responsive**: Works on mobile and web

---

## API Implementation Priority

### Phase 1: Core Client Features
1. GET `/assessment/questions`
2. POST `/assessment/submit`
3. GET `/counselors/available`
4. POST `/appointment/book`

### Phase 2: Admin Features
5. POST `/admin/login`
6. GET `/admin/appointment/{id}`
7. PUT `/admin/appointment/{id}/status`

---

## Deployment Checklist

### Backend (.env file)
```
NEO4J_URI=neo4j+s://xxxxx.databases.neo4j.io
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your_password
NEO4J_DATABASE=neo4j
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
```

### Flutter (api_config.dart)
```dart
class ApiConfig {
  static const String baseUrl = 'https://your-api.com';
}
```

---

## Next Steps
1. Set up Neo4j Aura database
2. Create initial counselor account
3. Deploy FastAPI backend
4. Build Flutter app
5. Test end-to-end flow
