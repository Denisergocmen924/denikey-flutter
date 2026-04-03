class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://127.0.0.1:8000';
  // Auth
  static const String register = '/api/v1/auth/register';
  static const String login    = '/api/v1/auth/login';

  // Vault
  static const String vaultItems = '/api/v1/vault/items';
  static String vaultItem(String id) => '/api/v1/vault/items/$id';

  // Categories
  static const String categories = '/api/v1/categories/';
  static String category(String id) => '/api/v1/categories/$id';

  // Password generator
  static const String generatePassword = '/api/v1/password/generate';
}