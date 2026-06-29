import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../crypto/encryption_service.dart';
import '../storage/secure_storage.dart';
import '../../features/vault/data/vault_repository.dart';

class ExportService {
  static final ExportService instance = ExportService._();
  ExportService._();

  final _repo = VaultRepository();

  /// Tüm vault öğelerini çeker, plaintext JSON olarak oluşturur,
  /// master key ile AES-GCM şifreler ve dosyaya yazar.
  /// Döndürülen değer kaydedilen dosyanın yolu.
  Future<String> exportVault() async {
    final masterKey = await SecureStorage.instance.getMasterKey();
    if (masterKey == null) throw Exception('Master key bulunamadı');

    final rawItems = await _repo.getItems();

    final exportItems = <Map<String, dynamic>>[];
    for (final item in rawItems) {
      final decrypted = await _repo.getItemDecrypted(item);
      exportItems.add(_toExportMap(decrypted));
    }

    const jsonEncoder = JsonEncoder.withIndent('  ');
    final plainJson = jsonEncoder.convert(exportItems);

    final encrypted = await EncryptionService.instance.encrypt(plainJson, masterKey);

    final wrapper = jsonEncoder.convert({
      'format': 'denikey-export-v1',
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'item_count': exportItems.length,
      'data': encrypted['encrypted'],
    });

    final path = await _buildSavePath();
    final file = File(path);
    await file.writeAsString(wrapper, encoding: utf8);
    _tryCopyToDesktop(file);
    return path;
  }

  void _tryCopyToDesktop(File source) {
    if (!Platform.isLinux) return;
    try {
      final home = Platform.environment['HOME'];
      if (home == null) return;
      final desktop = Directory('$home/Desktop');
      if (!desktop.existsSync()) return;
      source.copySync('${desktop.path}/${source.uri.pathSegments.last}');
    } catch (_) {}
  }

  Map<String, dynamic> _toExportMap(Map<String, dynamic> item) {
    final rawFields = item['custom_fields'] as List<dynamic>? ?? [];
    final fields = rawFields
        .map((f) {
          final fm = Map<String, dynamic>.from(f as Map);
          return <String, dynamic>{
            'field_name': fm['field_name'],
            'field_type': fm['field_type'],
            'value': fm['decrypted_value'] ?? '',
          };
        })
        .where((f) => (f['value'] as String).isNotEmpty)
        .toList();

    return {
      if (item['title'] != null) 'title': item['title'],
      if (item['username'] != null) 'username': item['username'],
      if (item['email'] != null) 'email': item['email'],
      'password': item['decrypted_password'] ?? '',
      if (item['url'] != null) 'url': item['url'],
      if (item['notes'] != null) 'notes': item['notes'],
      if (item['item_type_id'] != null) 'item_type_id': item['item_type_id'],
      if (item['category_id'] != null) 'category_id': item['category_id'],
      'is_favorite': item['is_favorite'] ?? false,
      if (fields.isNotEmpty) 'custom_fields': fields,
      if (item['created_at'] != null) 'created_at': item['created_at'],
      if (item['updated_at'] != null) 'updated_at': item['updated_at'],
    };
  }

  Future<String> _buildSavePath() async {
    final now = DateTime.now();
    final ts =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    final filename = 'denikey_export_$ts.json';

    Directory dir;
    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory()) ??
          await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    return '${dir.path}/$filename';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
