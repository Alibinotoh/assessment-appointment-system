"""
Database initialization script
Creates initial counselor account and sample time slots
"""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from services.auth_service import auth_service
from services.appointment_service import appointment_service
from models.schemas import TimeSlotCreate
from datetime import date, time, timedelta

def create_initial_counselor():
    """Create the first counselor account"""
    print("Creating initial counselor account...")
    
    counselor_id = auth_service.create_counselor(
        full_name="Dr. Maria Santos",
        email="counselor@msu.edu.ph",
        employee_id="MSU-2024-001",
        specialization="Mental Health and Wellness",
        password="Admin2024!"  # Change this in production!
    )
    
    print(f"✅ Counselor created with ID: {counselor_id}")
    print(f"   Email: counselor@msu.edu.ph")
    print(f"   Password: Admin2024!")
    
    return counselor_id

def create_sample_slots(counselor_id: str):
    """Create sample time slots for the next 7 days"""
    print("\nCreating sample time slots...")
    
    today = date.today()
    
    # Create slots for next 7 days (9 AM - 5 PM, 1-hour slots)
    for day_offset in range(1, 8):
        target_date = today + timedelta(days=day_offset)
        
        # Morning slots
        for hour in [9, 10, 11]:
            slot = TimeSlotCreate(
                date=target_date,
                start_time=time(hour, 0),
                end_time=time(hour + 1, 0)
            )
            appointment_service.create_time_slot(counselor_id, slot)
        
        # Afternoon slots
        for hour in [13, 14, 15, 16]:
            slot = TimeSlotCreate(
                date=target_date,
                start_time=time(hour, 0),
                end_time=time(hour + 1, 0)
            )
            appointment_service.create_time_slot(counselor_id, slot)
    
    print(f"✅ Created 49 time slots (7 days × 7 slots/day)")

if __name__ == "__main__":
    print("=" * 60)
    print("Guidance and Counseling System - Database Initialization")
    print("=" * 60)
    
    try:
        counselor_id = create_initial_counselor()
        create_sample_slots(counselor_id)
        
        print("\n" + "=" * 60)
        print("✅ Database initialized successfully!")
        print("=" * 60)
        print("\nYou can now:")
        print("1. Start the API server: uvicorn main:app --reload")
        print("2. Login at: POST /admin/login")
        print("3. Access docs at: http://localhost:8000/docs")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)
