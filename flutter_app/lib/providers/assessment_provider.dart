import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assessment.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final apiServiceProvider = Provider((ref) {
  final apiService = ApiService();
  final authState = ref.watch(authProvider);
  
  // Automatically set/clear token when auth state changes
  if (authState.token != null) {
    apiService.setAuthToken(authState.token!);
  } else {
    apiService.clearAuthToken();
  }
  
  return apiService;
});

final assessmentQuestionnaireProvider = FutureProvider<AssessmentQuestionnaire>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getQuestions();
});

class AssessmentAnswersNotifier extends StateNotifier<AssessmentAnswers> {
  AssessmentAnswersNotifier()
      : super(AssessmentAnswers(
          section1: {},
          section2: {},
          section3: {},
        ));

  void setAnswer(int section, String questionId, int value) {
    switch (section) {
      case 1:
        state = AssessmentAnswers(
          section1: {...state.section1, questionId: value},
          section2: state.section2,
          section3: state.section3,
        );
        break;
      case 2:
        state = AssessmentAnswers(
          section1: state.section1,
          section2: {...state.section2, questionId: value},
          section3: state.section3,
        );
        break;
      case 3:
        state = AssessmentAnswers(
          section1: state.section1,
          section2: state.section2,
          section3: {...state.section3, questionId: value},
        );
        break;
    }
  }

  void reset() {
    state = AssessmentAnswers(
      section1: {},
      section2: {},
      section3: {},
    );
  }

  bool isSectionComplete(int section, int totalQuestions) {
    switch (section) {
      case 1:
        return state.section1.length == totalQuestions;
      case 2:
        return state.section2.length == totalQuestions;
      case 3:
        return state.section3.length == totalQuestions;
      default:
        return false;
    }
  }
}

final assessmentAnswersProvider =
    StateNotifierProvider<AssessmentAnswersNotifier, AssessmentAnswers>(
  (ref) => AssessmentAnswersNotifier(),
);

final assessmentResultProvider = StateProvider<AssessmentResult?>((ref) => null);
