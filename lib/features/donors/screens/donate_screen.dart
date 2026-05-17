import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/loading_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../services/donor_service.dart';

class DonateScreen extends ConsumerStatefulWidget {
  const DonateScreen({super.key});

  @override
  ConsumerState<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends ConsumerState<DonateScreen> {
  bool _loading = false;

  Future<void> _toggleAvailability(bool current) async {
    setState(() => _loading = true);
    try {
      final uid = ref.read(authServiceProvider).currentUser!.uid;
      await ref
          .read(donorServiceProvider)
          .setAvailability(uid, !current);

      ref.invalidate(currentUserProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!current
                ? 'You are now marked as available to donate!'
                : 'You are now marked as unavailable.'),
            backgroundColor: !current ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Donate Blood')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          if (user.role != AppConstants.roleDonor) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'Only donors can access this section.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: user.isAvailable
                          ? [AppTheme.primaryRed, AppTheme.darkRed]
                          : [Colors.grey.shade400, Colors.grey.shade600],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        user.isAvailable
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 56,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.isAvailable
                            ? 'You are Available'
                            : 'You are Unavailable',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.isAvailable
                            ? 'Receivers can see and contact you'
                            : 'You are hidden from the donor list',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),


                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Donor Profile',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(),
                        _InfoRow(label: 'Name', value: user.name),
                        _InfoRow(label: 'Blood Group', value: user.bloodGroup),
                        _InfoRow(label: 'Phone', value: user.phone),
                        if (user.location != null && user.location!.isNotEmpty)
                          _InfoRow(label: 'Location', value: user.location!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),


                const Text('Donation Tips',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...[
                  '💧 Stay well hydrated before donating',
                  '🍽️ Eat a healthy meal before donation',
                  '😴 Get a good night\'s sleep',
                  '🚫 Avoid alcohol 24 hours before',
                  '💊 Inform about any medications',
                ].map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        Expanded(child: Text(tip)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                LoadingButton(
                  label: user.isAvailable
                      ? 'Mark as Unavailable'
                      : 'Mark as Available',
                  loading: _loading,
                  onPressed: () => _toggleAvailability(user.isAvailable),
                  color: user.isAvailable ? Colors.grey.shade700 : null,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryRed)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(
              child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
