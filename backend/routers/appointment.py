from fastapi import APIRouter, HTTPException, Query
from models.schemas import (
    AppointmentBookRequest, AppointmentBookResponse,
    AppointmentStatusResponse
)
from services.appointment_service import appointment_service
from datetime import date
from typing import Optional

router = APIRouter()

@router.get("/counselors/available")
async def get_available_counselors(date: Optional[str] = Query(None)):
    """
    Get all counselors with their available time slots
    No authentication required
    """
    target_date = None
    if date:
        try:
            target_date = date.fromisoformat(date)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD")
    
    return appointment_service.get_available_counselors(target_date)

@router.post("/book", response_model=AppointmentBookResponse)
async def book_appointment(request: AppointmentBookRequest):
    """
    Book an appointment
    No authentication required - client provides personal details directly
    """
    try:
        return appointment_service.book_appointment(request)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/status/{email}")
async def get_appointment_status(email: str):
    """
    Check appointment status by email
    No authentication required
    """
    appointments = appointment_service.get_appointment_status_by_email(email)
    
    if not appointments:
        raise HTTPException(
            status_code=404,
            detail="No appointments found for this email"
        )
    
    return appointments
