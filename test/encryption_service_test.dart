import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:denikey_app/core/crypto/encryption_service.dart';

void main() {
  final enc = EncryptionService.instance;

  group('EncryptionService', () {
    test('generateSalt — 16 byte base64 string üretir', () {
      final s1 = enc.generateSalt();
      final s2 = enc.generateSalt();
      expect(s1, isNotEmpty);
      expect(s1, isNot(equals(s2)));
      // base64 decode edilebilmeli
      final bytes = base64Decode(s1);
      expect(bytes.length, greaterThanOrEqualTo(16));
    });

    test('deriveMasterKey — aynı password + salt ile aynı key döner', () async {
      final salt = enc.generateSalt();
      final k1 = await enc.deriveMasterKey('master-pass', salt);
      final k2 = await enc.deriveMasterKey('master-pass', salt);
      expect(k1, equals(k2));
    });

    test('deriveMasterKey — farklı salt ile farklı key döner', () async {
      final s1 = enc.generateSalt();
      final s2 = enc.generateSalt();
      final k1 = await enc.deriveMasterKey('master-pass', s1);
      final k2 = await enc.deriveMasterKey('master-pass', s2);
      expect(k1, isNot(equals(k2)));
    });

    test('encrypt/decrypt — round-trip çalışır', () async {
      final salt = enc.generateSalt();
      final key = await enc.deriveMasterKey('test-password', salt);
      const plain = 'super-secret-123!';

      final result = await enc.encrypt(plain, key);
      expect(result['encrypted'], isNotEmpty);
      expect(result['iv'], isNotEmpty);

      final decrypted = await enc.decrypt(
        result['encrypted']!,
        result['iv']!,
        key,
      );
      expect(decrypted, equals(plain));
    });

    test('encrypt — aynı veri iki kez şifrelenince farklı çıktı (rastgele IV)', () async {
      final salt = enc.generateSalt();
      final key = await enc.deriveMasterKey('password', salt);

      final r1 = await enc.encrypt('hello', key);
      final r2 = await enc.encrypt('hello', key);
      expect(r1['iv'], isNot(equals(r2['iv'])));
    });

    test('decrypt — yanlış key ile hata fırlatır', () async {
      final s1 = enc.generateSalt();
      final s2 = enc.generateSalt();
      final k1 = await enc.deriveMasterKey('password', s1);
      final k2 = await enc.deriveMasterKey('password', s2);

      final result = await enc.encrypt('secret', k1);
      expect(
        () async => enc.decrypt(result['encrypted']!, result['iv']!, k2),
        throwsA(anything),
      );
    });

    test('decryptCombined — combined format (iv+cipher) çözülür', () async {
      final salt = enc.generateSalt();
      final key = await enc.deriveMasterKey('password', salt);
      const plain = 'combined-format-test';

      final result = await enc.encrypt(plain, key);
      // combined format: backend'in custom_fields için ürettiği format
      final combined = result['encrypted']!;
      final decrypted = await enc.decryptCombined(combined, key);
      expect(decrypted, equals(plain));
    });
  });
}
