import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'action_buttons.dart';
import 'password_card.dart';
import 'password_strength_indicator.dart';

class PasswordOutputSection extends ConsumerWidget {
  final VoidCallback onCopy;
  final VoidCallback onReset;

  const PasswordOutputSection({
    super.key,
    required this.onCopy,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'Your Generated Password',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const PasswordStrengthIndicator(),
        const SizedBox(height: 16),
        const PasswordCard(),
        const SizedBox(height: 16),
        ActionButtons(onCopy: onCopy, onReset: onReset),
      ],
    );
  }
}
