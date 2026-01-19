class ApiConfig {
  // Change this to your backend URL
  static const String baseUrl = 'http://localhost:8000';
  
  // Endpoints
  static const String assessmentQuestions = '/assessment/questions';
  static const String assessmentSubmit = '/assessment/submit';
  static const String counselorsAvailable = '/appointment/counselors/available';
  static const String appointmentBook = '/appointment/book';
  static String appointmentStatus(String email) => '/appointment/status/$email';
  
  // Admin endpoints
  static const String adminLogin = '/admin/login';
  static const String adminAssessments = '/admin/assessments';
  static String adminAppointment(String id) => '/admin/appointment/$id';
  static String adminAppointmentStatus(String id) => '/admin/appointment/$id/status';
  static const String adminSlots = '/admin/slots';
  static const String adminAppointments = '/admin/appointments';
  
  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}
