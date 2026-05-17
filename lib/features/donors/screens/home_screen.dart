import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/donor_card.dart';
import '../../../widgets/app_drawer.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/donor_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donorsAsync = ref.watch(filteredDonorsAsync);
    final filter = ref.watch(bloodGroupFilterProvider);
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              color: AppTheme.primaryRed,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userAsync.when(
                  data: (user) => Text(
                    'Hello, ${user?.name.split(' ').first ?? 'Friend'} 👋',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Find blood donors near you',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: filter.isEmpty ? null : filter,
                      hint: const Text('Filter by Blood Group'),
                      items: [
                        const DropdownMenuItem(
                            value: '', child: Text('All Blood Groups')),
                        ...AppConstants.bloodGroups.map(
                          (g) => DropdownMenuItem(value: g, child: Text(g)),
                        ),
                      ],
                      onChanged: (v) => ref
                          .read(bloodGroupFilterProvider.notifier)
                          .setFilter(v ?? ''),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.people,
                  label: 'Available Donors',
                  color: AppTheme.primaryRed,
                ),
                const SizedBox(width: 8),
                if (filter.isNotEmpty)
                  Chip(
                    label: Text(filter),
                    backgroundColor: AppTheme.lightRed,
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => ref
                        .read(bloodGroupFilterProvider.notifier)
                        .clearFilter(),
                  ),
              ],
            ),
          ),

          // Donors list
          Expanded(
            child: donorsAsync.when(
              data: (donors) {
                if (donors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          filter.isEmpty
                              ? 'No donors available'
                              : 'No $filter donors found',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: donors.length,
                  itemBuilder: (_, i) => DonorCard(donor: donors[i]),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRed),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: userAsync.when(
        data: (user) {
          if (user?.role == AppConstants.roleReceiver) {
            return FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.bloodRequest),
              backgroundColor: AppTheme.primaryRed,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Request Blood',
                  style: TextStyle(color: Colors.white)),
            );
          }
          return const SizedBox.shrink();
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
