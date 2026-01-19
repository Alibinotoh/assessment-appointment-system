from services.neo4j_service import neo4j_service
from utils.scoring import calculate_assessment_score, reverse_score_for_q8
from models.schemas import AssessmentAnswers, AssessmentSubmitResponse
from datetime import datetime
import uuid
import json

class AssessmentService:
    
    @staticmethod
    def get_questions() -> dict:
        """
        Return the assessment questionnaire structure
        """
        return {
            "section1": {
                "title": "Mental Health Quality",
                "description": "Rate your current state (Excellent to Poor)",
                "questions": [
                    {"id": "q1", "text": "Rate your mental wellbeing", "valence": "positive"},
                    {"id": "q2", "text": "Your mood for the past 2 weeks", "valence": "positive"},
                    {"id": "q3", "text": "Your outlook in life", "valence": "positive"},
                    {"id": "q4", "text": "Intrapersonal relationship", "valence": "positive"},
                    {"id": "q5", "text": "Feelings towards your surroundings", "valence": "positive"},
                    {"id": "q6", "text": "Sleep cycle", "valence": "positive"},
                    {"id": "q7", "text": "Sleep quality", "valence": "positive"},
                    {"id": "q8", "text": "Relationship with family", "valence": "positive"},
                    {"id": "q9", "text": "Relationship with friends", "valence": "positive"},
                    {"id": "q10", "text": "Physical Health", "valence": "positive"}
                ],
                "options": [
                    {"value": 1, "label": "Excellent"},
                    {"value": 2, "label": "Good"},
                    {"value": 3, "label": "Fair"},
                    {"value": 4, "label": "Bad"},
                    {"value": 5, "label": "Poor"}
                ]
            },
            "section2": {
                "title": "University Life",
                "description": "Answer YES or NO",
                "questions": [
                    {"id": "q1", "text": "Are you finding it easy to adjust to your new environment?", "valence": "positive"},
                    {"id": "q2", "text": "Are you happy with your current course?", "valence": "positive"},
                    {"id": "q3", "text": "Do you feel productive with your course?", "valence": "positive"},
                    {"id": "q4", "text": "Are you satisfied with your current academic performance?", "valence": "positive"},
                    {"id": "q5", "text": "Are your professors/instructors approachable and understanding?", "valence": "positive"},
                    {"id": "q6", "text": "Is your allowance sufficient for your needs?", "valence": "positive"},
                    {"id": "q7", "text": "Do you feel safe and at ease on campus?", "valence": "positive"},
                    {"id": "q8", "text": "Are you comfortable making new friends at university?", "valence": "positive"},
                    {"id": "q9", "text": "Have you felt sense of personal growth or development since starting university?", "valence": "positive"},
                    {"id": "q10", "text": "Do you feel like you have a good work-life balance?", "valence": "positive"}
                ],
                "options": [
                    {"value": 1, "label": "YES"},
                    {"value": 5, "label": "NO"}
                ]
            },
            "section3": {
                "title": "Self Assessment",
                "description": "How often do you experience these? (Not at all/Never to Very Much/Always)",
                "questions": [
                    {"id": "q1", "text": "Are you having a difficulty coping with your stressors?", "valence": "negative"},
                    {"id": "q2", "text": "Do people's perception about you affects you?", "valence": "negative"},
                    {"id": "q3", "text": "Does your medical health or mental wellbeing limits your daily productivity?", "valence": "negative"},
                    {"id": "q4", "text": "Do you have trouble sleeping?", "valence": "negative"},
                    {"id": "q5", "text": "Do you smoke cigarettes/e-cigars?", "valence": "negative"},
                    {"id": "q6", "text": "Do you drink liquors?", "valence": "negative"},
                    {"id": "q7", "text": "Do you get in conflict with your partner or family members?", "valence": "negative"},
                    {"id": "q8", "text": "Do you feel calmness and happiness?", "valence": "positive", "note": "REVERSED SCORING"},
                    {"id": "q9", "text": "Do you feel sad and depress?", "valence": "negative"},
                    {"id": "q10", "text": "Do you feel angry and aggressive?", "valence": "negative"}
                ],
                "options": [
                    {"value": 1, "label": "Not at all/Never"},
                    {"value": 2, "label": "Rarely"},
                    {"value": 3, "label": "Sometimes"},
                    {"value": 4, "label": "Often"},
                    {"value": 5, "label": "Very Much/Always"}
                ]
            }
        }
    
    @staticmethod
    def submit_assessment(answers: AssessmentAnswers) -> AssessmentSubmitResponse:
        """
        Process and store assessment submission
        """
        # Reverse Q8 in Section 3 (positive question in negative section)
        section3_processed = answers.section3.copy()
        if "q8" in section3_processed:
            section3_processed["q8"] = reverse_score_for_q8(section3_processed["q8"])
        
        # Calculate scores
        s1_score, s2_score, s3_score, overall, stress_level, recommendation = calculate_assessment_score(
            answers.section1,
            answers.section2,
            section3_processed
        )
        
        # Generate submission ID
        submission_id = str(uuid.uuid4())
        timestamp = datetime.utcnow()
        
        # Store in Neo4j (convert dicts to JSON strings)
        query = """
        CREATE (a:AssessmentSubmission {
            submission_id: $submission_id,
            timestamp: datetime($timestamp),
            section1_raw_answers: $section1_raw,
            section2_raw_answers: $section2_raw,
            section3_raw_answers: $section3_raw,
            section1_score: $section1_score,
            section2_score: $section2_score,
            section3_score: $section3_score,
            overall_score: $overall_score,
            stress_level: $stress_level,
            recommendation: $recommendation
        })
        RETURN a.submission_id as submission_id
        """
        
        neo4j_service.execute_write(query, {
            "submission_id": submission_id,
            "timestamp": timestamp.isoformat(),
            "section1_raw": json.dumps(answers.section1),
            "section2_raw": json.dumps(answers.section2),
            "section3_raw": json.dumps(section3_processed),
            "section1_score": s1_score,
            "section2_score": s2_score,
            "section3_score": s3_score,
            "overall_score": overall,
            "stress_level": stress_level,
            "recommendation": recommendation
        })
        
        return AssessmentSubmitResponse(
            submission_id=submission_id,
            section1_score=s1_score,
            section2_score=s2_score,
            section3_score=s3_score,
            overall_score=overall,
            stress_level=stress_level,
            recommendation=recommendation,
            timestamp=timestamp
        )

assessment_service = AssessmentService()
