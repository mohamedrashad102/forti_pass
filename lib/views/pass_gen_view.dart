import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/password_provider.dart';
import '../widgets/clear_button.dart';
import '../widgets/generate_button.dart';
import '../widgets/header_widget.dart';
import '../widgets/master_key_field.dart';
import '../widgets/password_options_card.dart';
import '../widgets/password_output_section.dart';
import '../widgets/website_field.dart';

class PassGenView extends ConsumerStatefulWidget {
  const PassGenView({super.key});

  @override
  ConsumerState<PassGenView> createState() => _PassGenViewState();
}

class _PassGenViewState extends ConsumerState<PassGenView>
    with TickerProviderStateMixin {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _siteController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );
  }

  @override
  void dispose() {
    _keyController.dispose();
    _siteController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _onGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    final passwordNotifier = ref.read(passwordProvider.notifier);
    passwordNotifier.updateMasterKey(_keyController.text.trim());
    passwordNotifier.updateWebsite(_siteController.text.trim());

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    await passwordNotifier.generatePassword();

    _fadeController.forward();
    _slideController.forward();
    _showSnackBar('🔐 Password generated successfully!', isSuccess: true);
  }

  Future<void> _copyToClipboard() async {
    final password = ref.read(passwordProvider).generatedPassword;
    if (password == null) return;

    await Clipboard.setData(ClipboardData(text: password));
    HapticFeedback.lightImpact();
    _showSnackBar('📋 Password copied to clipboard!', isSuccess: true);
  }

  void _resetPassword() {
    ref.read(passwordProvider.notifier).resetPassword();
    _fadeController.reset();
    _slideController.reset();
    HapticFeedback.selectionClick();
  }

  void _clearForm() {
    _keyController.clear();
    _siteController.clear();
    ref.read(passwordProvider.notifier).clearForm();
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess
            ? Colors.green.shade600
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passwordState = ref.watch(passwordProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HeaderWidget(),
                const SizedBox(height: 32),
                MasterKeyField(controller: _keyController),
                const SizedBox(height: 16),
                WebsiteField(
                  controller: _siteController,
                  onSubmitted: (_) => _onGenerate(),
                ),
                const SizedBox(height: 24),
                const PasswordOptionsCard(),
                const SizedBox(height: 24),
                GenerateButton(
                  onPressed: passwordState.isGenerating ? null : _onGenerate,
                  isGenerating: passwordState.isGenerating,
                ),
                const SizedBox(height: 16),
                ClearButton(onPressed: _clearForm),
                if (passwordState.generatedPassword != null) ...[
                  const SizedBox(height: 32),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: PasswordOutputSection(
                        onCopy: _copyToClipboard,
                        onReset: _resetPassword,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
