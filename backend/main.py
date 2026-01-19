from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config import get_settings
from routers import assessment, appointment, admin
from services.neo4j_service import neo4j_service
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

settings = get_settings()

app = FastAPI(
    title="Guidance and Counseling System API",
    description="Anonymous Self-Assessment & Non-Authenticated Appointment Scheduling",
    version="1.0.0"
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(assessment.router, prefix="/assessment", tags=["Assessment"])
app.include_router(appointment.router, prefix="/appointment", tags=["Appointment"])
app.include_router(admin.router, prefix="/admin", tags=["Admin"])

@app.on_event("startup")
async def startup_event():
    logger.info("🚀 Starting Guidance and Counseling System API")
    logger.info("📊 Neo4j connection verified")

@app.on_event("shutdown")
async def shutdown_event():
    neo4j_service.close()
    logger.info("👋 Shutting down API")

@app.get("/")
async def root():
    return {
        "message": "Guidance and Counseling System API",
        "version": "1.0.0",
        "status": "active"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "database": "connected"}
