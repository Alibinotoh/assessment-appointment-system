class TimeSlot {
  final String slotId;
  final String date;
  final String startTime;
  final String endTime;

  TimeSlot({
    required this.slotId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      slotId: json['slot_id'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class Counselor {
  final String counselorId;
  final String fullName;
  final String specialization;
  final String email;
  final List<TimeSlot> availableSlots;

  Counselor({
    required this.counselorId,
    required this.fullName,
    required this.specialization,
    required this.email,
    required this.availableSlots,
  });

  factory Counselor.fromJson(Map<String, dynamic> json) {
    return Counselor(
      counselorId: json['counselor_id'],
      fullName: json['full_name'],
      specialization: json['specialization'],
      email: json['email'],
      availableSlots: (json['available_slots'] as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
    );
  }
}

class ClientDetails {
  final String fullName;
  final String email;
  final String? studentId;
  final String course;
  final String yearLevel;
  final String gender;
  final int age;
  final String? contactNumber;

  ClientDetails({
    required this.fullName,
    required this.email,
    this.studentId,
    required this.course,
    required this.yearLevel,
    required this.gender,
    required this.age,
    this.contactNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'student_id': studentId,
      'course': course,
      'year_level': yearLevel,
      'gender': gender,
      'age': age,
      'contact_number': contactNumber,
    };
  }
}

class AppointmentBookRequest {
  final String submissionId;
  final String counselorId;
  final String slotId;
  final ClientDetails clientDetails;

  AppointmentBookRequest({
    required this.submissionId,
    required this.counselorId,
    required this.slotId,
    required this.clientDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'submission_id': submissionId,
      'counselor_id': counselorId,
      'slot_id': slotId,
      'client_details': clientDetails.toJson(),
    };
  }
}

class Appointment {
  final String appointmentId;
  final String status;
  final String scheduledDate;
  final String scheduledTime;
  final String counselorName;
  final String counselorEmail;
  final DateTime createdAt;
  final String? counselorNotes;
  final String? rejectionReason;

  Appointment({
    required this.appointmentId,
    required this.status,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.counselorName,
    required this.counselorEmail,
    required this.createdAt,
    this.counselorNotes,
    this.rejectionReason,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id'],
      status: json['status'],
      scheduledDate: json['scheduled_date'],
      scheduledTime: json['scheduled_time'],
      counselorName: json['counselor_name'],
      counselorEmail: json['counselor_email'],
      createdAt: DateTime.parse(json['created_at']),
      counselorNotes: json['counselor_notes'],
      rejectionReason: json['rejection_reason'],
    );
  }
}
