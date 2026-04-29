import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/models/user_model.dart';

/// Card widget displaying a single donor's info
class DonorCard extends StatelessWidget {
  final UserModel donor;
  const DonorCard({super.key, required this.donor});

  Future<void> _callDonor() async {
    final uri = Uri(scheme: 'tel', path: donor.phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.lightRed,
              backgroundImage: donor.photoUrl != null
                  ? CachedNetworkImageProvider(donor.photoUrl!)
                  : null,
              child: donor.photoUrl == null
                  ? Text(
                      donor.name.isNotEmpty ? donor.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 22,
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(donor.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Blood group badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          donor.bloodGroup,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (donor.location != null &&
                          donor.location!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            donor.location!,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Contact button
            IconButton(
              onPressed: _callDonor,
              icon: const Icon(Icons.phone, color: AppTheme.primaryRed),
              tooltip: 'Call ${donor.name}',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.lightRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
