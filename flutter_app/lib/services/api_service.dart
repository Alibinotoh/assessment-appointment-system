import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/assessment.dart';
import '../models/appointment.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Assessment Endpoints
  Future<AssessmentQuestionnaire> getQuestions() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl${ApiConfig.assessmentQuestions}'),
            headers: _getHeaders(),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return AssessmentQuestionnaire.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<AssessmentResult> submitAssessment(AssessmentAnswers answers) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${ApiConfig.assessmentSubmit}'),
            headers: _getHeaders(),
            body: json.encode(answers.toJson()),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return AssessmentResult.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to submit assessment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Appointment Endpoints
  Future<List<Counselor>> getAvailableCounselors({String? date}) async {
    try {
      var uri = Uri.parse('$baseUrl${ApiConfig.counselorsAvailable}');
      if (date != null) {
        uri = uri.replace(queryParameters: {'date': date});
      }

      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Counselor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load counselors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> bookAppointment(
      AppointmentBookRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${ApiConfig.appointmentBook}'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Failed to book appointment');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Appointment>> getAppointmentStatus(String email) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl${ApiConfig.appointmentStatus(email)}'),
            headers: _getHeaders(),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to get appointment status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Admin Endpoints
  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${ApiConfig.adminLogin}'),
            headers: _getHeaders(),
            body: json.encode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setAuthToken(data['access_token']);
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getAdminAssessments({int skip = 0, int limit = 50}) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiConfig.adminAssessments}')
          .replace(queryParameters: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      });

      final response = await http
          .get(uri, headers: _getHeaders(requiresAuth: true))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load assessments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getAppointmentDetail(String appointmentId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl${ApiConfig.adminAppointment(appointmentId)}'),
            headers: _getHeaders(requiresAuth: true),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status, {
    String? notes,
    String? rejectionReason,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl${ApiConfig.adminAppointmentStatus(appointmentId)}'),
            headers: _getHeaders(requiresAuth: true),
            body: json.encode({
              'status': status,
              'counselor_notes': notes,
              'rejection_reason': rejectionReason,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getAdminAppointments({String? status}) async {
    try {
      var uri = Uri.parse('$baseUrl${ApiConfig.adminAppointments}');
      if (status != null) {
        uri = uri.replace(queryParameters: {'status': status});
      }

      final response = await http
          .get(uri, headers: _getHeaders(requiresAuth: true))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/admin/dashboard/stats'),
            headers: _getHeaders(requiresAuth: true),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getAllCounselors() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/admin/counselors'),
            headers: _getHeaders(requiresAuth: true),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load counselors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> createCounselor(String fullName, String email, String employeeId,
      String specialization, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/admin/counselors'),
            headers: _getHeaders(requiresAuth: true),
            body: json.encode({
              'full_name': fullName,
              'email': email,
              'employee_id': employeeId,
              'specialization': specialization,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to create counselor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteCounselor(String counselorId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/admin/counselors/$counselorId'),
            headers: _getHeaders(requiresAuth: true),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete counselor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getTimeSlots({String? startDate, String? endDate}) async {
    try {
      var uri = Uri.parse('$baseUrl/admin/slots');
      if (startDate != null && endDate != null) {
        uri = uri.replace(queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        });
      }

      final response = await http
          .get(uri, headers: _getHeaders(requiresAuth: true))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load time slots: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> createTimeSlot(String date, String startTime, String endTime) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/admin/slots'),
            headers: _getHeaders(requiresAuth: true),
            body: json.encode({
              'date': date,
              'start_time': startTime,
              'end_time': endTime,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        String errorMessage = 'Failed to create time slot';
        try {
          final errorBody = json.decode(response.body);
          errorMessage = errorBody['detail'] ?? errorMessage;
        } catch (_) {
          errorMessage = response.body;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteTimeSlot(String slotId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/admin/slots/$slotId'),
            headers: _getHeaders(requiresAuth: true),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete time slot: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getAnalytics({String period = '7days'}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/admin/analytics?period=$period'),
            headers: _getHeaders(requiresAuth: true),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
