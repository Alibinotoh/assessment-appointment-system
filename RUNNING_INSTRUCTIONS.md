# 🚀 Running Instructions

## ✅ System is Ready!

Both backend and frontend are configured and ready to run.

---

## 🖥️ Start Backend Server

### Option 1: Using start script
```bash
cd backend
./start.sh
```

### Option 2: Manual start
```bash
cd backend
source venv/bin/activate
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Backend will run at:** http://localhost:8000
**API Docs:** http://localhost:8000/docs

---

## 📱 Start Flutter App

### For Web (Chrome)
```bash
cd flutter_app
flutter run -d chrome --web-port=3000
```

**App will open at:** http://localhost:3000

### For Linux Desktop
```bash
cd flutter_app
flutter run -d linux
```

### For Android/iOS
Connect your device and run:
```bash
cd flutter_app
flutter run
```

---

## 🔑 Login Credentials

**Counselor Account:**
- Email: `counselor@msu.edu.ph`
- Password: `Admin2024!`

---

## 🧪 Test the Complete Flow

### 1. Client Flow (No Login Required)
1. Open the Flutter app
2. Click **"Start Assessment"**
3. Complete all 30 questions across 3 sections
4. View your results and stress level
5. Click **"Book an Appointment"**
6. Select a counselor and time slot
7. Fill in your personal details
8. Submit the booking

### 2. Counselor Flow (Login Required)
1. On welcome screen, click **"Counselor Login"**
2. Login with credentials above
3. View dashboard with pending appointments
4. Click on an appointment to see details
5. View the linked assessment results
6. Confirm or reject the appointment

---

## 📊 API Endpoints

### Test with curl:

**Health Check:**
```bash
curl http://localhost:8000/health
```

**Get Questions:**
```bash
curl http://localhost:8000/assessment/questions
```

**Login:**
```bash
curl -X POST http://localhost:8000/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"counselor@msu.edu.ph","password":"Admin2024!"}'
```

---

## ⚠️ Important Notes

### Backend
- **Port 8000** must be available
- If port is in use, kill the process: `lsof -i :8000` then `kill -9 <PID>`
- Backend must be running before testing the Flutter app

### Flutter
- **Placeholder images** are currently in use
- Replace `assets/images/logo.png` with actual MSU logo
- Replace `assets/images/background.jpg` with Student Center photo
- Web runs on port 3000 by default

### Database
- Neo4j Aura connection is configured
- 49 time slots are pre-created
- Assessments and appointments will be stored automatically

---

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check if venv is activated
source venv/bin/activate

# Reinstall dependencies if needed
pip install -r requirements.txt
```

### Flutter build errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -d chrome
```

### Can't connect to backend from Flutter
- Check backend is running: http://localhost:8000/health
- Verify API URL in `lib/config/api_config.dart`
- Check CORS settings in backend

### Images not showing
- Ensure files exist in `assets/images/`
- Run `flutter pub get` after adding images
- Restart the app

---

## 📁 Project URLs

When both are running:

- **Backend API:** http://localhost:8000
- **API Documentation:** http://localhost:8000/docs
- **Flutter Web App:** http://localhost:3000
- **Neo4j Aura:** https://console.neo4j.io

---

## 🎯 Next Steps

1. ✅ Backend is running on port 8000
2. ✅ Flutter app is running on port 3000
3. ⚠️ Replace placeholder images with actual photos
4. ✅ Test the complete assessment and booking flow
5. ⚠️ Change default password before production

**Everything is ready to use!** 🎉

---

## 💡 Tips

- Keep both terminal windows open (backend and frontend)
- Use Chrome DevTools (F12) to debug Flutter web app
- Check backend logs for API errors
- Use `/docs` endpoint to test API directly

**Happy Testing!** 🚀
