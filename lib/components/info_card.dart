import 'package:flutter/material.dart';
import 'package:pet_track/core/app_colors.dart';

class InfoCard extends StatelessWidget {
  final Widget child;
  const InfoCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.backgroundComponent,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}
