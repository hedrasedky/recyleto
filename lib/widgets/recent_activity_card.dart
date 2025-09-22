import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

enum ActivityType { sale, inventory, refund, request }

class RecentActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final String time;
  final ActivityType type;

  const RecentActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
    required this.type,
  });

  Color _getColor() {
    switch (type) {
      case ActivityType.sale:
        return AppTheme.successGreen;
      case ActivityType.inventory:
        return AppTheme.primaryTeal;
      case ActivityType.refund:
        return AppTheme.errorRed;
      case ActivityType.request:
        return AppTheme.warningOrange;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ActivityType.sale:
        return Icons.point_of_sale;
      case ActivityType.inventory:
        return Icons.inventory_2;
      case ActivityType.refund:
        return Icons.assignment_return;
      case ActivityType.request:
        return Icons.add_shopping_cart;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIcon(),
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGray,
                          fontSize: 13,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.darkGray.withOpacity(0.7),
                          fontSize: 11,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.darkGray.withOpacity(0.5),
                          fontSize: 10,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  amount,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 13,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type.name.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
