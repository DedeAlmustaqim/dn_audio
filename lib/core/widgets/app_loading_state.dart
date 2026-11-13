import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.label,
  });

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.4,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 14),
            Text(
              label!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
