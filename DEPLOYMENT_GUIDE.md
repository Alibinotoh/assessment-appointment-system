# Deployment Guide

Complete guide for deploying the MSU Guidance and Counseling System to production.

---

## 📋 Prerequisites

- Neo4j Aura account (free tier available)
- Backend hosting (Railway, Render, DigitalOcean, etc.)
- Flutter development environment
- Domain name (optional)

---

## 🗄️ Step 1: Set Up Neo4j Aura

### 1.1 Create Database

1. Go to https://neo4j.com/cloud/aura/
2. Sign up / Log in
3. Click "Create Database"
4. Select "AuraDB Free" (or paid tier)
5. Choose region closest to your users
6. Save credentials securely

### 1.2 Get Connection Details

After creation, note down:
- **URI**: `neo4j+s://xxxxx.databases.neo4j.io`
- **Username**: `neo4j`
- **Password**: (your generated password)

### 1.3 Test Connection

```bash
# Install Neo4j Python driver
pip install neo4j

# Test connection
python -c "from neo4j import GraphDatabase; driver = GraphDatabase.driver('YOUR_URI', auth=('neo4j', 'YOUR_PASSWORD')); driver.verify_connectivity(); print('✅ Connected!')"
```

---

## 🖥️ Step 2: Deploy Backend

### Option A: Railway (Recommended)

1. **Install Railway CLI**
```bash
npm install -g @railway/cli
railway login
```

2. **Initialize Project**
```bash
cd backend
railway init
```

3. **Add Environment Variables**
```bash
railway variables set NEO4J_URI="neo4j+s://xxxxx.databases.neo4j.io"
railway variables set NEO4J_USERNAME="neo4j"
railway variables set NEO4J_PASSWORD="your_password"
railway variables set SECRET_KEY="$(openssl rand -hex 32)"
railway variables set ALGORITHM="HS256"
railway variables set ACCESS_TOKEN_EXPIRE_MINUTES="1440"
railway variables set ALLOWED_ORIGINS="*"
```

4. **Deploy**
```bash
railway up
```

5. **Get URL**
```bash
railway domain
# Note the URL: https://your-app.up.railway.app
```

### Option B: Render

1. Create new Web Service on Render.com
2. Connect GitHub repository
3. Configure:
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
4. Add environment variables in Render dashboard
5. Deploy

### Option C: DigitalOcean App Platform

1. Create new App
2. Select GitHub repository
3. Configure:
   - **Type**: Web Service
   - **Run Command**: `uvicorn main:app --host 0.0.0.0 --port 8080`
4. Add environment variables
5. Deploy

---

## 🔧 Step 3: Initialize Database

### 3.1 SSH into Server (or use local connection)

```bash
# Set environment variables
export NEO4J_URI="your_uri"
export NEO4J_USERNAME="neo4j"
export NEO4J_PASSWORD="your_password"
export SECRET_KEY="your_secret_key"

# Run initialization script
cd backend
python scripts/init_db.py
```

### 3.2 Verify Initialization

```bash
# Test API
curl https://your-backend-url.com/health

# Test login
curl -X POST https://your-backend-url.com/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"counselor@msu.edu.ph","password":"Admin@2024"}'
```

---

## 📱 Step 4: Configure Flutter App

### 4.1 Update API Configuration

Edit `flutter_app/lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-backend-url.com';
  // ... rest of config
}
```

### 4.2 Add Assets

Place these files in `flutter_app/assets/images/`:
- `logo.png` - MSU logo
- `background.jpg` - Student Center building

### 4.3 Update App Info

Edit `flutter_app/pubspec.yaml`:
```yaml
name: msu_counseling
description: MSU Guidance and Counseling System
version: 1.0.0+1
```

---

## 📦 Step 5: Build Flutter App

### For Android

```bash
cd flutter_app

# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk

# Or build App Bundle for Play Store
flutter build appbundle --release
```

### For iOS

```bash
# Build iOS
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace

# Configure signing and build
```

### For Web

```bash
# Build web version
flutter build web --release

# Output: build/web/

# Deploy to hosting service
```

---

## 🌐 Step 6: Deploy Flutter Web (Optional)

### Option A: Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
cd flutter_app
firebase init hosting

# Deploy
firebase deploy --only hosting
```

### Option B: Netlify

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
cd flutter_app/build/web
netlify deploy --prod
```

### Option C: Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
cd flutter_app/build/web
vercel --prod
```

---

## 🔒 Step 7: Security Hardening

### 7.1 Update Default Password

```python
# Connect to your backend
from services.auth_service import auth_service
from utils.security import hash_password
from services.neo4j_service import neo4j_service

# Update password
query = """
MATCH (c:Counselor {email: 'counselor@msu.edu.ph'})
SET c.password_hash = $new_password_hash
"""

new_password = "YourSecurePassword123!"
neo4j_service.execute_write(query, {
    'new_password_hash': hash_password(new_password)
})
```

### 7.2 Configure CORS

Update backend `.env`:
```
ALLOWED_ORIGINS=https://your-flutter-web-url.com,https://your-domain.com
```

### 7.3 Enable HTTPS

- Railway/Render: Automatic HTTPS
- Custom domain: Configure SSL certificate

---

## 📊 Step 8: Monitoring & Maintenance

### 8.1 Set Up Logging

Add to `backend/main.py`:
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)
```

### 8.2 Database Backups

Neo4j Aura provides automatic backups. For manual backup:
1. Go to Neo4j Aura console
2. Select your database
3. Click "Backup"

### 8.3 Monitor API Health

```bash
# Set up cron job or monitoring service
curl https://your-backend-url.com/health
```

---

## 🧪 Step 9: Testing Production

### 9.1 Test Client Flow

1. Open Flutter app
2. Complete assessment
3. Book appointment
4. Verify email received

### 9.2 Test Admin Flow

1. Login as counselor
2. View appointments
3. Confirm/Reject appointment
4. Verify client receives notification

---

## 🚨 Troubleshooting

### Backend Not Connecting to Neo4j

```bash
# Check environment variables
echo $NEO4J_URI

# Test connection
python -c "from services.neo4j_service import neo4j_service; print('Connected!')"
```

### Flutter App Network Error

1. Check API URL in `api_config.dart`
2. Verify CORS settings
3. Check backend logs

### Authentication Issues

```bash
# Generate new secret key
openssl rand -hex 32

# Update in backend .env
SECRET_KEY=new_generated_key
```

---

## 📝 Post-Deployment Checklist

- [ ] Neo4j Aura database created and accessible
- [ ] Backend deployed and running
- [ ] Initial counselor account created
- [ ] Default password changed
- [ ] Flutter app configured with production API URL
- [ ] Assets (logo, background) added
- [ ] App built and distributed
- [ ] CORS configured correctly
- [ ] HTTPS enabled
- [ ] Monitoring set up
- [ ] Backup strategy in place
- [ ] Documentation updated

---

## 🆘 Support

For deployment issues:
1. Check logs: `railway logs` or hosting platform logs
2. Verify environment variables
3. Test API endpoints manually
4. Review Neo4j Aura connection

---

**Deployment Complete! 🎉**

Your MSU Guidance and Counseling System is now live!
