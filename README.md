# MSU Guidance and Counseling Self-Assessment & Appointment System

Complete technical implementation for Mindanao State University's Guidance and Counseling system with **anonymous self-assessment** and **non-authenticated appointment scheduling**.

## 🎯 Project Overview

### Core Features
- ✅ **Anonymous Self-Assessment**: 30-question assessment across 3 sections
- ✅ **Automated Scoring**: Real-time calculation with stress level determination
- ✅ **No Client Authentication**: Direct appointment booking with personal details
- ✅ **Counselor Portal**: JWT-authenticated admin interface
- ✅ **Neo4j Graph Database**: Efficient relationship mapping between assessments and appointments

### Technology Stack
- **Backend**: FastAPI (Python)
- **Database**: Neo4j Aura (Graph Database)
- **Frontend**: Flutter (Mobile & Web)
- **Authentication**: JWT (Counselor/Admin only)

---

## 📊 Assessment Scoring Methodology

### Section 1: Mental Health Quality (10 items)
- **Valence**: Positive
- **Scoring**: Excellent (1) → Poor (5)
- **Calculation**: Sum of all answers / 10

### Section 2: University Life (10 items)
- **Valence**: Positive
- **Scoring**: YES (1) → NO (5)
- **Calculation**: Sum of all answers / 10

### Section 3: Self Assessment (10 items)
- **Valence**: Negative
- **Scoring**: Not at all (1) → Very Much (5)
- **EXCEPTION**: Q8 "Do you feel calmness and happiness?" is **REVERSED**
  - Not at all/Never = 5 (worst)
  - Very Much/Always = 1 (best)
- **Calculation**: Sum of all answers / 10

### Overall Score & Stress Levels
```
Overall Score = (Section1 + Section2 + Section3) / 3

Stress Levels:
- Low: 1.0 - 2.33
- Moderate: 2.34 - 3.66
- High: 3.67 - 5.0
```

---

## 🗄️ Neo4j Data Model

### Nodes

**AssessmentSubmission**
```cypher
Properties:
- submission_id: String (UUID)
- timestamp: DateTime
- section1_raw_answers: Map<String, Integer>
- section2_raw_answers: Map<String, Integer>
- section3_raw_answers: Map<String, Integer>
- section1_score: Float
- section2_score: Float
- section3_score: Float
- overall_score: Float
- stress_level: String
- recommendation: String
```

**Counselor**
```cypher
Properties:
- counselor_id: String (UUID)
- full_name: String
- email: String (Unique)
- employee_id: String
- specialization: String
- password_hash: String
- created_at: DateTime
```

**TimeSlot**
```cypher
Properties:
- slot_id: String (UUID)
- date: Date
- start_time: Time
- end_time: Time
- is_available: Boolean
```

**Appointment**
```cypher
Properties:
- appointment_id: String (UUID)
- created_at: DateTime
- scheduled_date: Date
- scheduled_time: Time
- status: String (Pending/Confirmed/Rejected/Completed)
- counselor_notes: String
- rejection_reason: String
- client_full_name: String
- client_email: String
- client_student_id: String
- client_course: String
- client_year_level: String
- client_gender: String
- client_age: Integer
- client_contact_number: String
```

### Relationships
```cypher
(Appointment)-[:BASED_ON_ASSESSMENT]->(AssessmentSubmission)
(Appointment)-[:ASSIGNED_TO]->(Counselor)
(Appointment)-[:OCCUPIES_SLOT]->(TimeSlot)
(Counselor)-[:HAS_SLOT]->(TimeSlot)
```

---

## 🚀 Quick Start

### 1. Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your Neo4j Aura credentials

# Initialize database
python scripts/init_db.py

# Run server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**API Documentation**: http://localhost:8000/docs

### 2. Flutter App Setup

```bash
cd flutter_app

# Install dependencies
flutter pub get

# Add your assets
# Place logo.png and background.jpg in assets/images/

# Configure API endpoint
# Edit lib/config/api_config.dart

# Run app
flutter run
```

---

## 📡 API Endpoints

### Client Endpoints (No Authentication)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/assessment/questions` | Get questionnaire |
| POST | `/assessment/submit` | Submit assessment |
| GET | `/appointment/counselors/available` | List counselors with slots |
| POST | `/appointment/book` | Book appointment |
| GET | `/appointment/status/{email}` | Check appointment status |

### Admin Endpoints (JWT Required)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/admin/login` | Counselor login |
| GET | `/admin/assessments` | View all assessments |
| GET | `/admin/appointment/{id}` | View appointment details |
| PUT | `/admin/appointment/{id}/status` | Update appointment status |
| POST | `/admin/slots` | Create time slot |
| GET | `/admin/appointments` | List counselor's appointments |

---

## 🎨 Flutter App Screens

### Client Flow
1. **Welcome Screen**: Landing page with MSU branding
2. **Assessment Screen**: 3-section questionnaire with progress indicator
3. **Results Screen**: Score display with stress level visualization
4. **Booking Form Screen**: Counselor selection and personal details input

### Admin Flow
1. **Login Screen**: JWT authentication
2. **Dashboard Screen**: Appointments overview and recent assessments
3. **Appointment Detail Screen**: Full client info + linked assessment

---

## 🔐 Security Features

- **JWT Authentication**: Secure counselor/admin access
- **Password Hashing**: Bcrypt for password storage
- **CORS Configuration**: Controlled cross-origin requests
- **Input Validation**: Pydantic schemas for data validation
- **Anonymous Assessments**: No PII stored until booking

---

## 📦 Project Structure

```
Assessment_Appointment_System/
├── backend/
│   ├── config.py
│   ├── main.py
│   ├── requirements.txt
│   ├── models/
│   │   └── schemas.py
│   ├── services/
│   │   ├── neo4j_service.py
│   │   ├── auth_service.py
│   │   ├── assessment_service.py
│   │   └── appointment_service.py
│   ├── routers/
│   │   ├── assessment.py
│   │   ├── appointment.py
│   │   └── admin.py
│   ├── utils/
│   │   ├── security.py
│   │   └── scoring.py
│   └── scripts/
│       └── init_db.py
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── assets/
│   │   └── images/
│   └── pubspec.yaml
├── ARCHITECTURE.md
└── README.md
```

---

## 🧪 Testing

### Backend
```bash
# Test API endpoints
curl http://localhost:8000/health

# Test admin login
curl -X POST http://localhost:8000/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"counselor@msu.edu.ph","password":"Admin@2024"}'
```

### Flutter
```bash
flutter test
```

---

## 🚢 Deployment

### Backend (Recommended: Railway, Render, or DigitalOcean)
1. Set up Neo4j Aura database
2. Configure environment variables
3. Deploy FastAPI application
4. Update CORS settings

### Flutter
- **Mobile**: Build APK/IPA and distribute
- **Web**: Deploy to Firebase Hosting, Netlify, or Vercel

---

## 📝 Default Credentials

**Counselor Account** (created by init_db.py):
- Email: `counselor@msu.edu.ph`
- Password: `Admin@2024`

⚠️ **Change this password in production!**

---

## 🎯 Key Implementation Notes

### Assessment Scoring
- Q8 in Section 3 is automatically reversed in `assessment_service.py`
- Scoring logic is in `utils/scoring.py`

### Appointment Booking
- No client authentication required
- Personal details collected during booking
- Linked to assessment via `submission_id`

### Real-time Updates
- Implement WebSocket or polling for appointment status
- Email notifications can be added via SMTP configuration

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

---

## 📄 License

This project is developed for Mindanao State University.

---

## 👥 Support

For issues or questions:
- Check API documentation at `/docs`
- Review ARCHITECTURE.md for technical details
- Contact system administrator

---

**Built with ❤️ for MSU Guidance and Counseling**
