import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/error_dialog.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  List<dynamic> _slots = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final slots = await apiService.getTimeSlots(
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate),
      );
      
      setState(() {
        _slots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorDialog.showNetworkError(context, onRetry: _loadSlots);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangePicker(),
                  const SizedBox(height: 24),
                  _buildWeekView(),
                  const SizedBox(height: 24),
                  _buildSlotsList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSlotDialog,
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryMaroon,
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              '${DateFormat.yMMMd().format(_startDate)} - ${DateFormat.yMMMd().format(_endDate)}',
              style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
            );
            
            if (picked != null) {
              setState(() {
                _startDate = picked.start;
                _endDate = picked.end;
              });
              _loadSlots();
            }
          },
          child: const Text('Change'),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    final days = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      days.add(_startDate.add(Duration(days: i)));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        final isSelected = DateUtils.isSameDay(day, _selectedDate);
        final slotsForDay = _slots.where((slot) => DateUtils.isSameDay(DateTime.parse(slot['date']), day)).length;

        return InkWell(
          onTap: () => setState(() => _selectedDate = day),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryMaroon.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(DateFormat('E').format(day), style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                const SizedBox(height: 8),
                Text(DateFormat('d').format(day), style: TextStyle(fontSize: 20, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                const SizedBox(height: 4),
                Text('$slotsForDay slots', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlotsList() {
    final slotsForDay = _slots.where((slot) => DateUtils.isSameDay(DateTime.parse(slot['date']), _selectedDate)).toList();

    if (slotsForDay.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(
            children: [
              const Icon(Icons.event_busy_outlined, size: 64, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              Text(
                'No time slots for ${DateFormat.yMMMd().format(_selectedDate)}',
                style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slotsForDay.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildSlotCard(slotsForDay[index]);
      },
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> slot) {
    final hasAppointment = slot['appointment_id'] != null;
    final isAvailable = slot['is_available'] == true;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              hasAppointment ? Icons.person_outline : Icons.access_time_outlined,
              color: hasAppointment ? AppTheme.success : (isAvailable ? AppTheme.primaryMaroon : AppTheme.textSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${slot['start_time']?.substring(0, 5)} - ${slot['end_time']?.substring(0, 5)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (hasAppointment)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Booked by: ${slot['client_name']}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (hasAppointment ? AppTheme.success : (isAvailable ? AppTheme.info : AppTheme.textSecondary)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                hasAppointment ? slot['appointment_status'] : (isAvailable ? 'Available' : 'Unavailable'),
                style: TextStyle(
                  color: hasAppointment ? AppTheme.success : (isAvailable ? AppTheme.info : AppTheme.textSecondary),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            if (!hasAppointment)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                onPressed: () => _confirmDeleteSlot(slot),
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateSlotDialog() {
    DateTime selectedDate = _selectedDate;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Time Slot'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('MMMM dd, yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(startTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (picked != null) {
                      setState(() => startTime = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(endTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (picked != null) {
                      setState(() => endTime = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _createTimeSlot(selectedDate, startTime, endTime);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTimeSlot(DateTime date, TimeOfDay start, TimeOfDay end) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.createTimeSlot(
        DateFormat('yyyy-MM-dd').format(date),
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}:00',
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}:00',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot created successfully')),
        );
        _loadSlots();
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, title: 'Error', message: e.toString());
      }
    }
  }

  void _confirmDeleteSlot(Map<String, dynamic> slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Time Slot'),
        content: Text(
          'Are you sure you want to delete the slot at ${slot['start_time']?.substring(0, 5)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSlot(slot['slot_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSlot(String slotId) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.deleteTimeSlot(slotId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot deleted successfully')),
        );
        _loadSlots();
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, title: 'Error', message: e.toString());
      }
    }
  }
}
