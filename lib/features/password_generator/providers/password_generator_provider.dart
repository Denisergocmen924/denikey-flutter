import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/password_generator_repository.dart';

class PasswordGeneratorState {
  final String? generatedPassword;
  final bool isLoading;
  final String? error;
  final int length;
  final bool uppercase;
  final bool lowercase;
  final bool numbers;
  final bool symbols;

  const PasswordGeneratorState({
    this.generatedPassword,
    this.isLoading = false,
    this.error,
    this.length = 16,
    this.uppercase = true,
    this.lowercase = true,
    this.numbers = true,
    this.symbols = false,
  });

  PasswordGeneratorState copyWith({
    String? generatedPassword,
    bool? isLoading,
    String? error,
    int? length,
    bool? uppercase,
    bool? lowercase,
    bool? numbers,
    bool? symbols,
  }) {
    return PasswordGeneratorState(
      generatedPassword: generatedPassword ?? this.generatedPassword,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      length: length ?? this.length,
      uppercase: uppercase ?? this.uppercase,
      lowercase: lowercase ?? this.lowercase,
      numbers: numbers ?? this.numbers,
      symbols: symbols ?? this.symbols,
    );
  }
}

class PasswordGeneratorNotifier extends StateNotifier<PasswordGeneratorState> {
  final _repo = PasswordGeneratorRepository();

  PasswordGeneratorNotifier() : super(const PasswordGeneratorState());

  void setLength(int length) => state = state.copyWith(length: length);
  void toggleUppercase() => state = state.copyWith(uppercase: !state.uppercase);
  void toggleLowercase() => state = state.copyWith(lowercase: !state.lowercase);
  void toggleNumbers() => state = state.copyWith(numbers: !state.numbers);
  void toggleSymbols() => state = state.copyWith(symbols: !state.symbols);

  Future<void> generate() async {
    // En az bir seçenek aktif olmalı
    if (!state.uppercase && !state.lowercase && !state.numbers && !state.symbols) return;

    state = state.copyWith(isLoading: true);
    try {
      final password = await _repo.generatePassword(
        length: state.length,
        uppercase: state.uppercase,
        lowercase: state.lowercase,
        numbers: state.numbers,
        symbols: state.symbols,
      );
      state = state.copyWith(isLoading: false, generatedPassword: password);
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Şifre oluşturulamadı';
      state = state.copyWith(isLoading: false, error: msg.toString());
    }
  }
}

final passwordGeneratorProvider =
    StateNotifierProvider<PasswordGeneratorNotifier, PasswordGeneratorState>(
  (ref) => PasswordGeneratorNotifier(),
);
