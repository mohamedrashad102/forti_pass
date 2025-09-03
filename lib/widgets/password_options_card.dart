import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/password_provider.dart';

class PasswordOptionsCard extends ConsumerWidget {
  const PasswordOptionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final passwordState = ref.watch(passwordProvider);
    final passwordNotifier = ref.read(passwordProvider.notifier);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password Options',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.straighten, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Length: ${passwordState.passwordLength} characters'),
                ),
              ],
            ),
            Slider(
              value: passwordState.passwordLength.toDouble(),
              min: 8,
              max: 32,
              divisions: 24,
              label: passwordState.passwordLength.toString(),
              onChanged: (value) {
                passwordNotifier.updatePasswordLength(value.round());
                HapticFeedback.selectionClick();
              },
            ),
            SwitchListTile(
              title: const Text('Include Special Characters'),
              subtitle: const Text('Adds !@#\$%^&* for stronger security'),
              value: passwordState.includeSpecialChars,
              onChanged: (value) {
                passwordNotifier.updateIncludeSpecialChars(value);
                HapticFeedback.selectionClick();
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}