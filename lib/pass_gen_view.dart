import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PassGenView extends StatefulWidget {
  const PassGenView({super.key});

  @override
  State<PassGenView> createState() => _PassGenViewState();
}

class _PassGenViewState extends State<PassGenView>
    with TickerProviderStateMixin {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _siteController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _generatedPassword;
  bool _isKeyVisible = false;
  bool _isPasswordVisible = false;
  bool _isGenerating = false;
  int _passwordLength = 16;
  bool _includeSpecialChars = true;
  double _passwordStrength = 0.0;

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

  String _generatePassword({
    required String website,
    required String masterKey,
    int length = 16,
    bool includeSpecialChars = true,
  }) {
    // Enhanced password generation with multiple rounds of hashing
    final combined = utf8.encode(
      '$masterKey${website.toLowerCase()}PassGen2024',
    );
    var hashed = sha256.convert(combined).bytes;

    // Additional rounds for stronger security
    for (int i = 0; i < 1000; i++) {
      hashed = sha256.convert(hashed).bytes;
    }

    final base64Hash = base64Url.encode(hashed);

    if (!includeSpecialChars) {
      // Remove special characters and numbers for basic passwords
      return base64Hash
          .replaceAll(RegExp(r'[^a-zA-Z]'), '')
          .substring(0, min(length, base64Hash.length));
    }

    // Create a more diverse character set
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';

    return List.generate(length, (index) {
      final hashIndex = (hashed[index % hashed.length] + index) % chars.length;
      return chars[hashIndex];
    }).join();
  }

  double _calculatePasswordStrength(String password) {
    double strength = 0.0;

    // Length factor
    strength += min(password.length / 16.0, 1.0) * 0.25;

    // Character variety
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#\$%^&*]'));

    int varieties = [
      hasLower,
      hasUpper,
      hasDigits,
      hasSpecial,
    ].where((x) => x).length;
    strength += (varieties / 4.0) * 0.5;

    // Entropy
    Set<String> uniqueChars = Set.from(password.split(''));
    strength += min(uniqueChars.length / password.length, 1.0) * 0.25;

    return strength;
  }

  Future<void> _onGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    final key = _keyController.text.trim();
    final site = _siteController.text.trim();

    setState(() => _isGenerating = true);

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 600));

    final newPassword = _generatePassword(
      website: site,
      masterKey: key,
      length: _passwordLength,
      includeSpecialChars: _includeSpecialChars,
    );

    setState(() {
      _generatedPassword = newPassword;
      _passwordStrength = _calculatePasswordStrength(newPassword);
      _isGenerating = false;
    });

    _fadeController.forward();
    _slideController.forward();
    _showSnackBar('🔐 Password generated successfully!', isSuccess: true);
  }

  Future<void> _copyToClipboard() async {
    if (_generatedPassword == null) return;

    await Clipboard.setData(ClipboardData(text: _generatedPassword!));
    HapticFeedback.lightImpact();
    _showSnackBar('📋 Password copied to clipboard!', isSuccess: true);
  }

  void _resetPassword() {
    setState(() {
      _generatedPassword = null;
      _isPasswordVisible = false;
      _passwordStrength = 0.0;
    });
    _fadeController.reset();
    _slideController.reset();
    HapticFeedback.selectionClick();
  }

  void _clearForm() {
    _keyController.clear();
    _siteController.clear();
    _resetPassword();
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
                _buildHeader(theme),
                const SizedBox(height: 32),
                _buildMasterKeyField(theme, isDarkMode),
                const SizedBox(height: 16),
                _buildWebsiteField(theme, isDarkMode),
                const SizedBox(height: 24),
                _buildPasswordOptions(theme),
                const SizedBox(height: 24),
                _buildGenerateButton(theme),
                const SizedBox(height: 16),
                _buildClearButton(theme),
                if (_generatedPassword != null) ...[
                  const SizedBox(height: 32),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildPasswordOutputSection(theme, isDarkMode),
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

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
          ),
          child: const Icon(
            Icons.security_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Secure Password Generator',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Generate unique, cryptographically secure passwords',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMasterKeyField(ThemeData theme, bool isDarkMode) {
    return TextFormField(
      controller: _keyController,
      obscureText: !_isKeyVisible,
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
        fillColor: isDarkMode
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHigh,
        prefixIcon: Icon(
          Icons.vpn_key_rounded,
          color: theme.colorScheme.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isKeyVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onPressed: () {
            setState(() => _isKeyVisible = !_isKeyVisible);
            HapticFeedback.selectionClick();
          },
        ),
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(100)],
    );
  }

  Widget _buildWebsiteField(ThemeData theme, bool isDarkMode) {
    return TextFormField(
      controller: _siteController,
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
        fillColor: isDarkMode
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHigh,
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
            _siteController.clear();
            HapticFeedback.selectionClick();
          },
        ),
      ),
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _onGenerate(),
    );
  }

  Widget _buildPasswordOptions(ThemeData theme) {
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
                Expanded(child: Text('Length: $_passwordLength characters')),
              ],
            ),
            Slider(
              value: _passwordLength.toDouble(),
              min: 8,
              max: 32,
              divisions: 24,
              label: _passwordLength.toString(),
              onChanged: (value) {
                setState(() => _passwordLength = value.round());
                HapticFeedback.selectionClick();
              },
            ),
            SwitchListTile(
              title: const Text('Include Special Characters'),
              subtitle: const Text('Adds !@#\$%^&* for stronger security'),
              value: _includeSpecialChars,
              onChanged: (value) {
                setState(() => _includeSpecialChars = value);
                HapticFeedback.selectionClick();
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
      ),
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _onGenerate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isGenerating
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_fix_high_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'GENERATE PASSWORD',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildClearButton(ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: _clearForm,
      icon: const Icon(Icons.clear_all_rounded),
      label: const Text('Clear All'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildPasswordOutputSection(ThemeData theme, bool isDarkMode) {
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
        _buildPasswordStrengthIndicator(theme),
        const SizedBox(height: 16),
        _buildPasswordCard(theme, isDarkMode),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(ThemeData theme) {
    Color getStrengthColor() {
      if (_passwordStrength < 0.3) return Colors.red;
      if (_passwordStrength < 0.7) return Colors.orange;
      return Colors.green;
    }

    String getStrengthText() {
      if (_passwordStrength < 0.3) return 'Weak';
      if (_passwordStrength < 0.7) return 'Medium';
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
          value: _passwordStrength,
          backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
          color: getStrengthColor(),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildPasswordCard(ThemeData theme, bool isDarkMode) {
    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      color: isDarkMode
          ? theme.colorScheme.surfaceContainerHighest
          : Colors.white,
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
          setState(() => _isPasswordVisible = !_isPasswordVisible);
          HapticFeedback.selectionClick();
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  _isPasswordVisible
                      ? _generatedPassword!
                      : '•' * _generatedPassword!.length,
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
                _isPasswordVisible
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _copyToClipboard,
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copy'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetPassword,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About PassGen'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔐 Uses SHA-256 with 1000 iterations'),
              SizedBox(height: 8),
              Text('🛡️ Never stores your master key'),
              SizedBox(height: 8),
              Text('🔄 Same inputs = same password'),
              SizedBox(height: 8),
              Text('📱 Works offline'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }
}
