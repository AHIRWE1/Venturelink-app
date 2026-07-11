import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A single icon+label row, used to list facts (employment type, location,
/// posted date…) on the Opportunity Details and Startup screens.
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoRow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTextStyles.body)),
      ],
    );
  }
}

/// A card containing a stack of [InfoRow]s separated by dividers.
class InfoCard extends StatelessWidget {
  final List<InfoRow> rows;

  const InfoCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            rows[i],
          ],
        ],
      ),
    );
  }
}
