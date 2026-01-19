class Question {
  final String id;
  final String text;
  final String valence;
  final String? note;

  Question({
    required this.id,
    required this.text,
    required this.valence,
    this.note,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      valence: json['valence'],
      note: json['note'],
    );
  }
}

class QuestionOption {
  final int value;
  final String label;

  QuestionOption({required this.value, required this.label});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      value: json['value'],
      label: json['label'],
    );
  }
}

class AssessmentSection {
  final String title;
  final String description;
  final List<Question> questions;
  final List<QuestionOption> options;

  AssessmentSection({
    required this.title,
    required this.description,
    required this.questions,
    required this.options,
  });

  factory AssessmentSection.fromJson(Map<String, dynamic> json) {
    return AssessmentSection(
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      options: (json['options'] as List)
          .map((o) => QuestionOption.fromJson(o))
          .toList(),
    );
  }
}

class AssessmentQuestionnaire {
  final AssessmentSection section1;
  final AssessmentSection section2;
  final AssessmentSection section3;

  AssessmentQuestionnaire({
    required this.section1,
    required this.section2,
    required this.section3,
  });

  factory AssessmentQuestionnaire.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestionnaire(
      section1: AssessmentSection.fromJson(json['section1']),
      section2: AssessmentSection.fromJson(json['section2']),
      section3: AssessmentSection.fromJson(json['section3']),
    );
  }
}

class AssessmentAnswers {
  final Map<String, int> section1;
  final Map<String, int> section2;
  final Map<String, int> section3;

  AssessmentAnswers({
    required this.section1,
    required this.section2,
    required this.section3,
  });

  Map<String, dynamic> toJson() {
    return {
      'answers': {
        'section1': section1,
        'section2': section2,
        'section3': section3,
      }
    };
  }
}

class AssessmentResult {
  final String submissionId;
  final double section1Score;
  final double section2Score;
  final double section3Score;
  final double overallScore;
  final String stressLevel;
  final String recommendation;
  final DateTime timestamp;

  AssessmentResult({
    required this.submissionId,
    required this.section1Score,
    required this.section2Score,
    required this.section3Score,
    required this.overallScore,
    required this.stressLevel,
    required this.recommendation,
    required this.timestamp,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      submissionId: json['submission_id'],
      section1Score: json['section1_score'].toDouble(),
      section2Score: json['section2_score'].toDouble(),
      section3Score: json['section3_score'].toDouble(),
      overallScore: json['overall_score'].toDouble(),
      stressLevel: json['stress_level'],
      recommendation: json['recommendation'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
