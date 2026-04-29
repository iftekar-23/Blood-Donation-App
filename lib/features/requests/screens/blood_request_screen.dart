import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/loading_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../models/blood_request_model.dart';
import '../services/request_service.dart';

class BloodRequestScreen extends ConsumerStatefulWidget {
  const BloodRequestScreen({super.key});

  @override
  ConsumerState<BloodRequestScreen> createState() =>
      _BloodRequestScreenState();
}

class _BloodRequestScreenState extends ConsumerState<BloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  String? _selectedBloodGroup;
  DateTime? _neededDate;
  bool _loading = false;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryRed),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _neededDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      _showError('Please select blood group');
      return;
    }
    if (_neededDate == null) {
      _showError('Please select needed date');
      return;
    }

    setState(() => _loading = true);
    try {
      final user = await ref.read(currentUserProfileProvider.future);
      final uid = ref.read(authServiceProvider).currentUser!.uid;

      final request = BloodRequestModel(
        id: '',
        requesterId: uid,
        requesterName: user?.name ?? 'Unknown',
        bloodGroup: _selectedBloodGroup!,
        location: _locationCtrl.text.trim(),
        neededDate: _neededDate!,
        contactInfo: _contactCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(requestServiceProvider).createRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blood request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Failed to submit request: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Blood')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.lightRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primaryRed),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your request will be visible to all available donors.',
                        style: TextStyle(color: AppTheme.darkRed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Blood group
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(
                  labelText: 'Blood Group Needed',
                  prefixIcon: Icon(Icons.bloodtype_outlined),
                ),
                items: AppConstants.bloodGroups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v),
                validator: (v) => v == null ? 'Select blood group' : null,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Location / Hospital',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Location is required' : null,
              ),
              const SizedBox(height: 16),

              // Date picker
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date Needed',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      hintText: _neededDate == null
                          ? 'Select date'
                          : DateFormat('MMM dd, yyyy').format(_neededDate!),
                    ),
                    controller: TextEditingController(
                      text: _neededDate == null
                          ? ''
                          : DateFormat('MMM dd, yyyy').format(_neededDate!),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Date is required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contact info
              TextFormField(
                controller: _contactCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Contact is required' : null,
              ),
              const SizedBox(height: 28),

              LoadingButton(
                label: 'Submit Request',
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
