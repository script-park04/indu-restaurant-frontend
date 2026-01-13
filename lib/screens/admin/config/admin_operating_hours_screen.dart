import 'package:flutter/material.dart';
import '../../../services/config_service.dart';
import '../../../widgets/common/glass_button.dart';
import '../../../widgets/common/loading_indicator.dart';

class AdminOperatingHoursScreen extends StatefulWidget {
  const AdminOperatingHoursScreen({super.key});

  @override
  State<AdminOperatingHoursScreen> createState() => _AdminOperatingHoursScreenState();
}

class _AdminOperatingHoursScreenState extends State<AdminOperatingHoursScreen> {
  final _configService = ConfigService();
  
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    
    final config = await _configService.getAppConfig();
    
    // Parse time strings (HH:mm format)
    final startParts = config.operatingHoursStart.split(':');
    final endParts = config.operatingHoursEnd.split(':');
    
    setState(() {
      _startTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );
      _endTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );
      _isLoading = false;
    });
  }

  Future<void> _saveConfig() async {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end times')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final startStr = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
      final endStr = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
      
      await _configService.updateOperatingHours(
        startTime: startStr,
        endTime: endStr,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Operating hours updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Not set';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operating Hours'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading configuration...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurant Operating Hours',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Orders will only be accepted during these hours',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 32),
                  
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time, color: Colors.green),
                      title: const Text('Opening Time'),
                      subtitle: Text(_formatTime(_startTime)),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _selectTime(true),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time, color: Colors.red),
                      title: const Text('Closing Time'),
                      subtitle: Text(_formatTime(_endTime)),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _selectTime(false),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Customers will see an error message if they try to order outside these hours',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  GlassButton(
                    onPressed: _isSaving ? null : _saveConfig,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Save Operating Hours'),
                  ),
                ],
              ),
            ),
    );
  }
}
