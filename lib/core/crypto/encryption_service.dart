import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class EncryptionService {
  static final EncryptionService instance = EncryptionService._();
  EncryptionService._();

  // master_password + salt → master_key (Argon2id)
  Future<List<int>> deriveMasterKey(String masterPassword, String salt) async {
    final algorithm = Argon2id(
      memory: 65536,    // 64 MB
      parallelism: 2,
      iterations: 3,
      hashLength: 32,   // 256 bit
    );

    final secretKey = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(masterPassword)),
      nonce: base64Decode(salt),
    );

    return secretKey.extractBytes();
  }

  // Şifreleme: plaintext → base64(iv + ciphertext)
  Future<Map<String, String>> encrypt(String plaintext, List<int> masterKey) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(masterKey);
    final nonce = algorithm.newNonce();

    final secretBox = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    final combined = Uint8List.fromList(
      secretBox.nonce + secretBox.cipherText + secretBox.mac.bytes,
    );

    return {
      'encrypted': base64Encode(combined),
      'iv': base64Encode(secretBox.nonce),
    };
  }

  // Çözme: base64(iv + ciphertext) → plaintext
  Future<String> decrypt(String encryptedData, String iv, List<int> masterKey) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(masterKey);

    final combined = base64Decode(encryptedData);
    final nonce = base64Decode(iv);

    final nonceLength = nonce.length;
    final macLength = 16;
    final cipherText = combined.sublist(
      nonceLength,
      combined.length - macLength,
    );
    final mac = Mac(combined.sublist(combined.length - macLength));

    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);

    final decrypted = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(decrypted);
  }

  Future<String> decryptCombined(String encryptedData, List<int> masterKey) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(masterKey);

    final combined = base64Decode(encryptedData);
    const nonceLength = 12;
    const macLength = 16;

    final nonce = combined.sublist(0, nonceLength);
    final cipherText = combined.sublist(nonceLength, combined.length - macLength);
    final mac = Mac(combined.sublist(combined.length - macLength));

    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
    final decrypted = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(decrypted);
  }

  // Yeni salt üret (register sırasında)
  String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }
}
