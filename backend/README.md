# Guidance and Counseling System - Backend

FastAPI backend with Neo4j Aura database for anonymous self-assessment and appointment scheduling.

## Setup

### 1. Install Dependencies

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure Environment

Copy `.env.example` to `.env` and fill in your credentials:

```bash
cp .env.example .env
```

Edit `.env`:
```
NEO4J_URI=neo4j+s://xxxxx.databases.neo4j.io
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your_password
SECRET_KEY=your-secret-key
```

Generate a secure SECRET_KEY:
```bash
openssl rand -hex 32
```

### 3. Initialize Database

Create a counselor account (run Python shell):

```python
from services.auth_service import auth_service

auth_service.create_counselor(
    full_name="Dr. Jane Smith",
    email="counselor@university.edu",
    employee_id="EMP001",
    specialization="Mental Health",
    password="secure_password"
)
```

### 4. Run the Server

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

API will be available at: `http://localhost:8000`
API Documentation: `http://localhost:8000/docs`

## API Endpoints

### Client Endpoints (No Auth)
- `GET /assessment/questions` - Get questionnaire
- `POST /assessment/submit` - Submit assessment
- `GET /appointment/counselors/available` - List counselors
- `POST /appointment/book` - Book appointment
- `GET /appointment/status/{email}` - Check status

### Admin Endpoints (JWT Required)
- `POST /admin/login` - Login
- `GET /admin/assessments` - View all assessments
- `GET /admin/appointment/{id}` - View appointment details
- `PUT /admin/appointment/{id}/status` - Update status
- `POST /admin/slots` - Create time slot
- `GET /admin/appointments` - List counselor's appointments

## Testing

Test the API:
```bash
# Get questions
curl http://localhost:8000/assessment/questions

# Admin login
curl -X POST http://localhost:8000/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"counselor@university.edu","password":"secure_password"}'
```
