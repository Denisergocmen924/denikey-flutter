import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    final path = join(await getDatabasesPath(), 'denikey_cache.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vault_cache (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            title TEXT,
            username TEXT,
            email TEXT,
            phone TEXT,
            encrypted_password TEXT NOT NULL,
            iv TEXT,
            encryption_version INTEGER,
            notes TEXT,
            category_id TEXT,
            color TEXT,
            icon TEXT,
            is_favorite INTEGER,
            sort_order INTEGER,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
      },
    );
  }

  // Vault item'ları cache'e kaydet (şifrelenmiş halde)
  Future<void> cacheVaultItems(List<Map<String, dynamic>> items) async {
    final database = await db;
    final batch = database.batch();
    
    batch.delete('vault_cache');
    
    for (final item in items) {
      batch.insert(
        'vault_cache',
        {
          'id': item['id'],
          'user_id': item['user_id'],
          'title': item['title'],
          'username': item['username'],
          'email': item['email'],
          'phone': item['phone'],
          'encrypted_password': item['encrypted_password'],
          'iv': item['iv'],
          'encryption_version': item['encryption_version'],
          'notes': item['notes'],
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

  // Cache'den oku ve şifreleri çöz
  Future<List<Map<String, dynamic>>> getCachedVaultItems() async {
    final database = await db;
    final rows = await database.query('vault_cache', orderBy: 'sort_order, created_at DESC');

    final masterKey = await SecureStorage.instance.getMasterKey();
    if (masterKey == null) return [];

    final result = <Map<String, dynamic>>[];

    for (final row in rows) {
      final encryptedPassword = row['encrypted_password'] as String? ?? '';
      final iv = row['iv'] as String? ?? '';

      String decryptedPassword = '';
      if (encryptedPassword.isNotEmpty && iv.isNotEmpty) {
        try {
          decryptedPassword = await EncryptionService.instance.decrypt(
            encryptedPassword,
            iv,
            masterKey,
          );
        } catch (_) {
          decryptedPassword = '';
        }
      }

      result.add({
        ...row,
        'is_favorite': row['is_favorite'] == 1,
        'decrypted_password': decryptedPassword,
      });
    }

    return result;
  }

  // Cache'i temizle (logout)
  Future<void> clearCache() async {
    final database = await db;
    await database.delete('vault_cache');
  }
}
