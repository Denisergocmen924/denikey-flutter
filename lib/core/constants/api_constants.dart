class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    return 'https://denikey-backend.fly.dev';
  }

  // Auth
  static const String register           = '/api/v1/auth/register';
  static const String login              = '/api/v1/auth/login';
  static const String verifyEmail        = '/api/v1/auth/verify-email';
  static const String verifyDevice       = '/api/v1/auth/verify-device';
  static const String resendVerification = '/api/v1/auth/resend-verification';
  static const String refreshToken       = '/api/v1/auth/refresh';
  static const String forgotPassword     = '/api/v1/auth/forgot-password';
  static const String resetPassword      = '/api/v1/auth/reset-password';
  static const String changeEmail        = '/api/v1/auth/change-email';
  static const String confirmEmailChange = '/api/v1/auth/confirm-email-change';
  static const String updateProfile      = '/api/v1/auth/profile';
  static const String logout             = '/api/v1/auth/logout';
  static const String deleteAccount      = '/api/v1/auth/delete-account';
  static const String totpStatus         = '/api/v1/auth/totp/status';
  static const String totpSetup          = '/api/v1/auth/totp/setup';
  static const String totpEnable         = '/api/v1/auth/totp/enable';
  static const String totpDisable        = '/api/v1/auth/totp/disable';
  static const String totpVerifyLogin    = '/api/v1/auth/totp/verify-login';
  static const String totpTrustDuration  = '/api/v1/auth/totp/trust-duration';
  static const String totpTrustCheck     = '/api/v1/auth/totp/trust-check';
  static const String totpVerifyUnlock   = '/api/v1/auth/totp/verify-unlock';

  // Vault
  static const String vaultItems = '/api/v1/vault/items';
  static String vaultItem(String id) => '/api/v1/vault/items/$id';

  // Categories
  static const String categories = '/api/v1/categories/';
  static String category(String id) => '/api/v1/categories/$id';

  // Password generator
  static const String generatePassword = '/api/v1/password/generate';

  // Audit log
  static const String auditLog = '/api/v1/audit-logs/';

  // Support ticket
  static const String supportTickets = '/api/v1/support-ticket/';
  static String supportTicket(String id) => '/api/v1/support-ticket/$id';

  // Item types
  static const String itemTypes = '/api/v1/item-types/';

  // Trash
  static const String trashItems = '/api/v1/trash/';
  static String trashItem(String id) => '/api/v1/trash/$id';
  static String trashRestore(String id) => '/api/v1/trash/$id/restore';

  // Version
  static const String version = '/api/v1/version';

  // Devices
  static const String devices = '/api/v1/devices';
  static String deviceRevoke(String id) => '/api/v1/devices/$id';
  static String deviceBan(String id)    => '/api/v1/devices/$id/ban';
  static String deviceUnban(String id)  => '/api/v1/devices/$id/unban';

  // GitHub Releases (public repo)
  static const String releasesPage         = 'https://github.com/Denisergocmen924/denikey-releases/releases/latest';
  static const String releasesDownloadBase = 'https://github.com/Denisergocmen924/denikey-releases/releases/download';
}
