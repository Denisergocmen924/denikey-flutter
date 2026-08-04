import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';

const _localeKey = 'app_locale';

// Kullanıcı hiç dil seçmediyse arayüzün açıldığı dil; sunucuya da bu yazılır ki
// mailler ile ekranda görülen dil ayrışmasın (sunucu varsayılanı "tr").
const _defaultLanguage = 'en';

/// Sunucu, destek yanıtı gibi bilgilendirme maillerini `users.preferred_language`
/// alanına bakarak gönderir; bu yüzden yerel dil tercihi sunucuya da yazılır.
///
/// Oturum yokken istek atılmaz: 401 dönerse DioClient interceptor'ı oturumu
/// temizleyip `/login`'e atıyor — giriş ekranında dil değiştirmek bunu tetiklememeli.
Future<void> syncPreferredLanguageToServer([String? languageCode]) async {
  try {
    if (await SecureStorage.instance.getToken() == null) return;
    final lang = languageCode ??
        (await SharedPreferences.getInstance()).getString(_localeKey) ??
        _defaultLanguage;
    await DioClient.instance.dio.put(
      ApiConstants.updateProfile,
      data: {'preferred_language': lang},
    );
  } catch (_) {
    // Dil tercihi kritik değil; sunucuya yazılamazsa arayüz dili yine değişir
  }
}

class LocaleNotifier extends Notifier<Locale> {
  static const _key = _localeKey;

  @override
  Locale build() {
    _load();
    return const Locale(_defaultLanguage);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) state = Locale(value);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
    await syncPreferredLanguageToServer(locale.languageCode);
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

const supportedLocales = [
  Locale('tr'),
  Locale('en'),
  Locale('ru'),
];

const localeDisplayNames = {
  'tr': 'Türkçe',
  'en': 'English',
  'ru': 'Русский',
};
