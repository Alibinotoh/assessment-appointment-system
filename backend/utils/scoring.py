from typing import Dict, Tuple

def calculate_assessment_score(
    section1_answers: Dict[str, int],
    section2_answers: Dict[str, int],
    section3_answers: Dict[str, int]
) -> Tuple[float, float, float, float, str, str]:
    """
    Calculate assessment scores based on the provided scoring methodology.
    
    Section 1 (Mental Health Quality): Positive questions, Excellent(1) → Poor(5)
    Section 2 (University Life): Positive questions, YES(1) → NO(5)
    Section 3 (Self/Negative Symptoms): Negative questions, Not at all(1) → Very Much(5)
                                        EXCEPT Q8 (reversed): Not at all(5) → Very Much(1)
    
    Returns:
        (section1_score, section2_score, section3_score, overall_score, stress_level, recommendation)
    """
    
    # Section 1: Sum all answers, divide by 10
    section1_sum = sum(section1_answers.values())
    section1_score = section1_sum / 10.0
    
    # Section 2: Sum all answers, divide by 10
    section2_sum = sum(section2_answers.values())
    section2_score = section2_sum / 10.0
    
    # Section 3: Sum all answers (Q8 already reversed in input), divide by 10
    section3_sum = sum(section3_answers.values())
    section3_score = section3_sum / 10.0
    
    # Overall Score: Average of three sections
    overall_score = (section1_score + section2_score + section3_score) / 3.0
    
    # Determine Stress Level
    if overall_score <= 2.33:
        stress_level = "Low"
        recommendation = (
            "Your assessment indicates a low stress level. You're managing well! "
            "Continue maintaining healthy habits and reach out if you need support."
        )
    elif overall_score <= 3.66:
        stress_level = "Moderate"
        recommendation = (
            "Your assessment indicates a moderate stress level. Consider speaking with a counselor "
            "to discuss strategies for managing stress and improving your well-being."
        )
    else:
        stress_level = "High"
        recommendation = (
            "Your assessment indicates a high stress level. We strongly recommend booking an appointment "
            "with a counselor to discuss your concerns and develop a support plan."
        )
    
    return (
        round(section1_score, 2),
        round(section2_score, 2),
        round(section3_score, 2),
        round(overall_score, 2),
        stress_level,
        recommendation
    )

def reverse_score_for_q8(answer: int) -> int:
    """
    Reverse the score for Section 3, Question 8 (Positive question in negative section)
    Input: 1-5 (where user selected 1=Not at all, 5=Very Much)
    Output: 5-1 (reversed)
    """
    return 6 - answer
