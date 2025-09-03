import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WebsiteField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSubmitted;

  const WebsiteField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Website/service name is required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Website/Service',
        hintText: 'e.g., google.com, facebook, gmail',
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
          Icons.language_rounded,
          color: theme.colorScheme.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.clear_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onPressed: () {
            controller.clear();
            HapticFeedback.selectionClick();
          },
        ),
      ),
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
    );
  }
}
