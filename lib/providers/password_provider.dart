import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/password_state.dart';

class PasswordNotifier extends StateNotifier<PasswordState> {
  PasswordNotifier() : super(const PasswordState());

  void updateMasterKey(String key) {
    state = state.copyWith(masterKey: key);
  }

  void updateWebsite(String website) {
    state = state.copyWith(website: website);
  }

  void toggleKeyVisibility() {
    state = state.copyWith(isKeyVisible: !state.isKeyVisible);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void updatePasswordLength(int length) {
    state = state.copyWith(passwordLength: length);
  }

  void updateIncludeSpecialChars(bool include) {
    state = state.copyWith(includeSpecialChars: include);
  }

  void setGenerating(bool generating) {
    state = state.copyWith(isGenerating: generating);
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
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*';

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
    bool hasSpecial = password.contains(RegExp(r'[!@#%^&*]'));

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

  Future<void> generatePassword() async {
    setGenerating(true);

    await Future.delayed(const Duration(milliseconds: 600));

    final newPassword = _generatePassword(
      website: state.website,
      masterKey: state.masterKey,
      length: state.passwordLength,
      includeSpecialChars: state.includeSpecialChars,
    );

    final strength = _calculatePasswordStrength(newPassword);

    state = state.copyWith(
      generatedPassword: newPassword,
      passwordStrength: strength,
      isGenerating: false,
    );
  }

  void resetPassword() {
    state = state.copyWith(
      generatedPassword: null,
      isPasswordVisible: false,
      passwordStrength: 0.0,
    );
  }

  void clearForm() {
    state = const PasswordState();
  }
}

final passwordProvider = StateNotifierProvider<PasswordNotifier, PasswordState>(
  (ref) => PasswordNotifier(),
);
