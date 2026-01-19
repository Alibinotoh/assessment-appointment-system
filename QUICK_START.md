# Quick Start Guide

## ✅ Backend Setup Complete!

Your backend is now configured and ready to run.

### 🔐 Login Credentials

**Counselor Account:**
- **Email:** `counselor@msu.edu.ph`
- **Password:** `Admin2024!`

### 🚀 Start the Backend Server

```bash
cd backend
./start.sh
```

Or manually:
```bash
cd backend
source venv/bin/activate
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at:
- **API:** http://localhost:8000  
- **API Docs:** http://localhost:8000/docs
- **Health Check:** http://localhost:8000/health

### 📊 Database Info

- **Neo4j URI:** `neo4j+s://63f49743.databases.neo4j.io`
- **Status:** ✅ Connected and initialized
- **Sample Data:** 49 time slots created (7 days × 7 slots/day)

---

## 📱 Flutter App Setup

### 1. Create Asset Directories

```bash
cd flutter_app
mkdir -p assets/images
```

### 2. Add Your Images

Place these files in `flutter_app/assets/images/`:
- `logo.png` - MSU logo (from your provided image)
- `background.jpg` - Student Center building (from your provided image)

### 3. Install Flutter Dependencies

```bash
cd flutter_app
flutter pub get
```

### 4. Update API Configuration

The API is already configured to use `http://localhost:8000` in:
`flutter_app/lib/config/api_config.dart`

For physical device testing, update to your computer's IP:
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000';
```

### 5. Run the Flutter App

```bash
flutter run
```

Or for web:
```bash
flutter run -d chrome
```

---

## 🧪 Test the System

### Test Backend API

```bash
# Health check
curl http://localhost:8000/health

# Get assessment questions
curl http://localhost:8000/assessment/questions

# Login as counselor
curl -X POST http://localhost:8000/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"counselor@msu.edu.ph","password":"Admin2024!"}'
```

### Test Complete Flow

1. **Open Flutter App** → Welcome Screen appears
2. **Click "Start Assessment"** → Complete 30 questions
3. **View Results** → See stress level and score
4. **Click "Book Appointment"** → Select counselor and time slot
5. **Fill Personal Details** → Submit booking
6. **Login as Counselor** → View appointment in dashboard
7. **Confirm/Reject** → Update appointment status

---

## 📁 Project Structure

```
Assessment_Appointment_System/
├── backend/
│   ├── .env                    # ✅ Configured with Neo4j credentials
│   ├── main.py                 # FastAPI application
│   ├── start.sh                # Quick start script
│   ├── requirements.txt        # ✅ Updated dependencies
│   └── venv/                   # ✅ Virtual environment ready
├── flutter_app/
│   ├── lib/                    # Flutter source code
│   ├── assets/images/          # ⚠️ Add logo.png and background.jpg
│   └── pubspec.yaml            # Flutter dependencies
├── README.md                   # Full documentation
├── ARCHITECTURE.md             # Technical architecture
├── DEPLOYMENT_GUIDE.md         # Production deployment
└── QUICK_START.md             # This file
```

---

## ⚠️ Important Notes

1. **Port 8000:** Make sure no other service is using port 8000
2. **Assets:** Flutter app won't display images until you add them to `assets/images/`
3. **Network:** For mobile device testing, ensure phone and computer are on same network
4. **Password:** Change the default password in production!

---

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check if port is in use
lsof -i :8000

# Kill process if needed
kill -9 <PID>
```

### Neo4j connection error
- Verify credentials in `.env`
- Check internet connection
- Confirm Neo4j Aura database is running

### Flutter errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## 📞 Next Steps

1. ✅ Backend is running
2. ⚠️ Add images to `flutter_app/assets/images/`
3. ⚠️ Run `flutter pub get`
4. ⚠️ Run `flutter run`
5. ✅ Test the complete flow

**Your system is ready to use!** 🎉
