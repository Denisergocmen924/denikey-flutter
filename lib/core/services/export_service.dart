import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../crypto/encryption_service.dart';
import '../storage/secure_storage.dart';
import '../../features/vault/data/vault_repository.dart';
import '../../features/categories/data/category_repository.dart';
import '../../features/item_types/data/item_type_repository.dart';

/// Export sonucu: kaydedilen tüm dosyaların yolları.
class ExportResult {
  final String jsonPath;
  final String? decryptorPath;
  final String? readmePath;
  const ExportResult({
    required this.jsonPath,
    this.decryptorPath,
    this.readmePath,
  });
}

class ExportService {
  static final ExportService instance = ExportService._();
  ExportService._();

  final _repo = VaultRepository();
  final _categoryRepo = CategoryRepository();
  final _itemTypeRepo = ItemTypeRepository();

  /// Tüm vault öğelerini çeker, kaydedildiği başlıklarla (tip/kategori adı dahil)
  /// okunabilir JSON oluşturur, master key ile AES-GCM şifreler ve dosyaya yazar.
  /// Çözücü HTML + talimat dosyası da aynı klasöre kopyalanır.
  Future<ExportResult> exportVault() async {
    final masterKey = await SecureStorage.instance.getMasterKey();
    if (masterKey == null) throw Exception('Master key bulunamadı');

    final salt = await SecureStorage.instance.getEncryptionSalt();
    if (salt == null) throw Exception('Şifreleme salt bulunamadı');

    final rawItems = await _repo.getItems();

    // Tip ve kategori adlarını çöz (id → ad eşlemesi)
    final categoryNames = await _loadNameMap(_categoryRepo.getCategories);
    final itemTypeNames = await _loadNameMap(_itemTypeRepo.getItemTypes);

    final exportItems = <Map<String, dynamic>>[];
    for (final item in rawItems) {
      final decrypted = await _repo.getItemDecrypted(item);
      exportItems.add(_toExportMap(decrypted, categoryNames, itemTypeNames));
    }

    const jsonEncoder = JsonEncoder.withIndent('  ');
    final plainJson = jsonEncoder.convert(exportItems);

    final encrypted = await EncryptionService.instance.encrypt(plainJson, masterKey);

    final wrapper = jsonEncoder.convert({
      'format': 'denikey-export-v2',
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'item_count': exportItems.length,
      // Çözücünün master key'i offline türetebilmesi için (salt gizli değildir).
      'kdf': {'type': 'argon2id', 'm': 65536, 't': 3, 'p': 2, 'len': 32},
      'salt': salt,
      'data': encrypted['encrypted'],
    });

    final dir = await _exportDir();
    final ts = _timestamp();

    final jsonFile = File('${dir.path}/denikey_export_$ts.json');
    await jsonFile.writeAsString(wrapper, encoding: utf8);

    final decryptorPath = await _copyAsset(
      'assets/export/denikey_decryptor.html',
      '${dir.path}/denikey_decryptor.html',
    );
    final readmePath = await _copyAsset(
      'assets/export/NASIL_ACILIR.txt',
      '${dir.path}/NASIL_ACILIR.txt',
    );

    // Ubuntu'da masaüstüne de kopyala (varsa)
    _tryCopyToDesktop(jsonFile);
    if (decryptorPath != null) _tryCopyToDesktop(File(decryptorPath));
    if (readmePath != null) _tryCopyToDesktop(File(readmePath));

    return ExportResult(
      jsonPath: jsonFile.path,
      decryptorPath: decryptorPath,
      readmePath: readmePath,
    );
  }

  /// Repository listesinden id → görünen ad (name_tr ?? name_en) eşlemesi kurar.
  Future<Map<String, String>> _loadNameMap(
    Future<List<Map<String, dynamic>>> Function() loader,
  ) async {
    try {
      final list = await loader();
      final map = <String, String>{};
      for (final e in list) {
        final id = e['id'] as String?;
        if (id == null) continue;
        final name = (e['name_tr'] as String?) ?? (e['name_en'] as String?);
        if (name != null && name.isNotEmpty) map[id] = name;
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  /// Asset'i hedef yola kopyalar; başarısız olursa null döner (export yine de sürer).
  Future<String?> _copyAsset(String assetPath, String targetPath) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      await File(targetPath).writeAsString(content, encoding: utf8);
      return targetPath;
    } catch (_) {
      return null;
    }
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

  Map<String, dynamic> _toExportMap(
    Map<String, dynamic> item,
    Map<String, String> categoryNames,
    Map<String, String> itemTypeNames,
  ) {
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

    final categoryId = item['category_id'] as String?;
    final itemTypeId = item['item_type_id'] as String?;

    return {
      if (item['title'] != null) 'title': item['title'],
      if (item['username'] != null) 'username': item['username'],
      if (item['email'] != null) 'email': item['email'],
      'password': item['decrypted_password'] ?? '',
      if (item['url'] != null) 'url': item['url'],
      if (item['notes'] != null) 'notes': item['notes'],
      // Tip ve kategori ID yerine okunabilir ad olarak gömülür
      if (itemTypeId != null && itemTypeNames[itemTypeId] != null)
        'type': itemTypeNames[itemTypeId],
      if (categoryId != null && categoryNames[categoryId] != null)
        'category': categoryNames[categoryId],
      'is_favorite': item['is_favorite'] ?? false,
      if (fields.isNotEmpty) 'custom_fields': fields,
      if (item['created_at'] != null) 'created_at': item['created_at'],
      if (item['updated_at'] != null) 'updated_at': item['updated_at'],
    };
  }

  Future<Directory> _exportDir() async {
    if (Platform.isAndroid) {
      return (await getExternalStorageDirectory()) ??
          await getApplicationDocumentsDirectory();
    }
    return getApplicationDocumentsDirectory();
  }

  String _timestamp() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)}'
        '_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
