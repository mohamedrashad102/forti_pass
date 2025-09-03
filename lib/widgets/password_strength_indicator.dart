import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/password_provider.dart';

class PasswordStrengthIndicator extends ConsumerWidget {
  const PasswordStrengthIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final passwordState = ref.watch(passwordProvider);

    Color getStrengthColor() {
      if (passwordState.passwordStrength < 0.3) return Colors.red;
      if (passwordState.passwordStrength < 0.7) return Colors.orange;
      return Colors.green;
    }

    String getStrengthText() {
      if (passwordState.passwordStrength < 0.3) return 'Weak';
      if (passwordState.passwordStrength < 0.7) return 'Medium';
      return 'Strong';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Password Strength', style: theme.textTheme.bodyMedium),
            Text(
              getStrengthText(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: getStrengthColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: passwordState.passwordStrength,
          backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
          color: getStrengthColor(),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}