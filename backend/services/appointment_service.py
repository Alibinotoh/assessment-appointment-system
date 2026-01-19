from services.neo4j_service import neo4j_service
from models.schemas import (
    TimeSlotCreate, AppointmentBookRequest, AppointmentBookResponse,
    AppointmentDetailResponse, AppointmentStatusResponse,
    UpdateAppointmentStatusRequest, CounselorAvailability
)
from datetime import datetime, date, time
from fastapi import HTTPException, status
import uuid
import json

class AppointmentService:
    
    @staticmethod
    def json_converter(obj):
        if isinstance(obj, (datetime, date, time)):
            return obj.isoformat()
        raise TypeError(f'Object of type {obj.__class__.__name__} '
                        f'is not JSON serializable')

    @staticmethod
    def get_available_counselors(target_date: date = None) -> list[CounselorAvailability]:
        """
        Get all counselors with their available time slots
        """
        date_filter = ""
        params = {}
        
        if target_date:
            date_filter = "AND date(ts.date) = date($target_date)"
            params["target_date"] = target_date.isoformat()
        
        query = f"""
        MATCH (c:Counselor)-[:HAS_SLOT]->(ts:TimeSlot)
        WHERE ts.is_available = true {date_filter}
        WITH c, ts
        ORDER BY ts.date, ts.start_time
        RETURN c.counselor_id as counselor_id,
               c.full_name as full_name,
               c.specialization as specialization,
               c.email as email,
               collect({{
                   slot_id: ts.slot_id,
                   date: toString(ts.date),
                   start_time: toString(ts.start_time),
                   end_time: toString(ts.end_time)
               }}) as available_slots
        """
        
        results = neo4j_service.execute_query(query, params)
        
        return [
            CounselorAvailability(
                counselor_id=r["counselor_id"],
                full_name=r["full_name"],
                specialization=r["specialization"],
                email=r["email"],
                available_slots=r["available_slots"]
            )
            for r in results
        ]
    
    @staticmethod
    def book_appointment(request: AppointmentBookRequest) -> AppointmentBookResponse:
        """
        Create a new appointment booking
        """
        appointment_id = str(uuid.uuid4())
        
        # Verify submission exists
        verify_query = """
        MATCH (a:AssessmentSubmission {submission_id: $submission_id})
        RETURN a.submission_id as submission_id
        """
        assessment = neo4j_service.execute_query(verify_query, {"submission_id": request.submission_id})
        
        if not assessment:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Assessment submission not found"
            )
        
        # Create appointment with relationships
        query = """
        MATCH (a:AssessmentSubmission {submission_id: $submission_id})
        MATCH (c:Counselor {counselor_id: $counselor_id})
        MATCH (ts:TimeSlot {slot_id: $slot_id})
        WHERE ts.is_available = true
        
        CREATE (apt:Appointment {
            appointment_id: $appointment_id,
            created_at: datetime(),
            scheduled_date: date($scheduled_date),
            scheduled_time: time($scheduled_time),
            status: 'Pending',
            counselor_notes: '',
            client_full_name: $client_full_name,
            client_email: $client_email,
            client_student_id: $client_student_id,
            client_course: $client_course,
            client_year_level: $client_year_level,
            client_gender: $client_gender,
            client_age: $client_age,
            client_contact_number: $client_contact_number
        })
        
        CREATE (apt)-[:BASED_ON_ASSESSMENT]->(a)
        CREATE (apt)-[:ASSIGNED_TO]->(c)
        CREATE (apt)-[:OCCUPIES_SLOT]->(ts)
        
        SET ts.is_available = false
        
        RETURN apt.appointment_id as appointment_id,
               toString(apt.scheduled_date) as scheduled_date,
               toString(apt.scheduled_time) as scheduled_time,
               c.full_name as counselor_name
        """
        
        # Extract date and time from slot
        slot_query = """
        MATCH (ts:TimeSlot {slot_id: $slot_id})
        RETURN toString(ts.date) as date, toString(ts.start_time) as start_time
        """
        slot_info = neo4j_service.execute_query(slot_query, {"slot_id": request.slot_id})
        
        if not slot_info:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Time slot not found"
            )
        
        result = neo4j_service.execute_write(query, {
            "appointment_id": appointment_id,
            "submission_id": request.submission_id,
            "counselor_id": request.counselor_id,
            "slot_id": request.slot_id,
            "scheduled_date": slot_info[0]["date"],
            "scheduled_time": slot_info[0]["start_time"],
            "client_full_name": request.client_details.full_name,
            "client_email": request.client_details.email,
            "client_student_id": request.client_details.student_id,
            "client_course": request.client_details.course,
            "client_year_level": request.client_details.year_level,
            "client_gender": request.client_details.gender,
            "client_age": request.client_details.age,
            "client_contact_number": request.client_details.contact_number
        })
        
        return AppointmentBookResponse(
            appointment_id=result["appointment_id"],
            status="Pending",
            scheduled_date=result["scheduled_date"],
            scheduled_time=result["scheduled_time"],
            counselor_name=result["counselor_name"],
            message="Appointment booked successfully. You will receive a confirmation email soon."
        )
    
    @staticmethod
    def get_appointment_status_by_email(email: str) -> list[AppointmentStatusResponse]:
        """
        Get all appointments for a client by email
        """
        query = """
        MATCH (apt:Appointment {client_email: $email})-[:ASSIGNED_TO]->(c:Counselor)
        RETURN apt.appointment_id as appointment_id,
               apt.status as status,
               toString(apt.scheduled_date) as scheduled_date,
               toString(apt.scheduled_time) as scheduled_time,
               toString(apt.created_at) as created_at,
               apt.counselor_notes as counselor_notes,
               apt.rejection_reason as rejection_reason,
               c.full_name as counselor_name,
               c.email as counselor_email
        ORDER BY apt.created_at DESC
        """
        
        results = neo4j_service.execute_query(query, {"email": email})
        
        return [
            AppointmentStatusResponse(
                appointment_id=r["appointment_id"],
                status=r["status"],
                scheduled_date=r["scheduled_date"],
                scheduled_time=r["scheduled_time"],
                created_at=r["created_at"],
                counselor_notes=r.get("counselor_notes"),
                rejection_reason=r.get("rejection_reason"),
                counselor_name=r["counselor_name"],
                counselor_email=r["counselor_email"]
            )
            for r in results
        ]
    
    @staticmethod
    def get_appointment_detail(appointment_id: str) -> AppointmentDetailResponse:
        """
        Get full appointment details including linked assessment (Admin only)
        """
        query = """
        MATCH (apt:Appointment {appointment_id: $appointment_id})-[:BASED_ON_ASSESSMENT]->(a:AssessmentSubmission)
        MATCH (apt)-[:ASSIGNED_TO]->(c:Counselor)
        RETURN apt.appointment_id as appointment_id,
               apt.status as status,
               toString(apt.scheduled_date) as scheduled_date,
               toString(apt.scheduled_time) as scheduled_time,
               toString(apt.created_at) as created_at,
               apt.counselor_notes as counselor_notes,
               apt.rejection_reason as rejection_reason,
               apt.client_full_name as client_full_name,
               apt.client_email as client_email,
               apt.client_student_id as client_student_id,
               apt.client_course as client_course,
               apt.client_year_level as client_year_level,
               apt.client_gender as client_gender,
               apt.client_age as client_age,
               apt.client_contact_number as client_contact_number,
               a.submission_id as assessment_submission_id,
               toString(a.timestamp) as assessment_timestamp,
               a.section1_raw_answers as section1_raw_answers,
               a.section2_raw_answers as section2_raw_answers,
               a.section3_raw_answers as section3_raw_answers,
               a.section1_score as section1_score,
               a.section2_score as section2_score,
               a.section3_score as section3_score,
               a.overall_score as overall_score,
               a.stress_level as stress_level,
               a.recommendation as recommendation
        """
        
        result = neo4j_service.execute_query(query, {"appointment_id": appointment_id})
        
        if not result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Appointment not found"
            )
        
        r = result[0]
        # Keep JSON strings as-is, don't parse them
        return AppointmentDetailResponse(**r)
    
    @staticmethod
    def update_appointment_status(appointment_id: str, request: UpdateAppointmentStatusRequest) -> dict:
        """
        Update appointment status (Admin only)
        """
        query = """
        MATCH (apt:Appointment {appointment_id: $appointment_id})
        SET apt.status = $status,
            apt.counselor_notes = $counselor_notes,
            apt.rejection_reason = $rejection_reason
        RETURN apt.appointment_id as appointment_id,
               apt.status as status,
               apt.client_email as client_email
        """
        
        result = neo4j_service.execute_write(query, {
            "appointment_id": appointment_id,
            "status": request.status.value,
            "counselor_notes": request.counselor_notes or "",
            "rejection_reason": request.rejection_reason or ""
        })
        
        if not result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Appointment not found"
            )
        
        # TODO: Send email notification to client
        # notification_service.send_status_update(result["client_email"], request.status)
        
        return result
    
    @staticmethod
    def create_time_slot(counselor_id: str, slot: TimeSlotCreate) -> dict:
        """
        Create a new time slot for a counselor (Admin only)
        """
        slot_id = str(uuid.uuid4())
        
        query = """
        MATCH (c:Counselor {counselor_id: $counselor_id})
        CREATE (ts:TimeSlot {
            slot_id: $slot_id,
            date: date($date),
            start_time: time($start_time),
            end_time: time($end_time),
            is_available: true
        })
        CREATE (c)-[:HAS_SLOT]->(ts)
        RETURN ts.slot_id as slot_id
        """
        
        result = neo4j_service.execute_write(query, {
            "counselor_id": counselor_id,
            "slot_id": slot_id,
            "date": slot.date.isoformat(),
            "start_time": slot.start_time.isoformat(),
            "end_time": slot.end_time.isoformat()
        })
        
        if result:
            return result
        else:
            return {"slot_id": slot_id}

appointment_service = AppointmentService()
