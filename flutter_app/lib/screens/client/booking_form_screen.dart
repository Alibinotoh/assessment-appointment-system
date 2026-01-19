import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../models/appointment.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/error_dialog.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  final String submissionId;

  const BookingFormScreen({Key? key, required this.submissionId}) : super(key: key);

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _courseController = TextEditingController();
  final _yearLevelController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();

  String? _selectedGender;
  Counselor? _selectedCounselor;
  TimeSlot? _selectedSlot;
  List<Counselor> _counselors = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCounselors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _courseController.dispose();
    _yearLevelController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadCounselors() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final counselors = await apiService.getAvailableCounselors();
      if (mounted) {
        setState(() {
          _counselors = counselors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorDialog.showNetworkError(context, onRetry: _loadCounselors);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: AppTheme.primaryNavy, // Navy for appointments
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy, // Navy for appointment sections
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _studentIdController,
                      decoration: const InputDecoration(
                        labelText: 'Student ID (Optional)',
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _courseController,
                      decoration: const InputDecoration(
                        labelText: 'Course *',
                        prefixIcon: Icon(Icons.school),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your course';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _yearLevelController,
                      decoration: const InputDecoration(
                        labelText: 'Year Level *',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your year level';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender *',
                        prefixIcon: Icon(Icons.wc),
                      ),
                      items: ['Male', 'Female', 'Other', 'Prefer not to say']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedGender = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your gender';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age *',
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 15 || age > 100) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number (Optional)',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Select Counselor & Time Slot',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy, // Navy for appointment sections
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_counselors.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No counselors available at the moment.'),
                        ),
                      )
                    else
                      ..._counselors.map((counselor) => _buildCounselorCard(counselor)),
                    
                    const SizedBox(height: 32),
                    
                    CustomButton(
                      text: 'Confirm Booking',
                      icon: Icons.check,
                      backgroundColor: AppTheme.primaryNavy,
                      onPressed: _submitBooking,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCounselorCard(Counselor counselor) {
    final isSelected = _selectedCounselor?.counselorId == counselor.counselorId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
          width: 2,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryNavy,
          child: Text(
            counselor.fullName[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          counselor.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(counselor.specialization),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Time Slots:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (counselor.availableSlots.isEmpty)
                  const Text('No available slots')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: counselor.availableSlots.map((slot) {
                      final isSlotSelected = _selectedSlot?.slotId == slot.slotId;
                      final date = DateFormat('MMM dd').format(DateTime.parse(slot.date));
                      
                      // Convert 24-hour time to 12-hour format with AM/PM
                      String formatTime(String time) {
                        if (time.isEmpty) return '';
                        final parts = time.split(':');
                        if (parts.length >= 2) {
                          int hour = int.parse(parts[0]);
                          int minute = int.parse(parts[1]);
                          String period = hour >= 12 ? 'PM' : 'AM';
                          
                          // Convert to 12-hour format
                          if (hour == 0) {
                            hour = 12; // Midnight
                          } else if (hour > 12) {
                            hour = hour - 12;
                          }
                          
                          return '$hour:${minute.toString().padLeft(2, '0')} $period';
                        }
                        return time;
                      }
                      
                      final startTime = formatTime(slot.startTime);
                      final endTime = formatTime(slot.endTime);
                      final time = (startTime.isNotEmpty && endTime.isNotEmpty) 
                          ? '$startTime - $endTime' 
                          : 'Time TBA';

                      return ChoiceChip(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                color: isSlotSelected ? Colors.white : AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              time,
                              style: TextStyle(
                                color: isSlotSelected ? Colors.white.withOpacity(0.9) : AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        selected: isSlotSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCounselor = counselor;
                            _selectedSlot = slot;
                          });
                        },
                        selectedColor: AppTheme.primaryNavy,
                        side: BorderSide(
                          color: AppTheme.primaryNavy.withOpacity(0.3),
                          width: 1,
                        ),
                        backgroundColor: Colors.grey[100],
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCounselor == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a counselor and time slot'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    LoadingDialog.show(context, message: 'Booking appointment...');

    try {
      final apiService = ref.read(apiServiceProvider);
      
      final clientDetails = ClientDetails(
        fullName: _nameController.text,
        email: _emailController.text,
        studentId: _studentIdController.text.isEmpty ? null : _studentIdController.text,
        course: _courseController.text,
        yearLevel: _yearLevelController.text,
        gender: _selectedGender!,
        age: int.parse(_ageController.text),
        contactNumber: _contactController.text.isEmpty ? null : _contactController.text,
      );

      final request = AppointmentBookRequest(
        submissionId: widget.submissionId,
        counselorId: _selectedCounselor!.counselorId,
        slotId: _selectedSlot!.slotId,
        clientDetails: clientDetails,
      );

      final response = await apiService.bookAppointment(request);

      if (mounted) {
        LoadingDialog.hide(context);
        SuccessDialog.show(
          context,
          title: 'Booking Successful!',
          message: response['message'] ?? 'Your appointment has been booked successfully.',
          onClose: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        ErrorDialog.showBookingFailed(context, e.toString());
      }
    }
  }
}
