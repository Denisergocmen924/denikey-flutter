import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../crypto/encryption_service.dart';
import '../storage/secure_storage.dart';

class CacheService {
  static final CacheService instance = CacheService._();
  CacheService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final String dbDir;
    if (Platform.isLinux || Platform.isWindows) {
      final dir = await getApplicationSupportDirectory();
      dbDir = dir.path;
    } else {
      dbDir = await getDatabasesPath();
    }
    final path = join(dbDir, 'denikey_cache.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(_createTableSql);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Cache sunucudan yeniden doldurulur — drop + recreate yeterli
        await db.execute('DROP TABLE IF EXISTS vault_cache');
        await db.execute(_createTableSql);
      },
    );
  }

  static const _createTableSql = '''
    CREATE TABLE vault_cache (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      encrypted_meta TEXT,
      meta_iv TEXT,
      encrypted_password TEXT NOT NULL,
      iv TEXT,
      encryption_version INTEGER,
      category_id TEXT,
      color TEXT,
      icon TEXT,
      is_favorite INTEGER,
      sort_order INTEGER,
      created_at TEXT,
      updated_at TEXT
    )
  ''';

  Future<void> cacheVaultItems(List<Map<String, dynamic>> items) async {
    final masterKey = await SecureStorage.instance.getMasterKey();
    if (masterKey == null) return;

    final database = await db;
    final batch = database.batch();
    batch.delete('vault_cache');

    for (final item in items) {
      final metaJson = jsonEncode({
        'title': item['title'],
        'username': item['username'],
        'email': item['email'],
        'phone': item['phone'],
        'notes': item['notes'],
      });
      final encMeta = await EncryptionService.instance.encrypt(metaJson, masterKey);

      batch.insert(
        'vault_cache',
        {
          'id': item['id'],
          'user_id': item['user_id'],
          'encrypted_meta': encMeta['encrypted'],
          'meta_iv': encMeta['iv'],
          'encrypted_password': item['encrypted_password'],
          'iv': item['iv'],
          'encryption_version': item['encryption_version'],
          'category_id': item['category_id'],
          'color': item['color'],
          'icon': item['icon'],
          'is_favorite': item['is_favorite'] == true ? 1 : 0,
          'sort_order': item['sort_order'],
          'created_at': item['created_at']?.toString(),
          'updated_at': item['updated_at']?.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedVaultItems() async {
    final database = await db;
    final rows = await database.query('vault_cache', orderBy: 'sort_order, created_at DESC');

    final masterKey = await SecureStorage.instance.getMasterKey();
    if (masterKey == null) return [];

    final result = <Map<String, dynamic>>[];

    for (final row in rows) {
      final encPwd = row['encrypted_password'] as String? ?? '';
      final iv = row['iv'] as String? ?? '';

      String decryptedPassword = '';
      if (encPwd.isNotEmpty && iv.isNotEmpty) {
        try {
          decryptedPassword = await EncryptionService.instance.decrypt(encPwd, iv, masterKey);
        } catch (_) {}
      }

      Map<String, dynamic> meta = {};
      final encMeta = row['encrypted_meta'] as String?;
      final metaIv = row['meta_iv'] as String?;
      if (encMeta != null && metaIv != null) {
        try {
          final metaJson = await EncryptionService.instance.decrypt(encMeta, metaIv, masterKey);
          meta = Map<String, dynamic>.from(jsonDecode(metaJson) as Map);
        } catch (_) {}
      }

      result.add({
        ...row,
        'title': meta['title'],
        'username': meta['username'],
        'email': meta['email'],
        'phone': meta['phone'],
        'notes': meta['notes'],
        'is_favorite': row['is_favorite'] == 1,
        'decrypted_password': decryptedPassword,
      });
    }

    return result;
  }

  Future<void> clearCache() async {
    final database = await db;
    await database.delete('vault_cache');
  }
}
