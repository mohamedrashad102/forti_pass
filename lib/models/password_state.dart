import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_state.freezed.dart';

@freezed
class PasswordState with _$PasswordState {
  const factory PasswordState({
    @Default('') String masterKey,
    @Default('') String website,
    String? generatedPassword,
    @Default(false) bool isKeyVisible,
    @Default(false) bool isPasswordVisible,
    @Default(false) bool isGenerating,
    @Default(16) int passwordLength,
    @Default(true) bool includeSpecialChars,
    @Default(0.0) double passwordStrength,
  }) = _PasswordState;
}
