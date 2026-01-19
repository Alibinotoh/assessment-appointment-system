from pydantic import BaseModel, EmailStr, Field
from typing import Dict, Optional, List
from datetime import datetime, date, time
from enum import Enum

# ============= ENUMS =============
class AppointmentStatus(str, Enum):
    PENDING = "Pending"
    CONFIRMED = "Confirmed"
    REJECTED = "Rejected"
    COMPLETED = "Completed"

class StressLevel(str, Enum):
    LOW = "Low"
    MODERATE = "Moderate"
    HIGH = "High"

# ============= ASSESSMENT SCHEMAS =============
class AssessmentAnswers(BaseModel):
    section1: Dict[str, int] = Field(..., description="Q1-Q10 with scores 1-5")
    section2: Dict[str, int] = Field(..., description="Q1-Q10 with scores 1 or 5")
    section3: Dict[str, int] = Field(..., description="Q1-Q10 with scores 1-5")

class AssessmentSubmitRequest(BaseModel):
    answers: AssessmentAnswers

class AssessmentSubmitResponse(BaseModel):
    submission_id: str
    section1_score: float
    section2_score: float
    section3_score: float
    overall_score: float
    stress_level: StressLevel
    recommendation: str
    timestamp: datetime

# ============= APPOINTMENT SCHEMAS =============
class ClientDetails(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    student_id: Optional[str] = None
    course: str = Field(..., min_length=2, max_length=100)
    year_level: str = Field(..., min_length=1, max_length=20)
    gender: str = Field(..., min_length=4, max_length=20)
    age: int = Field(..., ge=15, le=100)
    contact_number: Optional[str] = None

class AppointmentBookRequest(BaseModel):
    submission_id: str
    counselor_id: str
    slot_id: str
    client_details: ClientDetails

class AppointmentBookResponse(BaseModel):
    appointment_id: str
    status: AppointmentStatus
    scheduled_date: date
    scheduled_time: time
    counselor_name: str
    message: str

class AppointmentStatusResponse(BaseModel):
    appointment_id: str
    status: AppointmentStatus
    scheduled_date: date
    scheduled_time: time
    counselor_name: str
    counselor_email: str
    created_at: datetime
    counselor_notes: Optional[str] = None
    rejection_reason: Optional[str] = None

# ============= ADMIN SCHEMAS =============
class AdminLoginRequest(BaseModel):
    email: EmailStr
    password: str

class AdminLoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    counselor_id: str
    full_name: str
    email: str

class AppointmentDetailResponse(BaseModel):
    # Appointment Info
    appointment_id: str
    status: AppointmentStatus
    scheduled_date: date
    scheduled_time: time
    created_at: datetime
    counselor_notes: Optional[str]
    rejection_reason: Optional[str]
    
    # Client Details
    client_full_name: str
    client_email: str
    client_student_id: Optional[str]
    client_course: str
    client_year_level: str
    client_gender: str
    client_age: int
    client_contact_number: Optional[str]
    
    # Linked Assessment Details
    assessment_submission_id: str
    assessment_timestamp: datetime
    section1_raw_answers: str  # JSON string
    section2_raw_answers: str  # JSON string
    section3_raw_answers: str  # JSON string
    section1_score: float
    section2_score: float
    section3_score: float
    overall_score: float
    stress_level: StressLevel
    recommendation: str

class UpdateAppointmentStatusRequest(BaseModel):
    status: AppointmentStatus
    counselor_notes: Optional[str] = None
    rejection_reason: Optional[str] = None

class CounselorAvailability(BaseModel):
    counselor_id: str
    full_name: str
    specialization: str
    email: str
    available_slots: List[dict]

class TimeSlotCreate(BaseModel):
    date: date
    start_time: time
    end_time: time
