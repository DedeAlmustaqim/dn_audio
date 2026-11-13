import 'package:dn_audio/core/constants/app_colors.dart';
import 'package:dn_audio/core/theme/app_theme.dart';
import 'package:dn_audio/core/theme/app_typography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DN Audio design system foundation', () {
    test('uses the approved monochrome color scheme', () {
      final theme = AppTheme.dark;

      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.textPrimary);
      expect(theme.colorScheme.secondary, AppColors.textSecondary);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.dividerColor, AppColors.border);
    });

    test('applies the Poppins type scale globally', () {
      final theme = AppTheme.dark;

      expect(theme.fontFamily, AppTypography.fontFamily);
      expect(theme.textTheme.displayLarge?.fontFamily, 'Poppins');
      expect(theme.textTheme.titleLarge?.fontFamily, 'Poppins');
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Poppins');
      expect(theme.textTheme.labelSmall?.fontFamily, 'Poppins');
    });
  });
}
