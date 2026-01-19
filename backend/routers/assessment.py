from fastapi import APIRouter, HTTPException
from models.schemas import AssessmentSubmitRequest, AssessmentSubmitResponse
from services.assessment_service import assessment_service

router = APIRouter()

@router.get("/questions")
async def get_questions():
    """
    Get the assessment questionnaire
    No authentication required
    """
    return assessment_service.get_questions()

@router.post("/submit", response_model=AssessmentSubmitResponse)
async def submit_assessment(request: AssessmentSubmitRequest):
    """
    Submit assessment answers and get results
    No authentication required
    """
    try:
        return assessment_service.submit_assessment(request.answers)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
