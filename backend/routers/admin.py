from fastapi import APIRouter, HTTPException, Depends, Query
from pydantic import BaseModel, EmailStr
from models.schemas import (
    AdminLoginRequest, AdminLoginResponse,
    AppointmentDetailResponse, UpdateAppointmentStatusRequest,
    TimeSlotCreate
)
from services.auth_service import auth_service
from services.appointment_service import appointment_service
from services.neo4j_service import neo4j_service
from utils.security import get_current_counselor

class CreateCounselorRequest(BaseModel):
    full_name: str
    email: EmailStr
    employee_id: str
    specialization: str
    password: str

router = APIRouter()

@router.post("/login", response_model=AdminLoginResponse)
async def admin_login(request: AdminLoginRequest):
    """
    Counselor/Admin login
    Returns JWT token
    """
    try:
        return auth_service.authenticate_counselor(request.email, request.password)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/assessments")
async def get_all_assessments(
    current_user: dict = Depends(get_current_counselor),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100)
):
    """
    Get all anonymous assessment submissions
    Requires authentication
    """
    query = """
    MATCH (a:AssessmentSubmission)
    RETURN a.submission_id as submission_id,
           a.timestamp as timestamp,
           a.overall_score as overall_score,
           a.stress_level as stress_level,
           a.recommendation as recommendation
    ORDER BY a.timestamp DESC
    SKIP $skip
    LIMIT $limit
    """
    
    results = neo4j_service.execute_query(query, {"skip": skip, "limit": limit})
    return results

@router.get("/appointment/{appointment_id}", response_model=AppointmentDetailResponse)
async def get_appointment_detail(
    appointment_id: str,
    current_user: dict = Depends(get_current_counselor)
):
    """
    Get full appointment details including linked assessment
    Requires authentication
    """
    return appointment_service.get_appointment_detail(appointment_id)

@router.put("/appointment/{appointment_id}/status")
async def update_appointment_status(
    appointment_id: str,
    request: UpdateAppointmentStatusRequest,
    current_user: dict = Depends(get_current_counselor)
):
    """
    Update appointment status (Confirm/Reject)
    Requires authentication
    Triggers email notification to client
    """
    result = appointment_service.update_appointment_status(appointment_id, request)
    return {
        "message": "Appointment status updated successfully",
        "appointment_id": result["appointment_id"],
        "status": result["status"]
    }

@router.post("/slots")
async def create_time_slot(
    slot: TimeSlotCreate,
    current_user: dict = Depends(get_current_counselor)
):
    """
    Create a new time slot for the authenticated counselor
    Requires authentication
    """
    result = appointment_service.create_time_slot(
        current_user["counselor_id"],
        slot
    )
    return {
        "message": "Time slot created successfully",
        "slot_id": result["slot_id"]
    }

@router.get("/appointments")
async def get_counselor_appointments(
    current_user: dict = Depends(get_current_counselor),
    status: str = Query(None)
):
    """
    Get all appointments for the authenticated counselor
    Requires authentication
    """
    query = """
    MATCH (apt:Appointment)-[:ASSIGNED_TO]->(c:Counselor {counselor_id: $counselor_id})
    WHERE $status IS NULL OR apt.status = $status
    RETURN apt.appointment_id as appointment_id,
           apt.status as status,
           toString(apt.scheduled_date) as scheduled_date,
           toString(apt.scheduled_time) as scheduled_time,
           toString(apt.created_at) as created_at,
           apt.client_full_name as client_full_name,
           apt.client_email as client_email
    ORDER BY apt.scheduled_date DESC, apt.scheduled_time DESC
    """
    
    results = neo4j_service.execute_query(query, {
        "counselor_id": current_user["counselor_id"],
        "status": status
    })
    
    return results

@router.get("/dashboard/stats")
async def get_dashboard_statistics(
    current_user: dict = Depends(get_current_counselor)
):
    """
    Get dashboard statistics for the authenticated counselor
    Returns counts and analytics data
    """
    stats_query = """
    MATCH (c:Counselor {counselor_id: $counselor_id})
    OPTIONAL MATCH (apt:Appointment)-[:ASSIGNED_TO]->(c)
    OPTIONAL MATCH (a:AssessmentSubmission)
    WITH c, 
         count(DISTINCT apt) as total_appointments,
         count(DISTINCT CASE WHEN apt.status = 'Pending' THEN apt END) as pending_appointments,
         count(DISTINCT CASE WHEN apt.status = 'Confirmed' THEN apt END) as confirmed_appointments,
         count(DISTINCT CASE WHEN apt.status = 'Rejected' THEN apt END) as rejected_appointments,
         count(DISTINCT CASE WHEN apt.status = 'Completed' THEN apt END) as completed_appointments,
         count(DISTINCT a) as total_assessments
    OPTIONAL MATCH (a2:AssessmentSubmission)
    WITH total_appointments, pending_appointments, confirmed_appointments, 
         rejected_appointments, completed_appointments, total_assessments,
         count(DISTINCT CASE WHEN a2.stress_level = 'Low' THEN a2 END) as low_stress,
         count(DISTINCT CASE WHEN a2.stress_level = 'Moderate' THEN a2 END) as moderate_stress,
         count(DISTINCT CASE WHEN a2.stress_level = 'High' THEN a2 END) as high_stress
    RETURN total_appointments, pending_appointments, confirmed_appointments,
           rejected_appointments, completed_appointments, total_assessments,
           low_stress, moderate_stress, high_stress
    """
    
    result = neo4j_service.execute_query(stats_query, {
        "counselor_id": current_user["counselor_id"]
    })
    
    return result[0] if result else {
        "total_appointments": 0,
        "pending_appointments": 0,
        "confirmed_appointments": 0,
        "rejected_appointments": 0,
        "completed_appointments": 0,
        "total_assessments": 0,
        "low_stress": 0,
        "moderate_stress": 0,
        "high_stress": 0
    }

@router.get("/counselors")
async def get_all_counselors(
    current_user: dict = Depends(get_current_counselor)
):
    """
    Get all counselors
    Requires authentication
    """
    query = """
    MATCH (c:Counselor)
    RETURN c.counselor_id as counselor_id,
           c.full_name as full_name,
           c.email as email,
           c.employee_id as employee_id,
           c.specialization as specialization,
           c.created_at as created_at
    ORDER BY c.full_name
    """
    
    results = neo4j_service.execute_query(query, {})
    return results

@router.post("/counselors")
async def create_counselor(
    request: CreateCounselorRequest,
    current_user: dict = Depends(get_current_counselor)
):
    """
    Create a new counselor
    Requires authentication
    """
    try:
        counselor_id = auth_service.create_counselor(
            full_name=request.full_name,
            email=request.email,
            employee_id=request.employee_id,
            specialization=request.specialization,
            password=request.password
        )
        return {
            "message": "Counselor created successfully",
            "counselor_id": counselor_id
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/counselors/{counselor_id}")
async def delete_counselor(
    counselor_id: str,
    current_user: dict = Depends(get_current_counselor)
):
    """
    Delete a counselor
    Requires authentication
    """
    query = """
    MATCH (c:Counselor {counselor_id: $counselor_id})
    DETACH DELETE c
    RETURN count(c) as deleted
    """
    
    result = neo4j_service.execute_write(query, {"counselor_id": counselor_id})
    
    if result and result.get('deleted', 0) > 0:
        return {"message": "Counselor deleted successfully"}
    else:
        raise HTTPException(status_code=404, detail="Counselor not found")

@router.get("/slots")
async def get_all_slots(
    current_user: dict = Depends(get_current_counselor),
    start_date: str = Query(None),
    end_date: str = Query(None)
):
    """
    Get all time slots for the authenticated counselor
    Optionally filter by date range
    """
    date_filter = ""
    params = {"counselor_id": current_user["counselor_id"]}
    
    if start_date and end_date:
        date_filter = "AND date(ts.date) >= date($start_date) AND date(ts.date) <= date($end_date)"
        params["start_date"] = start_date
        params["end_date"] = end_date
    
    query = f"""
    MATCH (c:Counselor {{counselor_id: $counselor_id}})-[:HAS_SLOT]->(ts:TimeSlot)
    WHERE 1=1 {date_filter}
    OPTIONAL MATCH (apt:Appointment)-[:OCCUPIES_SLOT]->(ts)
    RETURN ts.slot_id as slot_id,
           toString(ts.date) as date,
           toString(ts.start_time) as start_time,
           toString(ts.end_time) as end_time,
           ts.is_available as is_available,
           apt.appointment_id as appointment_id,
           apt.client_full_name as client_name,
           apt.status as appointment_status
    ORDER BY ts.date, ts.start_time
    """
    
    results = neo4j_service.execute_query(query, params)
    return results

@router.delete("/slots/{slot_id}")
async def delete_slot(
    slot_id: str,
    current_user: dict = Depends(get_current_counselor)
):
    """
    Delete a time slot
    Only if it's not occupied by an appointment
    """
    query = """
    MATCH (ts:TimeSlot {slot_id: $slot_id})
    OPTIONAL MATCH (apt:Appointment)-[:OCCUPIES_SLOT]->(ts)
    WITH ts, apt
    WHERE apt IS NULL
    DETACH DELETE ts
    RETURN count(ts) as deleted
    """
    
    result = neo4j_service.execute_write(query, {"slot_id": slot_id})
    
    if result and result.get('deleted', 0) > 0:
        return {"message": "Time slot deleted successfully"}
    else:
        raise HTTPException(status_code=400, detail="Cannot delete slot with existing appointment")

@router.get("/analytics")
async def get_analytics(
    current_user: dict = Depends(get_current_counselor),
    period: str = Query('7days')
):
    """
    Get analytics data for assessments
    Period: 7days, 30days, 90days, all
    """
    # Calculate date filter based on period
    date_filter = ""
    if period == '7days':
        date_filter = "AND a.timestamp >= datetime() - duration('P7D')"
    elif period == '30days':
        date_filter = "AND a.timestamp >= datetime() - duration('P30D')"
    elif period == '90days':
        date_filter = "AND a.timestamp >= datetime() - duration('P90D')"
    
    query = f"""
    MATCH (a:AssessmentSubmission)
    WHERE 1=1 {date_filter}
    WITH count(a) as total_assessments,
         avg(a.overall_score) as average_score,
         count(CASE WHEN a.stress_level = 'High' THEN 1 END) as high_stress_count,
         count(CASE WHEN a.stress_level = 'Low' THEN 1 END) as low_stress,
         count(CASE WHEN a.stress_level = 'Moderate' THEN 1 END) as moderate_stress,
         count(CASE WHEN a.stress_level = 'High' THEN 1 END) as high_stress
    RETURN total_assessments,
           average_score,
           high_stress_count,
           low_stress,
           moderate_stress,
           high_stress,
           100.0 as completion_rate
    """
    
    result = neo4j_service.execute_query(query, {})
    
    return result[0] if result else {
        "total_assessments": 0,
        "average_score": 0.0,
        "high_stress_count": 0,
        "low_stress": 0,
        "moderate_stress": 0,
        "high_stress": 0,
        "completion_rate": 0.0
    }
