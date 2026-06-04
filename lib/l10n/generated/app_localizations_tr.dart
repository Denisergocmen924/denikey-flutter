// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get loginTagline => 'Şifreleriniz güvende';

  @override
  String get loginUsernameLabel => 'Kullanıcı Adı veya E-posta';

  @override
  String get loginUsernameError => 'Kullanıcı adı veya e-posta gerekli';

  @override
  String get loginUsernameMinError => 'En az 3 karakter';

  @override
  String get loginPasswordLabel => 'Master Şifre';

  @override
  String get loginPasswordError => 'Şifre gerekli';

  @override
  String get loginPasswordMinError => 'En az 6 karakter';

  @override
  String get loginSubmitButton => 'Giriş Yap';

  @override
  String get loginNoAccountQuestion => 'Hesabın yok mu?';

  @override
  String get loginRegisterButton => 'Kayıt Ol';

  @override
  String get loginForgotButton => 'Şifremi Unuttum';

  @override
  String get loginError => 'Hata';

  @override
  String get registerAppBarTitle => 'Kayıt Ol';

  @override
  String get registerHeading => 'Hesap Oluştur';

  @override
  String get registerSubheading => 'Kimliğiniz gizli kalır.';

  @override
  String get registerUsernameLabel => 'Kullanıcı Adı';

  @override
  String get registerUsernameError => 'Kullanıcı adı gerekli';

  @override
  String get registerUsernameMinError => 'En az 3 karakter';

  @override
  String get registerUsernameMaxError => 'En fazla 50 karakter';

  @override
  String get registerEmailLabel => 'E-posta';

  @override
  String get registerEmailError => 'E-posta gerekli';

  @override
  String get registerEmailFormatError => 'Geçerli e-posta girin';

  @override
  String get registerPasswordLabel => 'Master Şifre';

  @override
  String get registerPasswordError => 'Şifre gerekli';

  @override
  String get registerPasswordMinError => 'En az 10 karakter';

  @override
  String get registerConfirmLabel => 'Şifre Tekrar';

  @override
  String get registerConfirmError => 'Şifreler eşleşmiyor';

  @override
  String get registerBirthdateLabel => 'Doğum Tarihi';

  @override
  String get registerBirthdateHelper => 'Doğum Tarihinizi Seçin';

  @override
  String get registerBirthdateSelect => 'Seçiniz';

  @override
  String get registerBirthdateMissing => 'Lütfen doğum tarihinizi seçin';

  @override
  String get registerAgeRestriction =>
      'DeniKey\'i kullanmak için en az 13 yaşında olmalısınız';

  @override
  String get registerSubmitButton => 'Kayıt Ol';

  @override
  String get registerError => 'Hata';

  @override
  String get verifyEmailTitle => 'E-posta Doğrulama';

  @override
  String get verifyDeviceTitle => 'Cihaz Doğrulama';

  @override
  String verifyEmailSubtitle(String email) {
    return '$email adresine gönderilen\n6 haneli kodu girin';
  }

  @override
  String verifyDeviceSubtitle(String email) {
    return 'Bu cihazdan ilk kez giriş yapıyorsunuz.\n$email adresine gönderilen 6 haneli kodu girin.';
  }

  @override
  String get verifySpamWarning => 'Spam/Gereksiz klasörünü kontrol edin';

  @override
  String get verifyCodeError => 'Lütfen 6 haneli kodu girin';

  @override
  String get verifySubmitButton => 'Doğrula';

  @override
  String get verifyResendButton => 'Kodu tekrar gönder';

  @override
  String get verifySendSuccess => 'Kod tekrar gönderildi';

  @override
  String get verifySendError => 'Kod gönderilemedi';

  @override
  String get forgotPasswordTitle => 'Şifremi Unuttum';

  @override
  String get forgotPasswordHeading => 'Şifre Sıfırlama';

  @override
  String get forgotPasswordDescription =>
      'Kayıtlı e-posta adresinize doğrulama kodu gönderilecek.';

  @override
  String get forgotPasswordEmailLabel => 'E-posta';

  @override
  String get forgotPasswordEmailError => 'E-posta gerekli';

  @override
  String get forgotPasswordEmailFormatError => 'Geçerli bir e-posta girin';

  @override
  String get forgotPasswordSubmitButton => 'Kod Gönder';

  @override
  String get forgotPasswordError =>
      'Doğrulama kodu gönderilemedi, tekrar deneyin';

  @override
  String get forgotPasswordApiError => 'Bir hata oluştu';

  @override
  String get resetPasswordTitle => 'Yeni Şifre Belirle';

  @override
  String get resetPasswordHeading => 'Şifrenizi Sıfırlayın';

  @override
  String resetPasswordDescription(String email) {
    return '$email adresine gönderilen kodu ve yeni şifrenizi girin.';
  }

  @override
  String get resetPasswordCodeLabel => 'Doğrulama Kodu';

  @override
  String get resetPasswordCodeError => 'Kod gerekli';

  @override
  String get resetPasswordCodeMinError => '6 haneli kodu girin';

  @override
  String get resetPasswordNewLabel => 'Yeni Master Şifre';

  @override
  String get resetPasswordNewError => 'Şifre gerekli';

  @override
  String get resetPasswordNewMinError => 'En az 8 karakter';

  @override
  String get resetPasswordConfirmLabel => 'Şifre Tekrar';

  @override
  String get resetPasswordConfirmError => 'Şifre tekrarı gerekli';

  @override
  String get resetPasswordConfirmMismatch => 'Şifreler eşleşmiyor';

  @override
  String get resetPasswordSubmitButton => 'Şifremi Sıfırla';

  @override
  String get resetPasswordSuccess => 'Şifreniz başarıyla sıfırlandı';

  @override
  String get resetPasswordApiError => 'Bir hata oluştu';

  @override
  String get changeEmailTitle => 'E-posta Değiştir';

  @override
  String get changeEmailHeading => 'Yeni E-posta Adresi';

  @override
  String get changeEmailDescription =>
      'Yeni e-posta adresinize doğrulama kodu gönderilecek.';

  @override
  String get changeEmailLabel => 'Yeni E-posta';

  @override
  String get changeEmailError => 'E-posta gerekli';

  @override
  String get changeEmailFormatError => 'Geçerli bir e-posta girin';

  @override
  String get changeEmailSubmitButton => 'Kod Gönder';

  @override
  String get changeEmailApiError => 'Bir hata oluştu';

  @override
  String get confirmEmailChangeTitle => 'E-posta Doğrulama';

  @override
  String get confirmEmailChangeHeading => 'Kodu Doğrulayın';

  @override
  String confirmEmailChangeDescription(String newEmail) {
    return '$newEmail adresine gönderilen 6 haneli kodu girin.';
  }

  @override
  String get confirmEmailChangeCodeLabel => 'Doğrulama Kodu';

  @override
  String get confirmEmailChangeCodeError => 'Kod gerekli';

  @override
  String get confirmEmailChangeCodeMinError => '6 haneli kodu girin';

  @override
  String get confirmEmailChangeSubmitButton => 'Onayla';

  @override
  String get confirmEmailChangeSuccess =>
      'E-posta adresiniz başarıyla güncellendi';

  @override
  String get confirmEmailChangeApiError => 'Bir hata oluştu';

  @override
  String get masterLockTitle => 'DeniKey Kilitli';

  @override
  String get masterLockPassword => 'Devam etmek için master şifrenizi girin';

  @override
  String get masterLockBiometricExpired =>
      '7 günlük biyometrik süreniz doldu.\nGüvenliğiniz için master şifrenizi girin.';

  @override
  String get masterLockPasswordLabel => 'Master Şifre';

  @override
  String get masterLockPasswordError => 'Şifre gerekli';

  @override
  String get masterLockWrongPassword => 'Yanlış master şifre';

  @override
  String get masterLockAuthFailed => 'Kimlik doğrulama başarısız';

  @override
  String get masterLockBiometricNeeded =>
      'Lütfen bir kez master şifrenizi girin';

  @override
  String get masterLockButton => 'Kilidi Aç';

  @override
  String masterLockBiometricDaysRemaining(int days) {
    return '$days gün sonra şifre istenecek';
  }

  @override
  String get masterLockBiometricTomorrow => 'Yarın şifre istenecek';

  @override
  String get masterLockDifferentAccount => 'Farklı hesapla giriş yap';

  @override
  String get masterLockTooManyAttempts =>
      'Çok fazla yanlış deneme. Güvenlik için oturum kapatıldı.';

  @override
  String get storageInsecureWarning =>
      'Uyarı: Bu platformda güvenli depolama bulunamadı. Veriler şifrelenmeden saklanıyor.';

  @override
  String get lockTitle => 'DeniKey Kilitli';

  @override
  String get lockDescription => 'Devam etmek için kimliğinizi doğrulayın';

  @override
  String get lockBiometricButton => 'Biyometrik ile Aç';

  @override
  String get lockLogoutButton => 'Çıkış Yap';

  @override
  String get lockAuthFailed => 'Kimlik doğrulama başarısız';

  @override
  String get deviceBannedTitle => 'Cihaz Yasaklandı';

  @override
  String get deviceBannedDescription =>
      'Bu hesap için bu cihaz kullanılamıyor.\nHesap sahibi tarafından erişiminiz kısıtlanmıştır.';

  @override
  String get deviceBannedBackButton => 'Geri Dön';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsAccountSection => 'HESAP';

  @override
  String get settingsUsernameChange => 'Kullanıcı Adı Değiştir';

  @override
  String get settingsEmailChange => 'E-posta Değiştir';

  @override
  String get settingsMyDevices => 'Cihazlarım';

  @override
  String get settingsAppSection => 'UYGULAMA';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsPasswordGenerator => 'Şifre Üretici';

  @override
  String get settingsAuditLog => 'Aktivite Geçmişi';

  @override
  String get settingsSupportTicket => 'Destek Talebi';

  @override
  String get settingsPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get settingsBiometricLock => 'Biyometrik Kilit';

  @override
  String settingsBiometricActive(int days) {
    return 'Aktif  ·  $days gün sonra şifre istenecek';
  }

  @override
  String get settingsBiometricActiveTomorrow =>
      'Aktif  ·  Yarın şifre istenecek';

  @override
  String get settingsBiometricExpired =>
      'Master şifre gerekiyor — kilidi açınca yenilenir';

  @override
  String get settingsBiometricDescription =>
      'Parmak izi veya yüz tanıma ile hızlı erişin.\nGüvenliğiniz için 7 günde bir master şifreniz istenecektir.';

  @override
  String get settingsAutoLock => 'Otomatik Kilit';

  @override
  String settingsAutoLockEnabled(int minutes) {
    return '$minutes dk sonra kilitle';
  }

  @override
  String get settingsAutoLockFocusLoss => 'Süresiz — odaklanmada kilitle';

  @override
  String get settingsAutoLockDisabled =>
      'Uygulamadan çıkınca master şifre iste';

  @override
  String get settingsClipboardTimeout => 'Pano Temizleme';

  @override
  String settingsClipboardTimeoutActive(int timeout) {
    return 'Kopyalanan şifre $timeout sn sonra silinir';
  }

  @override
  String get settingsClipboardTimeoutDisabled =>
      'Sınırsız — pano otomatik temizlenmez';

  @override
  String get settingsKeyboardShortcuts => 'Klavye Kısayolları';

  @override
  String get settingsKeyboardHint => 'Ctrl+1/2/3, +, ←→, Esc vb.';

  @override
  String get settingsDarkMode => 'Karanlık Tema';

  @override
  String get settingsDarkModeSystem => 'Sistem ayarına göre';

  @override
  String get settingsDarkModeEnabled => 'Açık';

  @override
  String get settingsDarkModeDisabled => 'Kapalı';

  @override
  String get settingsHowToUse => 'NASIL KULLANILIR';

  @override
  String get settingsDiscoverApp => 'Uygulamayı Keşfet';

  @override
  String get settingsDiscoverAppDescription => 'Tüm özelliklere genel bakış';

  @override
  String get settingsHelp => 'Yardım';

  @override
  String get settingsHelpAddPassword => 'Şifre Ekleme';

  @override
  String get settingsHelpAddPasswordContent =>
      'Alt menüden \"Kasam\" sekmesine geçin. Sağ alttaki \"+ Yeni Şifre\" butonuna dokunun. Site adı, kullanıcı adı ve şifrenizi girin; kaydedin.';

  @override
  String get settingsHelpPasswordGenerator => 'Şifre Üretici';

  @override
  String get settingsHelpPasswordGeneratorContent =>
      'Uygulama → Şifre Üretici ekranından uzunluk, büyük/küçük harf, rakam ve özel karakter seçenekleriyle güçlü şifre üretebilirsiniz.';

  @override
  String get settingsHelpCategories => 'Kategoriler ve Türler';

  @override
  String get settingsHelpCategoriesContent =>
      '\"Kütüphane\" sekmesinde şifrelerinizi kategorilere ayırabilir, yeni öğe türleri oluşturabilirsiniz.';

  @override
  String get settingsHelpTrash => 'Çöp Kutusu';

  @override
  String get settingsHelpTrashContent =>
      'Silinen şifreler 7 gün boyunca Çöp Kutusu\'nda tutulur. Kasam ekranının sağ üst köşesindeki çöp kutusu ikonundan erişebilirsiniz.';

  @override
  String get settingsHelpZeroKnowledge => 'Sıfır Bilgi Güvenliği';

  @override
  String get settingsHelpZeroKnowledgeContent =>
      'DeniKey\'de master şifreniz hiçbir zaman sunucuya gönderilmez ve hiçbir yerde saklanmaz. Şifreleriniz cihazınızda Argon2id algoritmasıyla türetilen bir anahtarla AES-256-GCM formatında şifrelenir; bu anahtar yalnızca sizin cihazınızda bulunur. Sunucuya yalnızca şifreli (encrypted) veri gönderilir. Master şifrenizi unutursanız verilerinizi kurtarmanın hiçbir yolu yoktur — bu, gerçek sıfır-bilgi güvenliğinin kaçınılmaz sonucudur.';

  @override
  String get settingsLogout => 'Çıkış Yap';

  @override
  String get settingsDeleteAccount => 'Hesabı Kalıcı Olarak Sil';

  @override
  String get settingsDeleteAccountWarning =>
      'Tüm veriler silinir, geri alınamaz';

  @override
  String settingsVersion(String version) {
    return 'DeniKey v$version';
  }

  @override
  String get settingsDevicesTitle => 'Cihazlarım';

  @override
  String get settingsDevicesEmpty => 'Kayıtlı cihaz yok';

  @override
  String get settingsDevicesError => 'Cihazlar yüklenemedi';

  @override
  String get settingsDeviceRefresh => 'Yenile';

  @override
  String get settingsDeviceStatusActive => 'Aktif';

  @override
  String get settingsDeviceStatusPassive => 'Pasif';

  @override
  String get settingsDeviceStatusBanned => 'Yasaklı';

  @override
  String get settingsDeviceRevoke => 'Oturumu Sonlandır';

  @override
  String get settingsDeviceRevokeSuccess => 'Oturum sonlandırıldı';

  @override
  String get settingsDeviceBan => 'Cihazı Yasakla';

  @override
  String get settingsDeviceBanSuccess => 'Cihaz yasaklandı';

  @override
  String get settingsDeviceUnban => 'Yasağı Kaldır';

  @override
  String get settingsDeviceUnbanSuccess => 'Cihaz yasağı kaldırıldı';

  @override
  String get settingsDeviceActionFailed => 'İşlem başarısız';

  @override
  String get settingsDeviceRemove => 'Cihazı Sil';

  @override
  String get settingsDeviceRemoveConfirm =>
      'Bu cihaz kalıcı olarak silinecek. Emin misiniz?';

  @override
  String get settingsDeviceRemoveSuccess => 'Cihaz silindi';

  @override
  String get settingsDeviceRename => 'Adı Değiştir';

  @override
  String get settingsDeviceRenameHint => 'Cihaz adı';

  @override
  String get settingsDeviceRenameSuccess => 'Cihaz adı güncellendi';

  @override
  String get settingsUsernameChangeTitle => 'Kullanıcı Adı Değiştir';

  @override
  String get settingsUsernameChangeHint => 'Yeni kullanıcı adı';

  @override
  String get settingsUsernameChangeError => 'Boş bırakılamaz';

  @override
  String get settingsUsernameChangeMinError => 'En az 3 karakter';

  @override
  String get settingsUsernameChangePatternError =>
      'Sadece harf, rakam ve _ kullanılabilir';

  @override
  String get settingsUsernameChangeSaved => 'Kullanıcı adı güncellendi';

  @override
  String get settingsUsernameChangeFailed => 'Güncellenemedi';

  @override
  String get settingsDeleteAccountStep1 => 'Hesabı Sil — Adım 1/4';

  @override
  String get settingsDeleteAccountWarningContent =>
      'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.';

  @override
  String get settingsDeleteAccountUsernameHint => 'Kullanıcı adınızı girin';

  @override
  String get settingsDeleteAccountStep2 => 'Hesabı Sil — Adım 2/4';

  @override
  String get settingsDeleteAccountPasswordHint => 'Master şifrenizi girin';

  @override
  String get settingsDeleteAccountStep3 => 'Hesabı Sil — Adım 3/4';

  @override
  String get settingsDeleteAccountConfirm =>
      'Gerçekten hesabınızı silmek istiyor musunuz?';

  @override
  String settingsDeleteAccountCountdownWait(int seconds) {
    return '$seconds saniye beklemeniz gerekiyor...';
  }

  @override
  String get settingsDeleteAccountCountdownReady => 'Devam edebilirsiniz.';

  @override
  String get settingsDeleteAccountYesConfirm => 'Evet, Devam Et';

  @override
  String get settingsDeleteAccountStep4 => 'Hesabı Sil — Adım 4/4';

  @override
  String get settingsDeleteAccountFinalMessage =>
      'Son adım: şifrenizi bir kez daha girin.';

  @override
  String get settingsDeleteAccountPasswordConfirmHint =>
      'Master şifrenizi tekrar girin';

  @override
  String get settingsDeleteAccountFinalButton => 'Hesabı Kalıcı Sil';

  @override
  String get settingsDeleteAccountFailed => 'Hesap silinemedi';

  @override
  String get settingsDeleteAccountCancel => 'İptal';

  @override
  String get settingsDeleteAccountContinue => 'Devam';

  @override
  String get privacyPolicyTitle => 'Gizlilik Politikası';

  @override
  String get privacyPolicyLastUpdate => 'Son güncelleme: Nisan 2026';

  @override
  String get privacyPolicySection1Title => '1. Giriş';

  @override
  String get privacyPolicySection1Body =>
      'DeniKey (\"uygulama\", \"biz\", \"hizmet\"), sıfır-bilgi (zero-knowledge) mimarisiyle çalışan bir şifre yöneticisidir. Bu Gizlilik Politikası, uygulamayı kullanırken hangi verilerin toplandığını, nasıl işlendiğini ve haklarınızı açıklamaktadır.';

  @override
  String get privacyPolicySection2Title => '2. Toplanan Veriler';

  @override
  String get privacyPolicySection2Body =>
      '• E-posta adresi ve kullanıcı adı — hesap oluşturma ve kimlik doğrulama için.\n• Master şifrenizin türetilmiş doğrulama değeri (hash) — düz metin asla saklanmaz.\n• Şifrelenmiş kasa verileri — cihazınızda AES-256-GCM ile şifrelendikten sonra sunucuya gönderilir; içeriği yalnızca siz okuyabilirsiniz.\n• Oturum tokenları ve cihaz kimliği — çoklu cihaz yönetimi için.\n• Denetim kayıtları (audit log) — hesap güvenliğinizi izlemeniz için, yalnızca sizin erişiminize açıktır.';

  @override
  String get privacyPolicySection3Title => '3. Sıfır Bilgi Mimarisi';

  @override
  String get privacyPolicySection3Body =>
      'DeniKey, master şifrenizi hiçbir zaman sunucuya göndermez ve hiçbir yerde saklamaz. Kasa verileriniz cihazınızda, Argon2id algoritmasıyla türetilen bir anahtar ile AES-256-GCM formatında şifrelenir. Sunucularımız yalnızca şifreli (encrypted) veri depolar; içeriğinize teknik olarak erişim imkânımız yoktur.\n\nMaster şifrenizi unutursanız verilerinizi kurtarmanın hiçbir yolu yoktur — bu, gerçek sıfır-bilgi güvenliğinin kaçınılmaz sonucudur.';

  @override
  String get privacyPolicySection4Title => '4. Verilerin Kullanımı';

  @override
  String get privacyPolicySection4Body =>
      'Topladığımız veriler yalnızca şu amaçlarla kullanılır:\n• Hesabınızın oluşturulması ve yönetilmesi\n• Kimlik doğrulama ve oturum güvenliği\n• E-posta doğrulama ve şifre sıfırlama bildirimleri\n• Destek taleplerinize yanıt verilmesi\n\nVerileriniz üçüncü taraflarla paylaşılmaz, reklam amacıyla kullanılmaz.';

  @override
  String get privacyPolicySection5Title => '5. Veri Güvenliği';

  @override
  String get privacyPolicySection5Body =>
      '• Tüm iletişim HTTPS/TLS üzerinden şifrelenmiş biçimde gerçekleşir.\n• Kasa verileri sunucuda şifreli olarak saklanır.\n• Şifreler Argon2id (memory: 64 MB, iterations: 3, parallelism: 2) ile türetilir; kaba kuvvet saldırılarına karşı dayanıklıdır.\n• JWT tokenlar kısa ömürlüdür ve yenileme mekanizması ile yönetilir.';

  @override
  String get privacyPolicySection6Title => '6. Hesap Silme';

  @override
  String get privacyPolicySection6Body =>
      'Hesabınızı istediğiniz zaman Ayarlar → Hesabı Kalıcı Olarak Sil adımından silebilirsiniz. Silme işlemi 4 adımlı onay gerektirir ve tüm verileriniz (kasa öğeleri, kategoriler, audit kayıtları dahil) kalıcı olarak kaldırılır. Bu işlem geri alınamaz.';

  @override
  String get privacyPolicySection7Title => '7. Çocukların Gizliliği';

  @override
  String get privacyPolicySection7Body =>
      'DeniKey, 13 yaşın altındaki çocuklara yönelik değildir. Bilerek bu yaş grubundan veri toplamıyoruz.';

  @override
  String get privacyPolicySection8Title => '8. Politika Değişiklikleri';

  @override
  String get privacyPolicySection8Body =>
      'Bu politikayı güncelleyebiliriz. Önemli değişiklikler kayıtlı e-posta adresinize bildirilir. Güncel politika her zaman uygulama içinden erişilebilir.';

  @override
  String get privacyPolicySection9Title => '9. İletişim';

  @override
  String get privacyPolicySection9Body =>
      'Gizlilik ile ilgili sorularınız için destek talebi oluşturabilir ya da uygulama içindeki Destek Talebi ekranını kullanabilirsiniz.';

  @override
  String get vaultTitle => 'DeniKey';

  @override
  String get vaultSearchTooltip => 'Ara';

  @override
  String get vaultTrashTooltip => 'Çöp Kutusu';

  @override
  String get vaultRefreshTooltip => 'Yenile';

  @override
  String get vaultOfflineWarning =>
      'İnternet bağlantısı olmadan kasanıza erişemezsiniz';

  @override
  String get vaultOfflineWarningDesktop => 'Çevrimdışı mod — Salt okunur';

  @override
  String get vaultBulkDeleteTitle => 'Toplu Sil';

  @override
  String vaultBulkDeleteMessage(int count) {
    return '$count kayıt çöp kutusuna taşınacak. Devam edilsin mi?';
  }

  @override
  String get vaultBulkSelectAll => 'Tümü';

  @override
  String vaultBulkMoveTitle(int count) {
    return '$count kaydı taşı';
  }

  @override
  String get vaultBulkMoveUncategorized => 'Kategorisiz';

  @override
  String get vaultCategoryEmpty => 'Bu kategoride şifre yok';

  @override
  String get vaultEmpty => 'Henüz şifre yok';

  @override
  String get vaultEmptyHint => '+ ile yeni şifre ekleyin';

  @override
  String get vaultFavoritesSection => 'Favoriler';

  @override
  String get vaultOthersSection => 'Diğerleri';

  @override
  String get vaultFavoritesAdd => 'Favorilere ekle';

  @override
  String get vaultFavoritesRemove => 'Favoriden çıkar';

  @override
  String get vaultAddButton => 'Yeni Şifre';

  @override
  String get vaultBulkDeleteButton => 'Sil';

  @override
  String get vaultBulkMoveButton => 'Taşı';

  @override
  String get vaultBulkFavoritesButton => 'Favoriye ekle';

  @override
  String get vaultBulkFavoritesRemoveButton => 'Favoriden çıkar';

  @override
  String get vaultLoading => 'Yükleniyor...';

  @override
  String get vaultError => 'Hata';

  @override
  String get vaultRetry => 'Yeniden Dene';

  @override
  String vaultBulkSelectionCount(int count) {
    return '$count seçildi';
  }

  @override
  String get addItemStep0 => 'Kategori Seç';

  @override
  String get addItemStep2 => 'Bilgileri Gir';

  @override
  String get addItemUncategorized => 'Kategorisiz';

  @override
  String get addItemUncategorizedSubtitle => 'Kategorisizler altında sakla';

  @override
  String get addItemCreateCategory => 'Kategori Oluştur';

  @override
  String get addItemCreateCategorySubtitle => 'Yeni kategori ekle';

  @override
  String get addItemNewCategory => 'Yeni Kategori';

  @override
  String get addItemNewCategoryName => 'Kategori Adı';

  @override
  String get addItemTypeNameLabel => 'Tip Adı';

  @override
  String get addItemTypeSelectIcon => 'İkon Seç';

  @override
  String get addItemTypeFixedFields => 'Sabit Alanlar';

  @override
  String get addItemTypeFieldAdd => 'Alan Ekle';

  @override
  String get addItemTypeFieldDefault =>
      'Alan eklenmedi — varsayılan olarak \"Şifre\" alanı oluşturulur.';

  @override
  String get addItemTypeFieldName => 'Alan Adı';

  @override
  String get addItemTypeFieldType => 'Tür';

  @override
  String get addItemTypeFieldTypeText => 'Metin';

  @override
  String get addItemTypeFieldTypeSecret => 'Gizli';

  @override
  String get addItemTypeFieldTypeNumber => 'Sayı';

  @override
  String get addItemTypeFieldTypeDate => 'Tarih';

  @override
  String get addItemTitleLabel => 'Başlık *';

  @override
  String get addItemTitleHint => 'Örn: Instagram, Gmail, Netflix';

  @override
  String get addItemExtraFieldKeyLabel => 'Alan Adı';

  @override
  String get addItemExtraFieldValueLabel => 'Değer';

  @override
  String get addItemAddFieldButton => 'Alan Ekle';

  @override
  String get addItemSaveButton => 'Kaydet';

  @override
  String get addItemPasswordStrengthVeryWeak => 'Çok Zayıf';

  @override
  String get addItemPasswordStrengthWeak => 'Zayıf';

  @override
  String get addItemPasswordStrengthMedium => 'Orta';

  @override
  String get addItemPasswordStrengthStrong => 'Güçlü';

  @override
  String get addItemPasswordStrengthVeryStrong => 'Çok Güçlü';

  @override
  String get addItemErrorSave => 'Kayıt eklenirken bir hata oluştu.';

  @override
  String get addItemCategoryCreate => 'Oluştur';

  @override
  String get addItemTypeCreate => 'Ekle';

  @override
  String get addItemCancel => 'İptal';

  @override
  String get detailPasswordLabel => 'Şifre';

  @override
  String get detailCategoryLabel => 'Klasör';

  @override
  String get detailCategoryUncategorized => 'Sınıflandırılmamış';

  @override
  String get detailCategoryMove => 'Klasöre Taşı';

  @override
  String get detailExternalLinkTitle => 'Dış Link';

  @override
  String detailExternalLinkMessage(String url) {
    return 'DeniKey bu bağlantıyı açmak üzere:\n\n$url';
  }

  @override
  String get detailExternalLinkDeny => 'İzin Verme';

  @override
  String get detailExternalLinkOnce => 'Bu Seferlik';

  @override
  String get detailExternalLinkNoAsk => 'Bir Daha Sorma';

  @override
  String get detailDeleteTitle => 'Sil';

  @override
  String get detailDeleteMessage =>
      'Bu şifreyi silmek istediğinize emin misiniz?';

  @override
  String get detailDeleteButton => 'Sil';

  @override
  String get detailFavoritesAdd => 'Favorilere ekle';

  @override
  String get detailFavoritesRemove => 'Favoriden çıkar';

  @override
  String get detailPasswordHistory => 'Şifre Geçmişi';

  @override
  String get detailEditButton => 'Düzenle';

  @override
  String get detailCancelEdit => 'İptal';

  @override
  String get detailEditTitle => 'Başlık';

  @override
  String get detailEditPassword => 'Şifre';

  @override
  String get detailEditCustomFieldKeyLabel => 'Başlık';

  @override
  String get detailEditCustomFieldValueLabel => 'İçerik';

  @override
  String get detailEditSaveButton => 'Kaydet';

  @override
  String get detailEditErrorBlankTitle => 'Başlık boş olamaz';

  @override
  String get detailEditErrorGeneral => 'Güncellenemedi, tekrar deneyin';

  @override
  String detailInfoTilePasswordCopied(String label, int timeout) {
    return '$label kopyalandı, $timeout saniye sonra silinecek';
  }

  @override
  String detailInfoTileCopied(String label) {
    return '$label kopyalandı';
  }

  @override
  String get detailLinkOpen => 'Linki Aç';

  @override
  String detailLoadError(String error) {
    return 'Bilgiler yüklenemedi: $error';
  }

  @override
  String get detailRetry => 'Tekrar Dene';

  @override
  String get searchHint => 'Ara...';

  @override
  String get searchEmpty => 'Aramak için yazmaya başlayın';

  @override
  String searchNoResults(String query) {
    return '\"$query\" için sonuç bulunamadı';
  }

  @override
  String passwordHistoryTitle(String itemTitle) {
    return '$itemTitle — Geçmiş';
  }

  @override
  String get passwordHistoryClear => 'Geçmişi Temizle';

  @override
  String get passwordHistoryClearTitle => 'Geçmişi Temizle';

  @override
  String get passwordHistoryClearMessage => 'Tüm şifre geçmişi silinsin mi?';

  @override
  String get passwordHistoryEmpty => 'Şifre geçmişi yok';

  @override
  String get passwordHistoryEmptyHint =>
      'Şifre güncellendiğinde eski sürümler burada görünür';

  @override
  String passwordHistoryCopy(int timeout) {
    return 'Şifre kopyalandı, $timeout sn sonra silinecek';
  }

  @override
  String get passwordHistoryCopyNoTimeout => 'Şifre kopyalandı';

  @override
  String get passwordHistoryError => 'Yüklenemedi';

  @override
  String get passwordHistoryRetry => 'Tekrar Dene';

  @override
  String get libraryTitle => 'Kütüphane';

  @override
  String get libraryCategoriesTab => 'Kategoriler';

  @override
  String get libraryTypesTab => 'Türler';

  @override
  String get libraryAddCategory => 'Yeni Kategori';

  @override
  String get libraryCategoryName => 'Kategori Adı';

  @override
  String get libraryCategoryColorSelect => 'Renk Seç';

  @override
  String get libraryDeleteCategoryTitle => 'Sil';

  @override
  String get libraryDeleteCategoryMessage =>
      'Bu kategoriyi silmek istediğinize emin misiniz?';

  @override
  String get libraryDeleteSystemCategory => 'Sistem kategorileri silinemez.';

  @override
  String get libraryDeleteSystemType => 'Sistem türleri silinemez.';

  @override
  String get libraryEmptyCategories => 'Henüz kategori yok';

  @override
  String get libraryEmptyTypes => 'Henüz tür yok';

  @override
  String get librarySystemLabel => 'Sistem';

  @override
  String libraryTypeFieldCount(int count) {
    return '$count alan';
  }

  @override
  String get libraryCancel => 'İptal';

  @override
  String get libraryAddButton => 'Ekle';

  @override
  String get categoryDetailEmpty => 'Bu kategoride henüz öğe yok';

  @override
  String get categoryDetailItem => 'İsimsiz';

  @override
  String get passwordGeneratorTitle => 'Şifre Üretici';

  @override
  String get passwordGeneratorHint => 'Şifre üretmek için butona basın';

  @override
  String get passwordGeneratorGenerate => 'Şifre Üret';

  @override
  String get passwordGeneratorLength => 'Uzunluk';

  @override
  String get passwordGeneratorCharacterTypes => 'Karakter Tipleri';

  @override
  String get passwordGeneratorUppercase => 'Büyük Harf (A–Z)';

  @override
  String get passwordGeneratorLowercase => 'Küçük Harf (a–z)';

  @override
  String get passwordGeneratorNumbers => 'Rakam (0–9)';

  @override
  String get passwordGeneratorSymbols => 'Sembol (!@#\$...)';

  @override
  String get passwordGeneratorCopy => 'Kopyala';

  @override
  String passwordGeneratorCopySuccess(int timeout) {
    return 'Şifre kopyalandı, $timeout sn sonra silinecek';
  }

  @override
  String get passwordGeneratorCopySuccessNoTimeout => 'Şifre kopyalandı';

  @override
  String get trashTitle => 'Çöp Kutusu';

  @override
  String get trashEmptyButton => 'Tümünü Sil';

  @override
  String get trashEmptyTitle => 'Çöp Kutusunu Boşalt';

  @override
  String get trashEmptyMessage =>
      'Tüm öğeler kalıcı olarak silinecek. Bu işlem geri alınamaz.';

  @override
  String get trashDeleteTitle => 'Kalıcı Sil';

  @override
  String trashDeleteMessage(String title) {
    return '\"$title\" kalıcı olarak silinsin mi?';
  }

  @override
  String get trashDeleteButton => 'Sil';

  @override
  String get trashEmpty => 'Çöp kutusu boş';

  @override
  String get trashEmptyHint => 'Silinen öğeler 7 gün burada saklanır';

  @override
  String trashDeleteFor(String date) {
    return '$date tarihinde kalıcı silinecek';
  }

  @override
  String get trashRestore => 'Geri Yükle';

  @override
  String get trashDeletePermanent => 'Kalıcı Sil';

  @override
  String get trashError => 'Hata';

  @override
  String get trashRetry => 'Tekrar Dene';

  @override
  String get trashCancel => 'İptal';

  @override
  String get auditLogTitle => 'Aktivite Geçmişi';

  @override
  String get auditLogFilterAll => 'Tümü';

  @override
  String get auditLogFilterAccount => 'Hesap';

  @override
  String get auditLogFilterSecurity => 'Güvenlik';

  @override
  String get auditLogFilterVault => 'Kasa';

  @override
  String get auditLogActionRegister => 'Kayıt Olundu';

  @override
  String get auditLogActionLoginSuccess => 'Giriş Yapıldı';

  @override
  String get auditLogActionLoginFailed => 'Başarısız Giriş';

  @override
  String get auditLogActionLoginNewDevice => 'Yeni Cihaz Girişi';

  @override
  String get auditLogActionLogout => 'Çıkış Yapıldı';

  @override
  String get auditLogActionDeviceVerified => 'Cihaz Doğrulandı';

  @override
  String get auditLogActionEmailChanged => 'E-posta Değiştirildi';

  @override
  String get auditLogActionPasswordReset => 'Şifre Sıfırlandı';

  @override
  String get auditLogActionVaultItemCreated => 'Şifre Eklendi';

  @override
  String get auditLogActionVaultItemUpdated => 'Şifre Güncellendi';

  @override
  String get auditLogActionVaultItemDeleted => 'Şifre Silindi';

  @override
  String get auditLogUnknownAction => 'Bilinmeyen İşlem';

  @override
  String get auditLogEmpty => 'Henüz aktivite yok';

  @override
  String auditLogEmptyCategory(String category) {
    return '$category kategorisinde kayıt yok';
  }

  @override
  String get auditLogError => 'Hata';

  @override
  String get auditLogRetry => 'Tekrar Dene';

  @override
  String get supportTicketTitle => 'Destek';

  @override
  String get supportTicketMyTickets => 'Taleplerim';

  @override
  String get supportTicketNew => 'Yeni Talep';

  @override
  String get supportTicketQuestion => 'Nasıl yardımcı olabiliriz?';

  @override
  String get supportTicketCategoryLabel => 'Kategori';

  @override
  String get supportTicketCategoryBug => 'Hata Bildirimi';

  @override
  String get supportTicketCategorySuggestion => 'Öneri';

  @override
  String get supportTicketCategoryOther => 'Diğer';

  @override
  String get supportTicketSubjectLabel => 'Konu';

  @override
  String get supportTicketSubjectError => 'Konu gerekli';

  @override
  String get supportTicketSubjectMinError => 'En az 5 karakter';

  @override
  String get supportTicketMessageLabel => 'Mesajınız';

  @override
  String get supportTicketMessageError => 'Mesaj gerekli';

  @override
  String get supportTicketMessageMinError => 'En az 20 karakter';

  @override
  String get supportTicketPriorityLabel => 'Öncelik';

  @override
  String get supportTicketPriorityLow => 'Düşük';

  @override
  String get supportTicketPriorityNormal => 'Normal';

  @override
  String get supportTicketPriorityHigh => 'Yüksek';

  @override
  String get supportTicketSubmitButton => 'Gönder';

  @override
  String get supportTicketStatusOpen => 'Açık';

  @override
  String get supportTicketStatusInProgress => 'İşlemde';

  @override
  String get supportTicketStatusClosed => 'Kapalı';

  @override
  String get supportTicketAdminReply => 'Destek Yanıtı';

  @override
  String get supportTicketWaitingReply => 'Yanıt bekleniyor...';

  @override
  String get supportTicketReplied => 'Yanıtlandı';

  @override
  String get supportTicketWaitingReplyLong => 'Yanıt bekleniyor';

  @override
  String get supportTicketSuccess => 'Destek talebiniz gönderildi';

  @override
  String get supportTicketError => 'Hata oluştu';

  @override
  String get supportTicketLoadingError => 'Talepler yüklenemedi';

  @override
  String get supportTicketLoadingRetry => 'Tekrar Dene';

  @override
  String get supportTicketDetailMessage => 'Mesajınız';

  @override
  String get supportTicketDeleteConfirmTitle => 'Talep Silinsin mi?';

  @override
  String get supportTicketDeleteConfirmMessage =>
      'Bu destek talebi kalıcı olarak silinecek.';

  @override
  String get supportTicketDeleteCancel => 'İptal';

  @override
  String get supportTicketDeleteConfirm => 'Sil';

  @override
  String get supportTicketDeleteSuccess => 'Talep silindi';

  @override
  String get forceUpdateTitle => 'Güncelleme Gerekli';

  @override
  String get forceUpdateDescription =>
      'Bu sürüm artık desteklenmiyor.\nDevam etmek için lütfen uygulamayı güncelleyin.';

  @override
  String get forceUpdateCurrentVersion => 'Mevcut sürüm';

  @override
  String get forceUpdateMinimumVersion => 'Gerekli sürüm';

  @override
  String get forceUpdateButton => 'Güncelle';

  @override
  String get forceUpdateButtonResume => 'Devam Et';

  @override
  String forceUpdateDownloading(int progress) {
    return 'İndiriliyor... %$progress';
  }

  @override
  String forceUpdateError(String error) {
    return 'İndirme başarısız: $error';
  }

  @override
  String forceUpdateInstallError(String error) {
    return 'Kurulum başlatılamadı: $error';
  }

  @override
  String get forceUpdatePermissionTitle => 'İzin Gerekiyor';

  @override
  String get forceUpdatePermissionContent =>
      'APK yükleyebilmek için \"Bilinmeyen uygulamaları yükle\" iznini vermeniz gerekiyor.\n\nAyarlar → Uygulamalar → DeniKey → Bilinmeyen uygulamaları yükle → İzin Ver\n\nİzni verdikten sonra \"Güncelle\" butonuna tekrar basın.';

  @override
  String get forceUpdatePermissionOpenSettings => 'Ayarları Aç';

  @override
  String get forceUpdatePermissionUnderstand => 'Anladım';

  @override
  String get navBarSupport => 'Destek';

  @override
  String get navBarLibrary => 'Kütüphane';

  @override
  String get navBarVault => 'Kasam';

  @override
  String get navBarGenerator => 'Üretici';

  @override
  String get navBarSettings => 'Ayarlar';

  @override
  String get desktopOnboardingTitle => 'Masaüstü Kısayolları';

  @override
  String get desktopOnboardingDescription =>
      'DeniKey\'i daha hızlı kullanmak için bu kısayolları deneyin.';

  @override
  String get desktopOnboardingShortcut1 => 'Kasam / Kütüphane / Ayarlar';

  @override
  String get desktopOnboardingShortcut2 => 'Yeni şifre ekle';

  @override
  String get desktopOnboardingShortcut3 => 'Arama';

  @override
  String get desktopOnboardingShortcut4 => 'Şifre Üretici';

  @override
  String get desktopOnboardingShortcut5 => 'Sekmeler arası geçiş';

  @override
  String get desktopOnboardingShortcut6 => 'Geri git / kapat';

  @override
  String get desktopOnboardingWindowsNote =>
      'X butonu uygulamayı kapatır. Sistem tepsisindeki simgeye sağ tıklayarak da çıkış yapabilirsiniz.';

  @override
  String get desktopOnboardingButton => 'Anladım';

  @override
  String get splashSubtitle => 'Sıfır Bilgi · Tam Güvenlik';

  @override
  String get settingsAutoLockUnlimited => 'Süresiz';

  @override
  String settingsAutoLockMinutesChip(int minutes) {
    return '$minutes dk';
  }

  @override
  String settingsClipboardSecondsChip(int seconds) {
    return '$seconds sn';
  }

  @override
  String get settingsClipboardUnlimited => 'Sınırsız';

  @override
  String get settingsDeviceJustNow => 'Az önce';

  @override
  String settingsDeviceMinutesAgo(int minutes) {
    return '$minutes dakika önce';
  }

  @override
  String settingsDeviceHoursAgo(int hours) {
    return '$hours saat önce';
  }

  @override
  String settingsDeviceDaysAgo(int days) {
    return '$days gün önce';
  }

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingStart => 'Başla';

  @override
  String get onboardingClose => 'Kapat';

  @override
  String get onboardingWelcomeTitle => 'DeniKey\'e Hoş Geldiniz';

  @override
  String get onboardingWelcomeSubtitle =>
      'Şifreleriniz, kartlarınız ve dijital kimlikleriniz tek bir güvenli yerde — yalnızca sizin elinizde.';

  @override
  String get onboardingChipZeroKnowledge => 'Sıfır Bilgi';

  @override
  String get onboardingChipMultiPlatform => 'Çok Platform';

  @override
  String get onboardingChipSync => 'Anlık Senkron';

  @override
  String get onboardingVaultTitle => 'Kasanız Her Şeyi Saklar';

  @override
  String get onboardingVaultSubtitle =>
      'Şifreler, kartlar, notlar ve özel alanlar. Tek dokunuşla kopyalayın, gizli alanları isteğe göre maskeleyin.';

  @override
  String get onboardingVaultActionCopy => 'Kopyala';

  @override
  String get onboardingVaultActionShow => 'Göster';

  @override
  String get onboardingVaultActionEdit => 'Düzenle';

  @override
  String get onboardingVaultMockBankCard => 'Banka Kartı';

  @override
  String get onboardingChipQuickAdd => 'Hızlı Ekle';

  @override
  String get onboardingChipFavorites => 'Favoriler';

  @override
  String get onboardingChipHiddenField => 'Gizli Alan';

  @override
  String get onboardingChipTrash => 'Çöp Kutusu';

  @override
  String get onboardingLibraryCategorySocialMedia => 'Sosyal Medya';

  @override
  String get onboardingLibraryCategoryWork => 'İş';

  @override
  String get onboardingChipCustomize => 'Özelleştir';

  @override
  String get onboardingGeneratorTitle => 'Güçlü Şifreler Üretin';

  @override
  String get onboardingGeneratorSubtitle =>
      'Uzunluk, büyük/küçük harf, rakam ve özel karakter seçenekleriyle tek tıkta kırılması zor şifreler oluşturun.';

  @override
  String get onboardingGeneratorSectionLabel => 'Şifre Üretici';

  @override
  String get onboardingGeneratorStrengthLabel => 'Güç:';

  @override
  String get onboardingGeneratorStrengthVeryStrong => 'Çok Güçlü';

  @override
  String onboardingGeneratorLengthOption(int n) {
    return 'Uzunluk: $n';
  }

  @override
  String get onboardingChipRefresh => 'Yenile';

  @override
  String get onboardingSecurityTitle => 'Tam Kontrol Sizde';

  @override
  String get onboardingSecuritySubtitle =>
      'Parmak izi, otomatik kilit, cihaz yasaklama ve denetim kaydı ile güvenliğinizi her açıdan yönetin.';

  @override
  String get onboardingSecurityBiometric => 'Biyometrik';

  @override
  String get onboardingSecurityBiometricDesc => 'Parmak izi ile hızlı erişim';

  @override
  String get onboardingSecurityAutoLock => 'Otomatik Kilit';

  @override
  String get onboardingSecurityAutoLockDesc =>
      'Süre veya odak kaybıyla kilitle';

  @override
  String get onboardingSecurityDeviceManagement => 'Cihaz Yönetimi';

  @override
  String get onboardingSecurityDeviceManagementDesc =>
      'Oturumları görüntüle ve sonlandır';

  @override
  String get onboardingSecurityAuditLog => 'Denetim Kaydı';

  @override
  String get onboardingSecurityAuditLogDesc => 'Her işlemi takip et';

  @override
  String get onboardingSecurityZeroKnowledgeTitle => 'Sıfır Bilgi Mimarisi';

  @override
  String get onboardingSecurityZeroKnowledgeDesc =>
      'Master şifreniz hiçbir zaman sunucuya gönderilmez.';

  @override
  String get onboardingReadyTitle => 'Başlamaya Hazır mısınız?';

  @override
  String get onboardingReadySubtitle =>
      'Hesap oluşturun ya da giriş yapın. Güvenlik artık karmaşık değil.';

  @override
  String get onboardingReplayTitle => 'Her Şeyi Hatırladınız!';

  @override
  String get onboardingReplaySubtitle =>
      'Sorularınız için Ayarlar → Destek Talebi kısmından bize ulaşabilirsiniz.';

  @override
  String get onboardingSummaryZeroKnowledge =>
      'Sıfır bilgi — veriler yalnızca sizin';

  @override
  String get onboardingSummaryAddPassword => 'Kasam → şifre ekle ve yönet';

  @override
  String get onboardingSummaryGenerator => 'Güçlü şifreler üret';

  @override
  String get onboardingSummaryBiometric => 'Biyometrik ile hızlı giriş';

  @override
  String get vaultItemUntitled => 'İsimsiz';

  @override
  String get vaultItemDetailFallbackTitle => 'Detay';

  @override
  String get categoriesUncategorized => 'Kategorisizler';

  @override
  String get networkError => 'Sunucuya bağlanılamadı';

  @override
  String get addItemTypeCreateTitle => 'Yeni Tip Oluştur';

  @override
  String get addItemTypeFieldsLabel => 'Alanlar';

  @override
  String get onboardingCategoriesTitle => 'Kategorilerle düzenle';

  @override
  String get onboardingCategoriesSubtitle =>
      'Şifrelerini klasörler halinde grupla. Kategorisizler her zaman oradadır ve silinemez.';

  @override
  String get onboardingCategoriesDefault => 'Kategorisizler';

  @override
  String get onboardingCategoriesDefaultLock => 'Silinemez & Düzenlenemez';

  @override
  String get onboardingCategoriesChipDefault => 'Varsayılan Klasör';

  @override
  String get onboardingCategoriesChipCustom => 'Özel Kategoriler';

  @override
  String get onboardingCategoriesChipOrganize => 'Düzenle';

  @override
  String get onboardingTypesTitle => 'Şablonlarla hızlan';

  @override
  String get onboardingTypesSubtitle =>
      'Sık kullandığın alan gruplarını bir kez tanımla. Her yeni şifrede hazır gelsin.';

  @override
  String get onboardingTypesWithout => 'Tipsiz';

  @override
  String get onboardingTypesWith => 'Tip seçilince';

  @override
  String get onboardingTypesChipTemplate => 'Şablon';

  @override
  String get onboardingTypesChipSpeed => 'Hızlı Kayıt';

  @override
  String get onboardingTypesChipCustomize => 'Özelleştir';

  @override
  String get notifAutoLockTitle => 'DeniKey Kilitlendi';

  @override
  String get notifAutoLockBody =>
      'Otomatik kilit devreye girdi. Devam etmek için master şifrenizi girin.';

  @override
  String get notifNewDeviceTitle => 'Yeni Cihaz Girişi';

  @override
  String get notifNewDeviceBody =>
      'Hesabınıza yeni bir cihazdan giriş denemesi var. Siz değilseniz şifrenizi hemen değiştirin.';

  @override
  String get notifChannelName => 'DeniKey Bildirimleri';

  @override
  String get notifChannelDesc =>
      'Güvenlik hatırlatıcıları ve önemli bildirimler';

  @override
  String get biometricFaceLabel => 'Yüz Tanıma ile Aç';

  @override
  String get biometricFingerprintLabel => 'Parmak İzi ile Aç';

  @override
  String get biometricPinLabel => 'Cihaz Kilidi ile Aç';

  @override
  String get biometricReason =>
      'DeniKey\'e erişmek için kimliğinizi doğrulayın';

  @override
  String get trayOpen => 'DeniKey\'i Aç';

  @override
  String get trayExit => 'Çıkış';

  @override
  String get shortcutSupport => 'Destek Talebi';

  @override
  String get shortcutVault => 'Kasama git';

  @override
  String get shortcutLibrary => 'Kütüphaneye git';

  @override
  String get shortcutSettings => 'Ayarlara git';

  @override
  String get shortcutNewPassword => 'Yeni şifre ekle';

  @override
  String get shortcutSearch => 'Arama';

  @override
  String get shortcutGenerator => 'Şifre Üretici';

  @override
  String get shortcutNewPasswordVault => 'Yeni şifre (kasam ekranı)';

  @override
  String get shortcutTabSwitch => 'Sekmeler arası geçiş';

  @override
  String get shortcutBack => 'Geri git';

  @override
  String get authLoadingLogin => 'Giriş yapılıyor...';

  @override
  String get authLoadingRegister => 'Hesap oluşturuluyor...';

  @override
  String get authErrorLogin => 'Giriş başarısız.';

  @override
  String get authErrorRegister => 'Kayıt başarısız.';

  @override
  String get vaultLoadingVault => 'Kasa yükleniyor...';

  @override
  String get vaultLoadingSaving => 'Kaydediliyor...';

  @override
  String get vaultLoadingUpdating => 'Güncelleniyor...';

  @override
  String get vaultLoadingDeleting => 'Siliniyor...';

  @override
  String get vaultLoadingMoving => 'Taşınıyor...';

  @override
  String vaultLoadingDeletingCount(int count) {
    return '$count kayıt siliniyor...';
  }

  @override
  String get vaultErrorTimeout =>
      'Sunucu yanıt vermedi. Lütfen tekrar deneyin.';

  @override
  String get vaultErrorLoad => 'Yüklenemedi.';

  @override
  String get vaultErrorOffline => 'İnternet bağlantısı yok.';

  @override
  String get vaultSampleTitle => 'DeniKey Örnek Kayıt';

  @override
  String get vaultSampleNotes =>
      'Bu otomatik oluşturulan bir örnek kayıttır. Kendi hesap bilgilerinizi ekledikten sonra silebilirsiniz.';

  @override
  String get errorCouldNotLoad => 'Yüklenemedi';

  @override
  String get errorCouldNotCreate => 'Oluşturulamadı';

  @override
  String get errorCouldNotUpdate => 'Güncellenemedi';

  @override
  String get errorCouldNotDelete => 'Silinemedi';

  @override
  String get offlineTitle => 'Ne yazık ki internetsiz DeniKey\'e erişemezsiniz';

  @override
  String get offlineMessage =>
      'Merak etmeyin, bu bir sorun değildir. Hesabınız ve içerikleriniz güvende. Tekrar internet bağlantısı sağladığınızda tam erişim geri gelecektir.';

  @override
  String get addItemFieldNameRequired => 'Bu alanı doldurmak zorunludur';

  @override
  String get totpSettingsTitle => 'Authenticator Koruması';

  @override
  String get totpSettingsActiveDesc =>
      'Girişlerde authenticator uygulamanızdan kod istenir';

  @override
  String get totpSettingsInactiveDesc =>
      'Girişlerde ek doğrulama kodu istenmez';

  @override
  String get totpSetupTitle => 'Authenticator Koruması Kurulumu';

  @override
  String get totpSetupStep1 => '1. QR Kodu Tarayın';

  @override
  String get totpSetupStep1Desc =>
      'Google Authenticator, Authy veya benzer bir uygulama ile aşağıdaki QR kodu tarayın.';

  @override
  String get totpSetupStep2 => '2. Doğrulama Kodunu Girin';

  @override
  String get totpSetupStep2Desc =>
      'Uygulamanızın gösterdiği 6 haneli kodu girerek kurulumu tamamlayın.';

  @override
  String get totpSetupManualKey => 'Elle Giriş için Anahtar';

  @override
  String get totpSetupActivate => 'Etkinleştir';

  @override
  String get totpSetupLoadError => 'Kurulum bilgileri yüklenemedi';

  @override
  String get totpSecretCopied => 'Anahtar kopyalandı';

  @override
  String get totpCodeLabel => '6 haneli kod';

  @override
  String get totpInvalidCode => 'Geçersiz kod, tekrar deneyin';

  @override
  String get totpEnabledSuccess => 'Authenticator Koruması etkinleştirildi';

  @override
  String get totpVerifyTitle => 'Authenticator Koruması';

  @override
  String get totpVerifyDesc =>
      'Authenticator uygulamanızın gösterdiği 6 haneli kodu girin.';

  @override
  String get totpVerifyButton => 'Doğrula';

  @override
  String get totpDisableTitle => 'Korumayı Devre Dışı Bırak';

  @override
  String get totpDisableDesc =>
      'Authenticator Korumasını devre dışı bırakmak için master password\'ünüzü girin.';

  @override
  String get totpDisableMasterPasswordLabel => 'Master Password';

  @override
  String get totpDisableMasterPasswordError => 'Master password hatalı';

  @override
  String get totpDisabledSuccess =>
      'Authenticator Koruması devre dışı bırakıldı';

  @override
  String get totpDisableConfirm => 'Devre Dışı Bırak';

  @override
  String get totpTrustDurationLabel => 'Doğrulama sıklığı';

  @override
  String get totpTrustAlways => 'Her seferinde';

  @override
  String get totpTrust12h => '12 saat';

  @override
  String get totpTrust1d => '1 gün';

  @override
  String get totpTrust7d => '7 gün';

  @override
  String get totpTrust30d => '30 gün';

  @override
  String get totpTrust60d => '60 gün';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';
}
