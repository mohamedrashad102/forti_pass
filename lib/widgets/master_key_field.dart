import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/password_provider.dart';

class MasterKeyField extends ConsumerWidget {
  final TextEditingController controller;

  const MasterKeyField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final passwordState = ref.watch(passwordProvider);

    return TextFormField(
      controller: controller,
      obscureText: !passwordState.isKeyVisible,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Master key is required';
        }
        if (value.length < 8) {
          return 'Master key should be at least 8 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Master Key',
        hintText: 'Enter your secret master key (min 8 chars)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHigh,
        prefixIcon: Icon(
          Icons.vpn_key_rounded,
          color: theme.colorScheme.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            passwordState.isKeyVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onPressed: () {
            ref.read(passwordProvider.notifier).toggleKeyVisibility();
            HapticFeedback.selectionClick();
          },
        ),
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(100)],
    );
  }
}