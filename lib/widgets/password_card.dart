import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/password_provider.dart';

class PasswordCard extends ConsumerWidget {
  const PasswordCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final passwordState = ref.watch(passwordProvider);

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ref.read(passwordProvider.notifier).togglePasswordVisibility();
          HapticFeedback.selectionClick();
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  passwordState.isPasswordVisible
                      ? passwordState.generatedPassword!
                      : '•' * passwordState.generatedPassword!.length,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    letterSpacing: 2.0,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(
                passwordState.isPasswordVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}