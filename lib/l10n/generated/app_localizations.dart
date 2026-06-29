import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @loginTagline.
  ///
  /// In tr, this message translates to:
  /// **'Şifreleriniz güvende'**
  String get loginTagline;

  /// No description provided for @loginUsernameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı veya E-posta'**
  String get loginUsernameLabel;

  /// No description provided for @loginUsernameError.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı veya e-posta gerekli'**
  String get loginUsernameError;

  /// No description provided for @loginUsernameMinError.
  ///
  /// In tr, this message translates to:
  /// **'En az 3 karakter'**
  String get loginUsernameMinError;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Master Şifre'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordError.
  ///
  /// In tr, this message translates to:
  /// **'Şifre gerekli'**
  String get loginPasswordError;

  /// No description provided for @loginPasswordMinError.
  ///
  /// In tr, this message translates to:
  /// **'En az 6 karakter'**
  String get loginPasswordMinError;

  /// No description provided for @loginSubmitButton.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginSubmitButton;

  /// No description provided for @loginNoAccountQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get loginNoAccountQuestion;

  /// No description provided for @loginRegisterButton.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get loginRegisterButton;

  /// No description provided for @loginError.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get loginError;

  /// No description provided for @registerAppBarTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get registerAppBarTitle;

  /// No description provided for @registerHeading.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get registerHeading;

  /// No description provided for @registerSubheading.
  ///
  /// In tr, this message translates to:
  /// **'Kimliğiniz gizli kalır.'**
  String get registerSubheading;

  /// No description provided for @registerUsernameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı'**
  String get registerUsernameLabel;

  /// No description provided for @registerUsernameError.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı gerekli'**
  String get registerUsernameError;

  /// No description provided for @registerUsernameMinError.
  ///
  /// In tr, this message translates to:
  /// **'En az 3 karakter'**
  String get registerUsernameMinError;

  /// No description provided for @registerUsernameMaxError.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 50 karakter'**
  String get registerUsernameMaxError;

  /// No description provided for @registerEmailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get registerEmailLabel;

  /// No description provided for @registerEmailError.
  ///
  /// In tr, this message translates to:
  /// **'E-posta gerekli'**
  String get registerEmailError;

  /// No description provided for @registerEmailFormatError.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli e-posta girin'**
  String get registerEmailFormatError;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Master Şifre'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordError.
  ///
  /// In tr, this message translates to:
  /// **'Şifre gerekli'**
  String get registerPasswordError;

  /// No description provided for @registerPasswordMinError.
  ///
  /// In tr, this message translates to:
  /// **'En az 10 karakter'**
  String get registerPasswordMinError;

  /// No description provided for @registerConfirmLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get registerConfirmLabel;

  /// No description provided for @registerConfirmError.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get registerConfirmError;

  /// No description provided for @registerBirthdateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Tarihi'**
  String get registerBirthdateLabel;

  /// No description provided for @registerBirthdateHelper.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Tarihinizi Seçin'**
  String get registerBirthdateHelper;

  /// No description provided for @registerBirthdateSelect.
  ///
  /// In tr, this message translates to:
  /// **'Seçiniz'**
  String get registerBirthdateSelect;

  /// No description provided for @registerBirthdateMissing.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen doğum tarihinizi seçin'**
  String get registerBirthdateMissing;

  /// No description provided for @registerAgeRestriction.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey\'i kullanmak için en az 13 yaşında olmalısınız'**
  String get registerAgeRestriction;

  /// No description provided for @registerSubmitButton.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get registerSubmitButton;

  /// No description provided for @registerError.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get registerError;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Doğrulama'**
  String get verifyEmailTitle;

  /// No description provided for @verifyDeviceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz Doğrulama'**
  String get verifyDeviceTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine gönderilen\n6 haneli kodu girin'**
  String verifyEmailSubtitle(String email);

  /// No description provided for @verifyDeviceSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihazdan ilk kez giriş yapıyorsunuz.\n{email} adresine gönderilen 6 haneli kodu girin.'**
  String verifyDeviceSubtitle(String email);

  /// No description provided for @verifySpamWarning.
  ///
  /// In tr, this message translates to:
  /// **'Spam/Gereksiz klasörünü kontrol edin'**
  String get verifySpamWarning;

  /// No description provided for @verifyCodeError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen 6 haneli kodu girin'**
  String get verifyCodeError;

  /// No description provided for @verifySubmitButton.
  ///
  /// In tr, this message translates to:
  /// **'Doğrula'**
  String get verifySubmitButton;

  /// No description provided for @verifyResendButton.
  ///
  /// In tr, this message translates to:
  /// **'Kodu tekrar gönder'**
  String get verifyResendButton;

  /// No description provided for @verifySendSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kod tekrar gönderildi'**
  String get verifySendSuccess;

  /// No description provided for @verifySendError.
  ///
  /// In tr, this message translates to:
  /// **'Kod gönderilemedi'**
  String get verifySendError;

  /// No description provided for @changeEmailTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Değiştir'**
  String get changeEmailTitle;

  /// No description provided for @changeEmailHeading.
  ///
  /// In tr, this message translates to:
  /// **'Yeni E-posta Adresi'**
  String get changeEmailHeading;

  /// No description provided for @changeEmailDescription.
  ///
  /// In tr, this message translates to:
  /// **'Yeni e-posta adresinize doğrulama kodu gönderilecek.'**
  String get changeEmailDescription;

  /// No description provided for @changeEmailLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yeni E-posta'**
  String get changeEmailLabel;

  /// No description provided for @changeEmailError.
  ///
  /// In tr, this message translates to:
  /// **'E-posta gerekli'**
  String get changeEmailError;

  /// No description provided for @changeEmailFormatError.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta girin'**
  String get changeEmailFormatError;

  /// No description provided for @changeEmailSubmitButton.
  ///
  /// In tr, this message translates to:
  /// **'Kod Gönder'**
  String get changeEmailSubmitButton;

  /// No description provided for @changeEmailApiError.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get changeEmailApiError;

  /// No description provided for @confirmEmailChangeTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Doğrulama'**
  String get confirmEmailChangeTitle;

  /// No description provided for @confirmEmailChangeHeading.
  ///
  /// In tr, this message translates to:
  /// **'Kodu Doğrulayın'**
  String get confirmEmailChangeHeading;

  /// No description provided for @confirmEmailChangeDescription.
  ///
  /// In tr, this message translates to:
  /// **'{newEmail} adresine gönderilen 6 haneli kodu girin.'**
  String confirmEmailChangeDescription(String newEmail);

  /// No description provided for @confirmEmailChangeCodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama Kodu'**
  String get confirmEmailChangeCodeLabel;

  /// No description provided for @confirmEmailChangeCodeError.
  ///
  /// In tr, this message translates to:
  /// **'Kod gerekli'**
  String get confirmEmailChangeCodeError;

  /// No description provided for @confirmEmailChangeCodeMinError.
  ///
  /// In tr, this message translates to:
  /// **'6 haneli kodu girin'**
  String get confirmEmailChangeCodeMinError;

  /// No description provided for @confirmEmailChangeSubmitButton.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get confirmEmailChangeSubmitButton;

  /// No description provided for @confirmEmailChangeSuccess.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresiniz başarıyla güncellendi'**
  String get confirmEmailChangeSuccess;

  /// No description provided for @confirmEmailChangeApiError.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get confirmEmailChangeApiError;

  /// No description provided for @masterLockTitle.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey Kilitli'**
  String get masterLockTitle;

  /// No description provided for @masterLockPassword.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için master şifrenizi girin'**
  String get masterLockPassword;

  /// No description provided for @masterLockBiometricExpired.
  ///
  /// In tr, this message translates to:
  /// **'7 günlük biyometrik süreniz doldu.\nGüvenliğiniz için master şifrenizi girin.'**
  String get masterLockBiometricExpired;

  /// No description provided for @masterLockPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Master Şifre'**
  String get masterLockPasswordLabel;

  /// No description provided for @masterLockPasswordError.
  ///
  /// In tr, this message translates to:
  /// **'Şifre gerekli'**
  String get masterLockPasswordError;

  /// No description provided for @masterLockWrongPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yanlış master şifre'**
  String get masterLockWrongPassword;

  /// No description provided for @masterLockAuthFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik doğrulama başarısız'**
  String get masterLockAuthFailed;

  /// No description provided for @masterLockBiometricNeeded.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir kez master şifrenizi girin'**
  String get masterLockBiometricNeeded;

  /// No description provided for @masterLockButton.
  ///
  /// In tr, this message translates to:
  /// **'Kilidi Aç'**
  String get masterLockButton;

  /// No description provided for @masterLockBiometricDaysRemaining.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün sonra şifre istenecek'**
  String masterLockBiometricDaysRemaining(int days);

  /// No description provided for @masterLockBiometricTomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın şifre istenecek'**
  String get masterLockBiometricTomorrow;

  /// No description provided for @masterLockDifferentAccount.
  ///
  /// In tr, this message translates to:
  /// **'Farklı hesapla giriş yap'**
  String get masterLockDifferentAccount;

  /// No description provided for @masterLockTooManyAttempts.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla yanlış deneme. Güvenlik için oturum kapatıldı.'**
  String get masterLockTooManyAttempts;

  /// No description provided for @masterLockDeriving.
  ///
  /// In tr, this message translates to:
  /// **'Şifreleme anahtarı oluşturuluyor...'**
  String get masterLockDeriving;

  /// No description provided for @lockTitle.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey Kilitli'**
  String get lockTitle;

  /// No description provided for @lockDescription.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için kimliğinizi doğrulayın'**
  String get lockDescription;

  /// No description provided for @lockBiometricButton.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik ile Aç'**
  String get lockBiometricButton;

  /// No description provided for @lockLogoutButton.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get lockLogoutButton;

  /// No description provided for @lockAuthFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik doğrulama başarısız'**
  String get lockAuthFailed;

  /// No description provided for @deviceBannedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz Yasaklandı'**
  String get deviceBannedTitle;

  /// No description provided for @deviceBannedDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap için bu cihaz kullanılamıyor.\nHesap sahibi tarafından erişiminiz kısıtlanmıştır.'**
  String get deviceBannedDescription;

  /// No description provided for @deviceBannedBackButton.
  ///
  /// In tr, this message translates to:
  /// **'Geri Dön'**
  String get deviceBannedBackButton;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsAccountSection.
  ///
  /// In tr, this message translates to:
  /// **'HESAP'**
  String get settingsAccountSection;

  /// No description provided for @settingsUsernameChange.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı Değiştir'**
  String get settingsUsernameChange;

  /// No description provided for @settingsEmailChange.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Değiştir'**
  String get settingsEmailChange;

  /// No description provided for @settingsMyDevices.
  ///
  /// In tr, this message translates to:
  /// **'Cihazlarım'**
  String get settingsMyDevices;

  /// No description provided for @settingsAppSection.
  ///
  /// In tr, this message translates to:
  /// **'UYGULAMA'**
  String get settingsAppSection;

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguage;

  /// No description provided for @settingsPasswordGenerator.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Üretici'**
  String get settingsPasswordGenerator;

  /// No description provided for @settingsAuditLog.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite Geçmişi'**
  String get settingsAuditLog;

  /// No description provided for @settingsSupportTicket.
  ///
  /// In tr, this message translates to:
  /// **'Destek Talebi'**
  String get settingsSupportTicket;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsExportVault.
  ///
  /// In tr, this message translates to:
  /// **'Verileri Dışa Aktar'**
  String get settingsExportVault;

  /// No description provided for @settingsExportVaultSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreli JSON yedek dosyası oluştur'**
  String get settingsExportVaultSubtitle;

  /// No description provided for @settingsExportDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Verileri Dışa Aktar'**
  String get settingsExportDialogTitle;

  /// No description provided for @settingsExportDialogContent.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kasanız master şifrenizle şifrelenmiş bir JSON dosyasına aktarılacak. Dosyayı açmak için master şifreniz gereklidir.'**
  String get settingsExportDialogContent;

  /// No description provided for @settingsExportDialogButton.
  ///
  /// In tr, this message translates to:
  /// **'Dışa Aktar'**
  String get settingsExportDialogButton;

  /// No description provided for @settingsExportSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Yedek oluşturuldu'**
  String get settingsExportSuccess;

  /// No description provided for @settingsExportSavedTo.
  ///
  /// In tr, this message translates to:
  /// **'Dosya kaydedildi:\n{path}'**
  String settingsExportSavedTo(String path);

  /// No description provided for @settingsExportError.
  ///
  /// In tr, this message translates to:
  /// **'Dışa aktarma başarısız'**
  String get settingsExportError;

  /// No description provided for @settingsExportNoItems.
  ///
  /// In tr, this message translates to:
  /// **'Kasanızda henüz öğe bulunmuyor'**
  String get settingsExportNoItems;

  /// No description provided for @settingsBiometricLock.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik Kilit'**
  String get settingsBiometricLock;

  /// No description provided for @settingsBiometricActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif  ·  {days} gün sonra şifre istenecek'**
  String settingsBiometricActive(int days);

  /// No description provided for @settingsBiometricActiveTomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Aktif  ·  Yarın şifre istenecek'**
  String get settingsBiometricActiveTomorrow;

  /// No description provided for @settingsBiometricExpired.
  ///
  /// In tr, this message translates to:
  /// **'Master şifre gerekiyor — kilidi açınca yenilenir'**
  String get settingsBiometricExpired;

  /// No description provided for @settingsBiometricDescription.
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi veya yüz tanıma ile hızlı erişin.\nGüvenliğiniz için 7 günde bir master şifreniz istenecektir.'**
  String get settingsBiometricDescription;

  /// No description provided for @settingsAutoLock.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik Kilit'**
  String get settingsAutoLock;

  /// No description provided for @settingsAutoLockEnabled.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dk sonra kilitle'**
  String settingsAutoLockEnabled(int minutes);

  /// No description provided for @settingsAutoLockFocusLoss.
  ///
  /// In tr, this message translates to:
  /// **'Süresiz — odaklanmada kilitle'**
  String get settingsAutoLockFocusLoss;

  /// No description provided for @settingsAutoLockDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamadan çıkınca master şifre iste'**
  String get settingsAutoLockDisabled;

  /// No description provided for @settingsClipboardTimeout.
  ///
  /// In tr, this message translates to:
  /// **'Pano Temizleme'**
  String get settingsClipboardTimeout;

  /// No description provided for @settingsClipboardTimeoutActive.
  ///
  /// In tr, this message translates to:
  /// **'Kopyalanan şifre {timeout} sn sonra silinir'**
  String settingsClipboardTimeoutActive(int timeout);

  /// No description provided for @settingsClipboardTimeoutDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız — pano otomatik temizlenmez'**
  String get settingsClipboardTimeoutDisabled;

  /// No description provided for @settingsKeyboardShortcuts.
  ///
  /// In tr, this message translates to:
  /// **'Klavye Kısayolları'**
  String get settingsKeyboardShortcuts;

  /// No description provided for @settingsKeyboardHint.
  ///
  /// In tr, this message translates to:
  /// **'Ctrl+1/2/3, +, ←→, Esc vb.'**
  String get settingsKeyboardHint;

  /// No description provided for @settingsDarkMode.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Tema'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem ayarına göre'**
  String get settingsDarkModeSystem;

  /// No description provided for @settingsDarkModeEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get settingsDarkModeEnabled;

  /// No description provided for @settingsDarkModeDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get settingsDarkModeDisabled;

  /// No description provided for @settingsHowToUse.
  ///
  /// In tr, this message translates to:
  /// **'NASIL KULLANILIR'**
  String get settingsHowToUse;

  /// No description provided for @settingsDiscoverApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı Keşfet'**
  String get settingsDiscoverApp;

  /// No description provided for @settingsDiscoverAppDescription.
  ///
  /// In tr, this message translates to:
  /// **'Tüm özelliklere genel bakış'**
  String get settingsDiscoverAppDescription;

  /// No description provided for @settingsHelp.
  ///
  /// In tr, this message translates to:
  /// **'Yardım'**
  String get settingsHelp;

  /// No description provided for @settingsHelpAddPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Ekleme'**
  String get settingsHelpAddPassword;

  /// No description provided for @settingsHelpAddPasswordContent.
  ///
  /// In tr, this message translates to:
  /// **'Alt menüden \"Kasam\" sekmesine geçin. Sağ alttaki \"+ Yeni Şifre\" butonuna dokunun. Site adı, kullanıcı adı ve şifrenizi girin; kaydedin.'**
  String get settingsHelpAddPasswordContent;

  /// No description provided for @settingsHelpPasswordGenerator.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Üretici'**
  String get settingsHelpPasswordGenerator;

  /// No description provided for @settingsHelpPasswordGeneratorContent.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama → Şifre Üretici ekranından uzunluk, büyük/küçük harf, rakam ve özel karakter seçenekleriyle güçlü şifre üretebilirsiniz.'**
  String get settingsHelpPasswordGeneratorContent;

  /// No description provided for @settingsHelpCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler ve Türler'**
  String get settingsHelpCategories;

  /// No description provided for @settingsHelpCategoriesContent.
  ///
  /// In tr, this message translates to:
  /// **'\"Kütüphane\" sekmesinde şifrelerinizi kategorilere ayırabilir, yeni öğe türleri oluşturabilirsiniz.'**
  String get settingsHelpCategoriesContent;

  /// No description provided for @settingsHelpTrash.
  ///
  /// In tr, this message translates to:
  /// **'Çöp Kutusu'**
  String get settingsHelpTrash;

  /// No description provided for @settingsHelpTrashContent.
  ///
  /// In tr, this message translates to:
  /// **'Silinen şifreler 7 gün boyunca Çöp Kutusu\'nda tutulur. Kasam ekranının sağ üst köşesindeki çöp kutusu ikonundan erişebilirsiniz.'**
  String get settingsHelpTrashContent;

  /// No description provided for @settingsHelpZeroKnowledge.
  ///
  /// In tr, this message translates to:
  /// **'Sıfır Bilgi Güvenliği'**
  String get settingsHelpZeroKnowledge;

  /// No description provided for @settingsHelpZeroKnowledgeContent.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey\'de master şifreniz hiçbir zaman sunucuya gönderilmez ve hiçbir yerde saklanmaz. Şifreleriniz cihazınızda Argon2id algoritmasıyla türetilen bir anahtarla AES-256-GCM formatında şifrelenir; bu anahtar yalnızca sizin cihazınızda bulunur. Sunucuya yalnızca şifreli (encrypted) veri gönderilir. Master şifrenizi unutursanız verilerinizi kurtarmanın hiçbir yolu yoktur — bu, gerçek sıfır-bilgi güvenliğinin kaçınılmaz sonucudur.'**
  String get settingsHelpZeroKnowledgeContent;

  /// No description provided for @settingsLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get settingsLogout;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Kalıcı Olarak Sil'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountWarning.
  ///
  /// In tr, this message translates to:
  /// **'Tüm veriler silinir, geri alınamaz'**
  String get settingsDeleteAccountWarning;

  /// No description provided for @settingsVersion.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey v{version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsDevicesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cihazlarım'**
  String get settingsDevicesTitle;

  /// No description provided for @settingsDevicesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı cihaz yok'**
  String get settingsDevicesEmpty;

  /// No description provided for @settingsDevicesError.
  ///
  /// In tr, this message translates to:
  /// **'Cihazlar yüklenemedi'**
  String get settingsDevicesError;

  /// No description provided for @settingsDeviceRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get settingsDeviceRefresh;

  /// No description provided for @settingsDeviceStatusActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get settingsDeviceStatusActive;

  /// No description provided for @settingsDeviceStatusPassive.
  ///
  /// In tr, this message translates to:
  /// **'Pasif'**
  String get settingsDeviceStatusPassive;

  /// No description provided for @settingsDeviceStatusBanned.
  ///
  /// In tr, this message translates to:
  /// **'Yasaklı'**
  String get settingsDeviceStatusBanned;

  /// No description provided for @settingsDeviceRevoke.
  ///
  /// In tr, this message translates to:
  /// **'Oturumu Sonlandır'**
  String get settingsDeviceRevoke;

  /// No description provided for @settingsDeviceRevokeSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Oturum sonlandırıldı'**
  String get settingsDeviceRevokeSuccess;

  /// No description provided for @settingsDeviceBan.
  ///
  /// In tr, this message translates to:
  /// **'Cihazı Yasakla'**
  String get settingsDeviceBan;

  /// No description provided for @settingsDeviceBanSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz yasaklandı'**
  String get settingsDeviceBanSuccess;

  /// No description provided for @settingsDeviceUnban.
  ///
  /// In tr, this message translates to:
  /// **'Yasağı Kaldır'**
  String get settingsDeviceUnban;

  /// No description provided for @settingsDeviceUnbanSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz yasağı kaldırıldı'**
  String get settingsDeviceUnbanSuccess;

  /// No description provided for @settingsDeviceActionFailed.
  ///
  /// In tr, this message translates to:
  /// **'İşlem başarısız'**
  String get settingsDeviceActionFailed;

  /// No description provided for @settingsDeviceRemove.
  ///
  /// In tr, this message translates to:
  /// **'Cihazı Sil'**
  String get settingsDeviceRemove;

  /// No description provided for @settingsDeviceRemoveConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihaz kalıcı olarak silinecek. Emin misiniz?'**
  String get settingsDeviceRemoveConfirm;

  /// No description provided for @settingsDeviceRemoveSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz silindi'**
  String get settingsDeviceRemoveSuccess;

  /// No description provided for @settingsDeviceRename.
  ///
  /// In tr, this message translates to:
  /// **'Adı Değiştir'**
  String get settingsDeviceRename;

  /// No description provided for @settingsDeviceRenameHint.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz adı'**
  String get settingsDeviceRenameHint;

  /// No description provided for @settingsDeviceRenameSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz adı güncellendi'**
  String get settingsDeviceRenameSuccess;

  /// No description provided for @settingsUsernameChangeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı Değiştir'**
  String get settingsUsernameChangeTitle;

  /// No description provided for @settingsUsernameChangeHint.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kullanıcı adı'**
  String get settingsUsernameChangeHint;

  /// No description provided for @settingsUsernameChangeError.
  ///
  /// In tr, this message translates to:
  /// **'Boş bırakılamaz'**
  String get settingsUsernameChangeError;

  /// No description provided for @settingsUsernameChangeMinError.
  ///
  /// In tr, this message translates to:
  /// **'En az 3 karakter'**
  String get settingsUsernameChangeMinError;

  /// No description provided for @settingsUsernameChangePatternError.
  ///
  /// In tr, this message translates to:
  /// **'Sadece harf, rakam ve _ kullanılabilir'**
  String get settingsUsernameChangePatternError;

  /// No description provided for @settingsUsernameChangeSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı güncellendi'**
  String get settingsUsernameChangeSaved;

  /// No description provided for @settingsUsernameChangeFailed.
  ///
  /// In tr, this message translates to:
  /// **'Güncellenemedi'**
  String get settingsUsernameChangeFailed;

  /// No description provided for @settingsDeleteAccountStep1.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil — Adım 1/4'**
  String get settingsDeleteAccountStep1;

  /// No description provided for @settingsDeleteAccountWarningContent.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.'**
  String get settingsDeleteAccountWarningContent;

  /// No description provided for @settingsDeleteAccountUsernameHint.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adınızı girin'**
  String get settingsDeleteAccountUsernameHint;

  /// No description provided for @settingsDeleteAccountStep2.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil — Adım 2/4'**
  String get settingsDeleteAccountStep2;

  /// No description provided for @settingsDeleteAccountPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'Master şifrenizi girin'**
  String get settingsDeleteAccountPasswordHint;

  /// No description provided for @settingsDeleteAccountStep3.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil — Adım 3/4'**
  String get settingsDeleteAccountStep3;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Gerçekten hesabınızı silmek istiyor musunuz?'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccountCountdownWait.
  ///
  /// In tr, this message translates to:
  /// **'{seconds} saniye beklemeniz gerekiyor...'**
  String settingsDeleteAccountCountdownWait(int seconds);

  /// No description provided for @settingsDeleteAccountCountdownReady.
  ///
  /// In tr, this message translates to:
  /// **'Devam edebilirsiniz.'**
  String get settingsDeleteAccountCountdownReady;

  /// No description provided for @settingsDeleteAccountYesConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Devam Et'**
  String get settingsDeleteAccountYesConfirm;

  /// No description provided for @settingsDeleteAccountStep4.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil — Adım 4/4'**
  String get settingsDeleteAccountStep4;

  /// No description provided for @settingsDeleteAccountFinalMessage.
  ///
  /// In tr, this message translates to:
  /// **'Son adım: şifrenizi bir kez daha girin.'**
  String get settingsDeleteAccountFinalMessage;

  /// No description provided for @settingsDeleteAccountPasswordConfirmHint.
  ///
  /// In tr, this message translates to:
  /// **'Master şifrenizi tekrar girin'**
  String get settingsDeleteAccountPasswordConfirmHint;

  /// No description provided for @settingsDeleteAccountFinalButton.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Kalıcı Sil'**
  String get settingsDeleteAccountFinalButton;

  /// No description provided for @settingsDeleteAccountFailed.
  ///
  /// In tr, this message translates to:
  /// **'Hesap silinemedi'**
  String get settingsDeleteAccountFailed;

  /// No description provided for @settingsDeleteAccountCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get settingsDeleteAccountCancel;

  /// No description provided for @settingsDeleteAccountContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get settingsDeleteAccountContinue;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyLastUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Son güncelleme: Nisan 2026'**
  String get privacyPolicyLastUpdate;

  /// No description provided for @privacyPolicySection1Title.
  ///
  /// In tr, this message translates to:
  /// **'1. Giriş'**
  String get privacyPolicySection1Title;

  /// No description provided for @privacyPolicySection1Body.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey (\"uygulama\", \"biz\", \"hizmet\"), sıfır-bilgi (zero-knowledge) mimarisiyle çalışan bir şifre yöneticisidir. Bu Gizlilik Politikası, uygulamayı kullanırken hangi verilerin toplandığını, nasıl işlendiğini ve haklarınızı açıklamaktadır.'**
  String get privacyPolicySection1Body;

  /// No description provided for @privacyPolicySection2Title.
  ///
  /// In tr, this message translates to:
  /// **'2. Toplanan Veriler'**
  String get privacyPolicySection2Title;

  /// No description provided for @privacyPolicySection2Body.
  ///
  /// In tr, this message translates to:
  /// **'• E-posta adresi ve kullanıcı adı — hesap oluşturma ve kimlik doğrulama için.\n• Master şifrenizin türetilmiş doğrulama değeri (hash) — düz metin asla saklanmaz.\n• Şifrelenmiş kasa verileri — cihazınızda AES-256-GCM ile şifrelendikten sonra sunucuya gönderilir; içeriği yalnızca siz okuyabilirsiniz.\n• Oturum tokenları ve cihaz kimliği — çoklu cihaz yönetimi için.\n• Denetim kayıtları (audit log) — hesap güvenliğinizi izlemeniz için, yalnızca sizin erişiminize açıktır.'**
  String get privacyPolicySection2Body;

  /// No description provided for @privacyPolicySection3Title.
  ///
  /// In tr, this message translates to:
  /// **'3. Sıfır Bilgi Mimarisi'**
  String get privacyPolicySection3Title;

  /// No description provided for @privacyPolicySection3Body.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey, master şifrenizi hiçbir zaman sunucuya göndermez ve hiçbir yerde saklamaz. Kasa verileriniz cihazınızda, Argon2id algoritmasıyla türetilen bir anahtar ile AES-256-GCM formatında şifrelenir. Sunucularımız yalnızca şifreli (encrypted) veri depolar; içeriğinize teknik olarak erişim imkânımız yoktur.\n\nMaster şifrenizi unutursanız verilerinizi kurtarmanın hiçbir yolu yoktur — bu, gerçek sıfır-bilgi güvenliğinin kaçınılmaz sonucudur.'**
  String get privacyPolicySection3Body;

  /// No description provided for @privacyPolicySection4Title.
  ///
  /// In tr, this message translates to:
  /// **'4. Verilerin Kullanımı'**
  String get privacyPolicySection4Title;

  /// No description provided for @privacyPolicySection4Body.
  ///
  /// In tr, this message translates to:
  /// **'Topladığımız veriler yalnızca şu amaçlarla kullanılır:\n• Hesabınızın oluşturulması ve yönetilmesi\n• Kimlik doğrulama ve oturum güvenliği\n• E-posta doğrulama ve şifre sıfırlama bildirimleri\n• Destek taleplerinize yanıt verilmesi\n\nVerileriniz üçüncü taraflarla paylaşılmaz, reklam amacıyla kullanılmaz.'**
  String get privacyPolicySection4Body;

  /// No description provided for @privacyPolicySection5Title.
  ///
  /// In tr, this message translates to:
  /// **'5. Veri Güvenliği'**
  String get privacyPolicySection5Title;

  /// No description provided for @privacyPolicySection5Body.
  ///
  /// In tr, this message translates to:
  /// **'• Tüm iletişim HTTPS/TLS üzerinden şifrelenmiş biçimde gerçekleşir.\n• Kasa verileri sunucuda şifreli olarak saklanır.\n• Şifreler Argon2id (memory: 64 MB, iterations: 3, parallelism: 2) ile türetilir; kaba kuvvet saldırılarına karşı dayanıklıdır.\n• JWT tokenlar kısa ömürlüdür ve yenileme mekanizması ile yönetilir.'**
  String get privacyPolicySection5Body;

  /// No description provided for @privacyPolicySection6Title.
  ///
  /// In tr, this message translates to:
  /// **'6. Hesap Silme'**
  String get privacyPolicySection6Title;

  /// No description provided for @privacyPolicySection6Body.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı istediğiniz zaman Ayarlar → Hesabı Kalıcı Olarak Sil adımından silebilirsiniz. Silme işlemi 4 adımlı onay gerektirir ve tüm verileriniz (kasa öğeleri, kategoriler, audit kayıtları dahil) kalıcı olarak kaldırılır. Bu işlem geri alınamaz.'**
  String get privacyPolicySection6Body;

  /// No description provided for @privacyPolicySection7Title.
  ///
  /// In tr, this message translates to:
  /// **'7. Çocukların Gizliliği'**
  String get privacyPolicySection7Title;

  /// No description provided for @privacyPolicySection7Body.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey, 13 yaşın altındaki çocuklara yönelik değildir. Bilerek bu yaş grubundan veri toplamıyoruz.'**
  String get privacyPolicySection7Body;

  /// No description provided for @privacyPolicySection8Title.
  ///
  /// In tr, this message translates to:
  /// **'8. Politika Değişiklikleri'**
  String get privacyPolicySection8Title;

  /// No description provided for @privacyPolicySection8Body.
  ///
  /// In tr, this message translates to:
  /// **'Bu politikayı güncelleyebiliriz. Önemli değişiklikler kayıtlı e-posta adresinize bildirilir. Güncel politika her zaman uygulama içinden erişilebilir.'**
  String get privacyPolicySection8Body;

  /// No description provided for @privacyPolicySection9Title.
  ///
  /// In tr, this message translates to:
  /// **'9. İletişim'**
  String get privacyPolicySection9Title;

  /// No description provided for @privacyPolicySection9Body.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ile ilgili sorularınız için destek talebi oluşturabilir ya da uygulama içindeki Destek Talebi ekranını kullanabilirsiniz.'**
  String get privacyPolicySection9Body;

  /// No description provided for @vaultTitle.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey'**
  String get vaultTitle;

  /// No description provided for @vaultSearchTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get vaultSearchTooltip;

  /// No description provided for @vaultTrashTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Çöp Kutusu'**
  String get vaultTrashTooltip;

  /// No description provided for @vaultRefreshTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get vaultRefreshTooltip;

  /// No description provided for @vaultOfflineWarning.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı olmadan kasanıza erişemezsiniz'**
  String get vaultOfflineWarning;

  /// No description provided for @vaultOfflineWarningDesktop.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı mod — Salt okunur'**
  String get vaultOfflineWarningDesktop;

  /// No description provided for @vaultBulkDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Toplu Sil'**
  String get vaultBulkDeleteTitle;

  /// No description provided for @vaultBulkDeleteMessage.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıt çöp kutusuna taşınacak. Devam edilsin mi?'**
  String vaultBulkDeleteMessage(int count);

  /// No description provided for @vaultBulkSelectAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get vaultBulkSelectAll;

  /// No description provided for @vaultBulkMoveTitle.
  ///
  /// In tr, this message translates to:
  /// **'{count} kaydı taşı'**
  String vaultBulkMoveTitle(int count);

  /// No description provided for @vaultBulkMoveUncategorized.
  ///
  /// In tr, this message translates to:
  /// **'Kategorisiz'**
  String get vaultBulkMoveUncategorized;

  /// No description provided for @vaultCategoryEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoride şifre yok'**
  String get vaultCategoryEmpty;

  /// No description provided for @vaultEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz şifre yok'**
  String get vaultEmpty;

  /// No description provided for @vaultEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'+ ile yeni şifre ekleyin'**
  String get vaultEmptyHint;

  /// No description provided for @vaultFavoritesSection.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get vaultFavoritesSection;

  /// No description provided for @vaultOthersSection.
  ///
  /// In tr, this message translates to:
  /// **'Diğerleri'**
  String get vaultOthersSection;

  /// No description provided for @vaultFavoritesAdd.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere ekle'**
  String get vaultFavoritesAdd;

  /// No description provided for @vaultFavoritesRemove.
  ///
  /// In tr, this message translates to:
  /// **'Favoriden çıkar'**
  String get vaultFavoritesRemove;

  /// No description provided for @vaultAddButton.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get vaultAddButton;

  /// No description provided for @vaultBulkDeleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get vaultBulkDeleteButton;

  /// No description provided for @vaultBulkMoveButton.
  ///
  /// In tr, this message translates to:
  /// **'Taşı'**
  String get vaultBulkMoveButton;

  /// No description provided for @vaultBulkFavoritesButton.
  ///
  /// In tr, this message translates to:
  /// **'Favoriye ekle'**
  String get vaultBulkFavoritesButton;

  /// No description provided for @vaultBulkFavoritesRemoveButton.
  ///
  /// In tr, this message translates to:
  /// **'Favoriden çıkar'**
  String get vaultBulkFavoritesRemoveButton;

  /// No description provided for @vaultLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get vaultLoading;

  /// No description provided for @vaultError.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get vaultError;

  /// No description provided for @vaultRetry.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden Dene'**
  String get vaultRetry;

  /// No description provided for @vaultBulkSelectionCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} seçildi'**
  String vaultBulkSelectionCount(int count);

  /// No description provided for @addItemStep0.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Seç'**
  String get addItemStep0;

  /// No description provided for @addItemStep2.
  ///
  /// In tr, this message translates to:
  /// **'Bilgileri Gir'**
  String get addItemStep2;

  /// No description provided for @addItemUncategorized.
  ///
  /// In tr, this message translates to:
  /// **'Kategorisiz'**
  String get addItemUncategorized;

  /// No description provided for @addItemUncategorizedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategorisizler altında sakla'**
  String get addItemUncategorizedSubtitle;

  /// No description provided for @addItemCreateCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Oluştur'**
  String get addItemCreateCategory;

  /// No description provided for @addItemCreateCategorySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kategori ekle'**
  String get addItemCreateCategorySubtitle;

  /// No description provided for @addItemNewCategory.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kategori'**
  String get addItemNewCategory;

  /// No description provided for @addItemNewCategoryName.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Adı'**
  String get addItemNewCategoryName;

  /// No description provided for @addItemTypeNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tip Adı'**
  String get addItemTypeNameLabel;

  /// No description provided for @addItemTypeSelectIcon.
  ///
  /// In tr, this message translates to:
  /// **'İkon Seç'**
  String get addItemTypeSelectIcon;

  /// No description provided for @addItemTypeFixedFields.
  ///
  /// In tr, this message translates to:
  /// **'Sabit Alanlar'**
  String get addItemTypeFixedFields;

  /// No description provided for @addItemTypeFieldAdd.
  ///
  /// In tr, this message translates to:
  /// **'Alan Ekle'**
  String get addItemTypeFieldAdd;

  /// No description provided for @addItemTypeFieldDefault.
  ///
  /// In tr, this message translates to:
  /// **'Alan eklenmedi — varsayılan olarak \"Şifre\" alanı oluşturulur.'**
  String get addItemTypeFieldDefault;

  /// No description provided for @addItemTypeFieldName.
  ///
  /// In tr, this message translates to:
  /// **'Alan Adı'**
  String get addItemTypeFieldName;

  /// No description provided for @addItemTypeFieldType.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get addItemTypeFieldType;

  /// No description provided for @addItemTypeFieldTypeText.
  ///
  /// In tr, this message translates to:
  /// **'Metin'**
  String get addItemTypeFieldTypeText;

  /// No description provided for @addItemTypeFieldTypeSecret.
  ///
  /// In tr, this message translates to:
  /// **'Gizli'**
  String get addItemTypeFieldTypeSecret;

  /// No description provided for @addItemTypeFieldTypeNumber.
  ///
  /// In tr, this message translates to:
  /// **'Sayı'**
  String get addItemTypeFieldTypeNumber;

  /// No description provided for @addItemTypeFieldTypeDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get addItemTypeFieldTypeDate;

  /// No description provided for @addItemTitleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlık *'**
  String get addItemTitleLabel;

  /// No description provided for @addItemTitleHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Instagram, Gmail, Netflix'**
  String get addItemTitleHint;

  /// No description provided for @addItemExtraFieldKeyLabel.
  ///
  /// In tr, this message translates to:
  /// **'Alan Adı'**
  String get addItemExtraFieldKeyLabel;

  /// No description provided for @addItemExtraFieldValueLabel.
  ///
  /// In tr, this message translates to:
  /// **'Değer'**
  String get addItemExtraFieldValueLabel;

  /// No description provided for @addItemAddFieldButton.
  ///
  /// In tr, this message translates to:
  /// **'Alan Ekle'**
  String get addItemAddFieldButton;

  /// No description provided for @addItemSaveButton.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get addItemSaveButton;

  /// No description provided for @addItemPasswordStrengthVeryWeak.
  ///
  /// In tr, this message translates to:
  /// **'Çok Zayıf'**
  String get addItemPasswordStrengthVeryWeak;

  /// No description provided for @addItemPasswordStrengthWeak.
  ///
  /// In tr, this message translates to:
  /// **'Zayıf'**
  String get addItemPasswordStrengthWeak;

  /// No description provided for @addItemPasswordStrengthMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get addItemPasswordStrengthMedium;

  /// No description provided for @addItemPasswordStrengthStrong.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü'**
  String get addItemPasswordStrengthStrong;

  /// No description provided for @addItemPasswordStrengthVeryStrong.
  ///
  /// In tr, this message translates to:
  /// **'Çok Güçlü'**
  String get addItemPasswordStrengthVeryStrong;

  /// No description provided for @addItemErrorSave.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt eklenirken bir hata oluştu.'**
  String get addItemErrorSave;

  /// No description provided for @addItemCategoryCreate.
  ///
  /// In tr, this message translates to:
  /// **'Oluştur'**
  String get addItemCategoryCreate;

  /// No description provided for @addItemTypeCreate.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get addItemTypeCreate;

  /// No description provided for @addItemCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get addItemCancel;

  /// No description provided for @detailPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get detailPasswordLabel;

  /// No description provided for @detailCategoryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Klasör'**
  String get detailCategoryLabel;

  /// No description provided for @detailCategoryUncategorized.
  ///
  /// In tr, this message translates to:
  /// **'Sınıflandırılmamış'**
  String get detailCategoryUncategorized;

  /// No description provided for @detailCategoryMove.
  ///
  /// In tr, this message translates to:
  /// **'Klasöre Taşı'**
  String get detailCategoryMove;

  /// No description provided for @detailExternalLinkTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dış Link'**
  String get detailExternalLinkTitle;

  /// No description provided for @detailExternalLinkMessage.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey bu bağlantıyı açmak üzere:\n\n{url}'**
  String detailExternalLinkMessage(String url);

  /// No description provided for @detailExternalLinkDeny.
  ///
  /// In tr, this message translates to:
  /// **'İzin Verme'**
  String get detailExternalLinkDeny;

  /// No description provided for @detailExternalLinkOnce.
  ///
  /// In tr, this message translates to:
  /// **'Bu Seferlik'**
  String get detailExternalLinkOnce;

  /// No description provided for @detailExternalLinkNoAsk.
  ///
  /// In tr, this message translates to:
  /// **'Bir Daha Sorma'**
  String get detailExternalLinkNoAsk;

  /// No description provided for @detailDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get detailDeleteTitle;

  /// No description provided for @detailDeleteMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu şifreyi silmek istediğinize emin misiniz?'**
  String get detailDeleteMessage;

  /// No description provided for @detailDeleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get detailDeleteButton;

  /// No description provided for @detailFavoritesAdd.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere ekle'**
  String get detailFavoritesAdd;

  /// No description provided for @detailFavoritesRemove.
  ///
  /// In tr, this message translates to:
  /// **'Favoriden çıkar'**
  String get detailFavoritesRemove;

  /// No description provided for @detailPasswordHistory.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Geçmişi'**
  String get detailPasswordHistory;

  /// No description provided for @detailEditButton.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get detailEditButton;

  /// No description provided for @detailCancelEdit.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get detailCancelEdit;

  /// No description provided for @detailEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get detailEditTitle;

  /// No description provided for @detailEditPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get detailEditPassword;

  /// No description provided for @detailEditCustomFieldKeyLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get detailEditCustomFieldKeyLabel;

  /// No description provided for @detailEditCustomFieldValueLabel.
  ///
  /// In tr, this message translates to:
  /// **'İçerik'**
  String get detailEditCustomFieldValueLabel;

  /// No description provided for @detailEditSaveButton.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get detailEditSaveButton;

  /// No description provided for @detailEditErrorBlankTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başlık boş olamaz'**
  String get detailEditErrorBlankTitle;

  /// No description provided for @detailEditErrorGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Güncellenemedi, tekrar deneyin'**
  String get detailEditErrorGeneral;

  /// No description provided for @detailInfoTilePasswordCopied.
  ///
  /// In tr, this message translates to:
  /// **'{label} kopyalandı, {timeout} saniye sonra silinecek'**
  String detailInfoTilePasswordCopied(String label, int timeout);

  /// No description provided for @detailInfoTileCopied.
  ///
  /// In tr, this message translates to:
  /// **'{label} kopyalandı'**
  String detailInfoTileCopied(String label);

  /// No description provided for @detailLinkOpen.
  ///
  /// In tr, this message translates to:
  /// **'Linki Aç'**
  String get detailLinkOpen;

  /// No description provided for @detailLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Bilgiler yüklenemedi: {error}'**
  String detailLoadError(String error);

  /// No description provided for @detailRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get detailRetry;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ara...'**
  String get searchHint;

  /// No description provided for @searchEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Aramak için yazmaya başlayın'**
  String get searchEmpty;

  /// No description provided for @searchNoResults.
  ///
  /// In tr, this message translates to:
  /// **'\"{query}\" için sonuç bulunamadı'**
  String searchNoResults(String query);

  /// No description provided for @passwordHistoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'{itemTitle} — Geçmiş'**
  String passwordHistoryTitle(String itemTitle);

  /// No description provided for @passwordHistoryClear.
  ///
  /// In tr, this message translates to:
  /// **'Geçmişi Temizle'**
  String get passwordHistoryClear;

  /// No description provided for @passwordHistoryClearTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmişi Temizle'**
  String get passwordHistoryClearTitle;

  /// No description provided for @passwordHistoryClearMessage.
  ///
  /// In tr, this message translates to:
  /// **'Tüm şifre geçmişi silinsin mi?'**
  String get passwordHistoryClearMessage;

  /// No description provided for @passwordHistoryEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Şifre geçmişi yok'**
  String get passwordHistoryEmpty;

  /// No description provided for @passwordHistoryEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Şifre güncellendiğinde eski sürümler burada görünür'**
  String get passwordHistoryEmptyHint;

  /// No description provided for @passwordHistoryCopy.
  ///
  /// In tr, this message translates to:
  /// **'Şifre kopyalandı, {timeout} sn sonra silinecek'**
  String passwordHistoryCopy(int timeout);

  /// No description provided for @passwordHistoryCopyNoTimeout.
  ///
  /// In tr, this message translates to:
  /// **'Şifre kopyalandı'**
  String get passwordHistoryCopyNoTimeout;

  /// No description provided for @passwordHistoryError.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemedi'**
  String get passwordHistoryError;

  /// No description provided for @passwordHistoryRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get passwordHistoryRetry;

  /// No description provided for @libraryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphane'**
  String get libraryTitle;

  /// No description provided for @libraryCategoriesTab.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get libraryCategoriesTab;

  /// No description provided for @libraryTypesTab.
  ///
  /// In tr, this message translates to:
  /// **'Türler'**
  String get libraryTypesTab;

  /// No description provided for @libraryAddCategory.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kategori'**
  String get libraryAddCategory;

  /// No description provided for @libraryCategoryName.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Adı'**
  String get libraryCategoryName;

  /// No description provided for @libraryCategoryColorSelect.
  ///
  /// In tr, this message translates to:
  /// **'Renk Seç'**
  String get libraryCategoryColorSelect;

  /// No description provided for @libraryDeleteCategoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get libraryDeleteCategoryTitle;

  /// No description provided for @libraryDeleteCategoryMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoriyi silmek istediğinize emin misiniz?'**
  String get libraryDeleteCategoryMessage;

  /// No description provided for @libraryDeleteSystemCategory.
  ///
  /// In tr, this message translates to:
  /// **'Sistem kategorileri silinemez.'**
  String get libraryDeleteSystemCategory;

  /// No description provided for @libraryDeleteSystemType.
  ///
  /// In tr, this message translates to:
  /// **'Sistem türleri silinemez.'**
  String get libraryDeleteSystemType;

  /// No description provided for @libraryEmptyCategories.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kategori yok'**
  String get libraryEmptyCategories;

  /// No description provided for @libraryEmptyTypes.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tür yok'**
  String get libraryEmptyTypes;

  /// No description provided for @librarySystemLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get librarySystemLabel;

  /// No description provided for @libraryTypeFieldCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} alan'**
  String libraryTypeFieldCount(int count);

  /// No description provided for @libraryCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get libraryCancel;

  /// No description provided for @libraryAddButton.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get libraryAddButton;

  /// No description provided for @categoryDetailEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoride henüz öğe yok'**
  String get categoryDetailEmpty;

  /// No description provided for @categoryDetailItem.
  ///
  /// In tr, this message translates to:
  /// **'İsimsiz'**
  String get categoryDetailItem;

  /// No description provided for @passwordGeneratorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Üretici'**
  String get passwordGeneratorTitle;

  /// No description provided for @passwordGeneratorHint.
  ///
  /// In tr, this message translates to:
  /// **'Şifre üretmek için butona basın'**
  String get passwordGeneratorHint;

  /// No description provided for @passwordGeneratorGenerate.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Üret'**
  String get passwordGeneratorGenerate;

  /// No description provided for @passwordGeneratorLength.
  ///
  /// In tr, this message translates to:
  /// **'Uzunluk'**
  String get passwordGeneratorLength;

  /// No description provided for @passwordGeneratorCharacterTypes.
  ///
  /// In tr, this message translates to:
  /// **'Karakter Tipleri'**
  String get passwordGeneratorCharacterTypes;

  /// No description provided for @passwordGeneratorUppercase.
  ///
  /// In tr, this message translates to:
  /// **'Büyük Harf (A–Z)'**
  String get passwordGeneratorUppercase;

  /// No description provided for @passwordGeneratorLowercase.
  ///
  /// In tr, this message translates to:
  /// **'Küçük Harf (a–z)'**
  String get passwordGeneratorLowercase;

  /// No description provided for @passwordGeneratorNumbers.
  ///
  /// In tr, this message translates to:
  /// **'Rakam (0–9)'**
  String get passwordGeneratorNumbers;

  /// No description provided for @passwordGeneratorSymbols.
  ///
  /// In tr, this message translates to:
  /// **'Sembol (!@#\$...)'**
  String get passwordGeneratorSymbols;

  /// No description provided for @passwordGeneratorCopy.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get passwordGeneratorCopy;

  /// No description provided for @passwordGeneratorCopySuccess.
  ///
  /// In tr, this message translates to:
  /// **'Şifre kopyalandı, {timeout} sn sonra silinecek'**
  String passwordGeneratorCopySuccess(int timeout);

  /// No description provided for @passwordGeneratorCopySuccessNoTimeout.
  ///
  /// In tr, this message translates to:
  /// **'Şifre kopyalandı'**
  String get passwordGeneratorCopySuccessNoTimeout;

  /// No description provided for @trashTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çöp Kutusu'**
  String get trashTitle;

  /// No description provided for @trashEmptyButton.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Sil'**
  String get trashEmptyButton;

  /// No description provided for @trashEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çöp Kutusunu Boşalt'**
  String get trashEmptyTitle;

  /// No description provided for @trashEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Tüm öğeler kalıcı olarak silinecek. Bu işlem geri alınamaz.'**
  String get trashEmptyMessage;

  /// No description provided for @trashDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı Sil'**
  String get trashDeleteTitle;

  /// No description provided for @trashDeleteMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" kalıcı olarak silinsin mi?'**
  String trashDeleteMessage(String title);

  /// No description provided for @trashDeleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get trashDeleteButton;

  /// No description provided for @trashEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Çöp kutusu boş'**
  String get trashEmpty;

  /// No description provided for @trashEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Silinen öğeler 7 gün burada saklanır'**
  String get trashEmptyHint;

  /// No description provided for @trashDeleteFor.
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihinde kalıcı silinecek'**
  String trashDeleteFor(String date);

  /// No description provided for @trashRestore.
  ///
  /// In tr, this message translates to:
  /// **'Geri Yükle'**
  String get trashRestore;

  /// No description provided for @trashDeletePermanent.
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı Sil'**
  String get trashDeletePermanent;

  /// No description provided for @trashError.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get trashError;

  /// No description provided for @trashRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get trashRetry;

  /// No description provided for @trashCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get trashCancel;

  /// No description provided for @auditLogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite Geçmişi'**
  String get auditLogTitle;

  /// No description provided for @auditLogFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get auditLogFilterAll;

  /// No description provided for @auditLogFilterAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get auditLogFilterAccount;

  /// No description provided for @auditLogFilterSecurity.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get auditLogFilterSecurity;

  /// No description provided for @auditLogFilterVault.
  ///
  /// In tr, this message translates to:
  /// **'Kasa'**
  String get auditLogFilterVault;

  /// No description provided for @auditLogActionRegister.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Olundu'**
  String get auditLogActionRegister;

  /// No description provided for @auditLogActionLoginSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yapıldı'**
  String get auditLogActionLoginSuccess;

  /// No description provided for @auditLogActionLoginFailed.
  ///
  /// In tr, this message translates to:
  /// **'Başarısız Giriş'**
  String get auditLogActionLoginFailed;

  /// No description provided for @auditLogActionLoginNewDevice.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Cihaz Girişi'**
  String get auditLogActionLoginNewDevice;

  /// No description provided for @auditLogActionLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yapıldı'**
  String get auditLogActionLogout;

  /// No description provided for @auditLogActionDeviceVerified.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz Doğrulandı'**
  String get auditLogActionDeviceVerified;

  /// No description provided for @auditLogActionEmailChanged.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Değiştirildi'**
  String get auditLogActionEmailChanged;

  /// No description provided for @auditLogActionPasswordReset.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Sıfırlandı'**
  String get auditLogActionPasswordReset;

  /// No description provided for @auditLogActionVaultItemCreated.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Eklendi'**
  String get auditLogActionVaultItemCreated;

  /// No description provided for @auditLogActionVaultItemUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Güncellendi'**
  String get auditLogActionVaultItemUpdated;

  /// No description provided for @auditLogActionVaultItemDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Silindi'**
  String get auditLogActionVaultItemDeleted;

  /// No description provided for @auditLogUnknownAction.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen İşlem'**
  String get auditLogUnknownAction;

  /// No description provided for @auditLogEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz aktivite yok'**
  String get auditLogEmpty;

  /// No description provided for @auditLogEmptyCategory.
  ///
  /// In tr, this message translates to:
  /// **'{category} kategorisinde kayıt yok'**
  String auditLogEmptyCategory(String category);

  /// No description provided for @auditLogError.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get auditLogError;

  /// No description provided for @auditLogRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get auditLogRetry;

  /// No description provided for @supportTicketTitle.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get supportTicketTitle;

  /// No description provided for @supportTicketMyTickets.
  ///
  /// In tr, this message translates to:
  /// **'Taleplerim'**
  String get supportTicketMyTickets;

  /// No description provided for @supportTicketNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Talep'**
  String get supportTicketNew;

  /// No description provided for @supportTicketQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl yardımcı olabiliriz?'**
  String get supportTicketQuestion;

  /// No description provided for @supportTicketCategoryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get supportTicketCategoryLabel;

  /// No description provided for @supportTicketCategoryBug.
  ///
  /// In tr, this message translates to:
  /// **'Hata Bildirimi'**
  String get supportTicketCategoryBug;

  /// No description provided for @supportTicketCategorySuggestion.
  ///
  /// In tr, this message translates to:
  /// **'Öneri'**
  String get supportTicketCategorySuggestion;

  /// No description provided for @supportTicketCategoryOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get supportTicketCategoryOther;

  /// No description provided for @supportTicketSubjectLabel.
  ///
  /// In tr, this message translates to:
  /// **'Konu'**
  String get supportTicketSubjectLabel;

  /// No description provided for @supportTicketSubjectError.
  ///
  /// In tr, this message translates to:
  /// **'Konu gerekli'**
  String get supportTicketSubjectError;

  /// No description provided for @supportTicketSubjectMinError.
  ///
  /// In tr, this message translates to:
  /// **'En az 5 karakter'**
  String get supportTicketSubjectMinError;

  /// No description provided for @supportTicketMessageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mesajınız'**
  String get supportTicketMessageLabel;

  /// No description provided for @supportTicketMessageError.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj gerekli'**
  String get supportTicketMessageError;

  /// No description provided for @supportTicketMessageMinError.
  ///
  /// In tr, this message translates to:
  /// **'En az 20 karakter'**
  String get supportTicketMessageMinError;

  /// No description provided for @supportTicketPriorityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Öncelik'**
  String get supportTicketPriorityLabel;

  /// No description provided for @supportTicketPriorityLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get supportTicketPriorityLow;

  /// No description provided for @supportTicketPriorityNormal.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get supportTicketPriorityNormal;

  /// No description provided for @supportTicketPriorityHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get supportTicketPriorityHigh;

  /// No description provided for @supportTicketSubmitButton.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get supportTicketSubmitButton;

  /// No description provided for @supportTicketStatusOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get supportTicketStatusOpen;

  /// No description provided for @supportTicketStatusInProgress.
  ///
  /// In tr, this message translates to:
  /// **'İşlemde'**
  String get supportTicketStatusInProgress;

  /// No description provided for @supportTicketStatusClosed.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get supportTicketStatusClosed;

  /// No description provided for @supportTicketAdminReply.
  ///
  /// In tr, this message translates to:
  /// **'Destek Yanıtı'**
  String get supportTicketAdminReply;

  /// No description provided for @supportTicketWaitingReply.
  ///
  /// In tr, this message translates to:
  /// **'Yanıt bekleniyor...'**
  String get supportTicketWaitingReply;

  /// No description provided for @supportTicketReplied.
  ///
  /// In tr, this message translates to:
  /// **'Yanıtlandı'**
  String get supportTicketReplied;

  /// No description provided for @supportTicketWaitingReplyLong.
  ///
  /// In tr, this message translates to:
  /// **'Yanıt bekleniyor'**
  String get supportTicketWaitingReplyLong;

  /// No description provided for @supportTicketSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Destek talebiniz gönderildi'**
  String get supportTicketSuccess;

  /// No description provided for @supportTicketError.
  ///
  /// In tr, this message translates to:
  /// **'Hata oluştu'**
  String get supportTicketError;

  /// No description provided for @supportTicketLoadingError.
  ///
  /// In tr, this message translates to:
  /// **'Talepler yüklenemedi'**
  String get supportTicketLoadingError;

  /// No description provided for @supportTicketLoadingRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get supportTicketLoadingRetry;

  /// No description provided for @supportTicketDetailMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesajınız'**
  String get supportTicketDetailMessage;

  /// No description provided for @supportTicketDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Talep Silinsin mi?'**
  String get supportTicketDeleteConfirmTitle;

  /// No description provided for @supportTicketDeleteConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu destek talebi kalıcı olarak silinecek.'**
  String get supportTicketDeleteConfirmMessage;

  /// No description provided for @supportTicketDeleteCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get supportTicketDeleteCancel;

  /// No description provided for @supportTicketDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get supportTicketDeleteConfirm;

  /// No description provided for @supportTicketDeleteSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Talep silindi'**
  String get supportTicketDeleteSuccess;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleme Gerekli'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu sürüm artık desteklenmiyor.\nDevam etmek için lütfen uygulamayı güncelleyin.'**
  String get forceUpdateDescription;

  /// No description provided for @forceUpdateCurrentVersion.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut sürüm'**
  String get forceUpdateCurrentVersion;

  /// No description provided for @forceUpdateMinimumVersion.
  ///
  /// In tr, this message translates to:
  /// **'Gerekli sürüm'**
  String get forceUpdateMinimumVersion;

  /// No description provided for @forceUpdateButton.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get forceUpdateButton;

  /// No description provided for @forceUpdateButtonResume.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get forceUpdateButtonResume;

  /// No description provided for @forceUpdateDownloading.
  ///
  /// In tr, this message translates to:
  /// **'İndiriliyor... %{progress}'**
  String forceUpdateDownloading(int progress);

  /// No description provided for @forceUpdateError.
  ///
  /// In tr, this message translates to:
  /// **'İndirme başarısız: {error}'**
  String forceUpdateError(String error);

  /// No description provided for @forceUpdateInstallError.
  ///
  /// In tr, this message translates to:
  /// **'Kurulum başlatılamadı: {error}'**
  String forceUpdateInstallError(String error);

  /// No description provided for @forceUpdatePermissionTitle.
  ///
  /// In tr, this message translates to:
  /// **'İzin Gerekiyor'**
  String get forceUpdatePermissionTitle;

  /// No description provided for @forceUpdatePermissionContent.
  ///
  /// In tr, this message translates to:
  /// **'APK yükleyebilmek için \"Bilinmeyen uygulamaları yükle\" iznini vermeniz gerekiyor.\n\nAyarlar → Uygulamalar → DeniKey → Bilinmeyen uygulamaları yükle → İzin Ver\n\nİzni verdikten sonra \"Güncelle\" butonuna tekrar basın.'**
  String get forceUpdatePermissionContent;

  /// No description provided for @forceUpdatePermissionOpenSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarları Aç'**
  String get forceUpdatePermissionOpenSettings;

  /// No description provided for @forceUpdatePermissionUnderstand.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get forceUpdatePermissionUnderstand;

  /// No description provided for @navBarSupport.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get navBarSupport;

  /// No description provided for @navBarLibrary.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphane'**
  String get navBarLibrary;

  /// No description provided for @navBarVault.
  ///
  /// In tr, this message translates to:
  /// **'Kasam'**
  String get navBarVault;

  /// No description provided for @navBarGenerator.
  ///
  /// In tr, this message translates to:
  /// **'Üretici'**
  String get navBarGenerator;

  /// No description provided for @navBarSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get navBarSettings;

  /// No description provided for @desktopOnboardingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Masaüstü Kısayolları'**
  String get desktopOnboardingTitle;

  /// No description provided for @desktopOnboardingDescription.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey\'i daha hızlı kullanmak için bu kısayolları deneyin.'**
  String get desktopOnboardingDescription;

  /// No description provided for @desktopOnboardingShortcut1.
  ///
  /// In tr, this message translates to:
  /// **'Kasam / Kütüphane / Ayarlar'**
  String get desktopOnboardingShortcut1;

  /// No description provided for @desktopOnboardingShortcut2.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre ekle'**
  String get desktopOnboardingShortcut2;

  /// No description provided for @desktopOnboardingShortcut3.
  ///
  /// In tr, this message translates to:
  /// **'Arama'**
  String get desktopOnboardingShortcut3;

  /// No description provided for @desktopOnboardingShortcut4.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Üretici'**
  String get desktopOnboardingShortcut4;

  /// No description provided for @desktopOnboardingShortcut5.
  ///
  /// In tr, this message translates to:
  /// **'Sekmeler arası geçiş'**
  String get desktopOnboardingShortcut5;

  /// No description provided for @desktopOnboardingShortcut6.
  ///
  /// In tr, this message translates to:
  /// **'Geri git / kapat'**
  String get desktopOnboardingShortcut6;

  /// No description provided for @desktopOnboardingButton.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get desktopOnboardingButton;

  /// No description provided for @splashSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sıfır Bilgi · Tam Güvenlik'**
  String get splashSubtitle;

  /// No description provided for @settingsAutoLockUnlimited.
  ///
  /// In tr, this message translates to:
  /// **'Süresiz'**
  String get settingsAutoLockUnlimited;

  /// No description provided for @settingsAutoLockMinutesChip.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dk'**
  String settingsAutoLockMinutesChip(int minutes);

  /// No description provided for @settingsClipboardSecondsChip.
  ///
  /// In tr, this message translates to:
  /// **'{seconds} sn'**
  String settingsClipboardSecondsChip(int seconds);

  /// No description provided for @settingsClipboardUnlimited.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız'**
  String get settingsClipboardUnlimited;

  /// No description provided for @settingsDeviceJustNow.
  ///
  /// In tr, this message translates to:
  /// **'Az önce'**
  String get settingsDeviceJustNow;

  /// No description provided for @settingsDeviceMinutesAgo.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dakika önce'**
  String settingsDeviceMinutesAgo(int minutes);

  /// No description provided for @settingsDeviceHoursAgo.
  ///
  /// In tr, this message translates to:
  /// **'{hours} saat önce'**
  String settingsDeviceHoursAgo(int hours);

  /// No description provided for @settingsDeviceDaysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün önce'**
  String settingsDeviceDaysAgo(int days);

  /// No description provided for @onboardingNext.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get onboardingStart;

  /// No description provided for @onboardingClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get onboardingClose;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey\'e Hoş Geldiniz'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreleriniz, kartlarınız ve dijital kimlikleriniz tek bir güvenli yerde — yalnızca sizin elinizde.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingChipZeroKnowledge.
  ///
  /// In tr, this message translates to:
  /// **'Sıfır Bilgi'**
  String get onboardingChipZeroKnowledge;

  /// No description provided for @onboardingChipMultiPlatform.
  ///
  /// In tr, this message translates to:
  /// **'Çok Platform'**
  String get onboardingChipMultiPlatform;

  /// No description provided for @onboardingChipSync.
  ///
  /// In tr, this message translates to:
  /// **'Anlık Senkron'**
  String get onboardingChipSync;

  /// No description provided for @onboardingVaultTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kasanız Her Şeyi Saklar'**
  String get onboardingVaultTitle;

  /// No description provided for @onboardingVaultSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler, kartlar, notlar ve özel alanlar. Tek dokunuşla kopyalayın, gizli alanları isteğe göre maskeleyin.'**
  String get onboardingVaultSubtitle;

  /// No description provided for @onboardingVaultActionCopy.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get onboardingVaultActionCopy;

  /// No description provided for @onboardingVaultActionShow.
  ///
  /// In tr, this message translates to:
  /// **'Göster'**
  String get onboardingVaultActionShow;

  /// No description provided for @onboardingVaultActionEdit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get onboardingVaultActionEdit;

  /// No description provided for @onboardingVaultMockBankCard.
  ///
  /// In tr, this message translates to:
  /// **'Banka Kartı'**
  String get onboardingVaultMockBankCard;

  /// No description provided for @onboardingChipQuickAdd.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Ekle'**
  String get onboardingChipQuickAdd;

  /// No description provided for @onboardingChipFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get onboardingChipFavorites;

  /// No description provided for @onboardingChipHiddenField.
  ///
  /// In tr, this message translates to:
  /// **'Gizli Alan'**
  String get onboardingChipHiddenField;

  /// No description provided for @onboardingChipTrash.
  ///
  /// In tr, this message translates to:
  /// **'Çöp Kutusu'**
  String get onboardingChipTrash;

  /// No description provided for @onboardingLibraryCategorySocialMedia.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal Medya'**
  String get onboardingLibraryCategorySocialMedia;

  /// No description provided for @onboardingLibraryCategoryWork.
  ///
  /// In tr, this message translates to:
  /// **'İş'**
  String get onboardingLibraryCategoryWork;

  /// No description provided for @onboardingChipCustomize.
  ///
  /// In tr, this message translates to:
  /// **'Özelleştir'**
  String get onboardingChipCustomize;

  /// No description provided for @onboardingGeneratorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü Şifreler Üretin'**
  String get onboardingGeneratorTitle;

  /// No description provided for @onboardingGeneratorSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uzunluk, büyük/küçük harf, rakam ve özel karakter seçenekleriyle tek tıkta kırılması zor şifreler oluşturun.'**
  String get onboardingGeneratorSubtitle;

  /// No description provided for @onboardingGeneratorSectionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Üretici'**
  String get onboardingGeneratorSectionLabel;

  /// No description provided for @onboardingGeneratorStrengthLabel.
  ///
  /// In tr, this message translates to:
  /// **'Güç:'**
  String get onboardingGeneratorStrengthLabel;

  /// No description provided for @onboardingGeneratorStrengthVeryStrong.
  ///
  /// In tr, this message translates to:
  /// **'Çok Güçlü'**
  String get onboardingGeneratorStrengthVeryStrong;

  /// No description provided for @onboardingGeneratorLengthOption.
  ///
  /// In tr, this message translates to:
  /// **'Uzunluk: {n}'**
  String onboardingGeneratorLengthOption(int n);

  /// No description provided for @onboardingChipRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get onboardingChipRefresh;

  /// No description provided for @onboardingSecurityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tam Kontrol Sizde'**
  String get onboardingSecurityTitle;

  /// No description provided for @onboardingSecuritySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi, otomatik kilit, cihaz yasaklama ve denetim kaydı ile güvenliğinizi her açıdan yönetin.'**
  String get onboardingSecuritySubtitle;

  /// No description provided for @onboardingSecurityBiometric.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik'**
  String get onboardingSecurityBiometric;

  /// No description provided for @onboardingSecurityBiometricDesc.
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi ile hızlı erişim'**
  String get onboardingSecurityBiometricDesc;

  /// No description provided for @onboardingSecurityAutoLock.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik Kilit'**
  String get onboardingSecurityAutoLock;

  /// No description provided for @onboardingSecurityAutoLockDesc.
  ///
  /// In tr, this message translates to:
  /// **'Süre veya odak kaybıyla kilitle'**
  String get onboardingSecurityAutoLockDesc;

  /// No description provided for @onboardingSecurityDeviceManagement.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz Yönetimi'**
  String get onboardingSecurityDeviceManagement;

  /// No description provided for @onboardingSecurityDeviceManagementDesc.
  ///
  /// In tr, this message translates to:
  /// **'Oturumları görüntüle ve sonlandır'**
  String get onboardingSecurityDeviceManagementDesc;

  /// No description provided for @onboardingSecurityAuditLog.
  ///
  /// In tr, this message translates to:
  /// **'Denetim Kaydı'**
  String get onboardingSecurityAuditLog;

  /// No description provided for @onboardingSecurityAuditLogDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her işlemi takip et'**
  String get onboardingSecurityAuditLogDesc;

  /// No description provided for @onboardingSecurityZeroKnowledgeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sıfır Bilgi Mimarisi'**
  String get onboardingSecurityZeroKnowledgeTitle;

  /// No description provided for @onboardingSecurityZeroKnowledgeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Master şifreniz hiçbir zaman sunucuya gönderilmez.'**
  String get onboardingSecurityZeroKnowledgeDesc;

  /// No description provided for @onboardingReadyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başlamaya Hazır mısınız?'**
  String get onboardingReadyTitle;

  /// No description provided for @onboardingReadySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluşturun ya da giriş yapın. Güvenlik artık karmaşık değil.'**
  String get onboardingReadySubtitle;

  /// No description provided for @onboardingReplayTitle.
  ///
  /// In tr, this message translates to:
  /// **'Her Şeyi Hatırladınız!'**
  String get onboardingReplayTitle;

  /// No description provided for @onboardingReplaySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sorularınız için Ayarlar → Destek Talebi kısmından bize ulaşabilirsiniz.'**
  String get onboardingReplaySubtitle;

  /// No description provided for @onboardingSummaryZeroKnowledge.
  ///
  /// In tr, this message translates to:
  /// **'Sıfır bilgi — veriler yalnızca sizin'**
  String get onboardingSummaryZeroKnowledge;

  /// No description provided for @onboardingSummaryAddPassword.
  ///
  /// In tr, this message translates to:
  /// **'Kasam → şifre ekle ve yönet'**
  String get onboardingSummaryAddPassword;

  /// No description provided for @onboardingSummaryGenerator.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü şifreler üret'**
  String get onboardingSummaryGenerator;

  /// No description provided for @onboardingSummaryBiometric.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik ile hızlı giriş'**
  String get onboardingSummaryBiometric;

  /// No description provided for @vaultItemUntitled.
  ///
  /// In tr, this message translates to:
  /// **'İsimsiz'**
  String get vaultItemUntitled;

  /// No description provided for @vaultItemDetailFallbackTitle.
  ///
  /// In tr, this message translates to:
  /// **'Detay'**
  String get vaultItemDetailFallbackTitle;

  /// No description provided for @categoriesUncategorized.
  ///
  /// In tr, this message translates to:
  /// **'Kategorisizler'**
  String get categoriesUncategorized;

  /// No description provided for @networkError.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya bağlanılamadı'**
  String get networkError;

  /// No description provided for @addItemTypeCreateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Tip Oluştur'**
  String get addItemTypeCreateTitle;

  /// No description provided for @addItemTypeFieldsLabel.
  ///
  /// In tr, this message translates to:
  /// **'Alanlar'**
  String get addItemTypeFieldsLabel;

  /// No description provided for @onboardingCategoriesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategorilerle düzenle'**
  String get onboardingCategoriesTitle;

  /// No description provided for @onboardingCategoriesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifrelerini klasörler halinde grupla. Kategorisizler her zaman oradadır ve silinemez.'**
  String get onboardingCategoriesSubtitle;

  /// No description provided for @onboardingCategoriesDefault.
  ///
  /// In tr, this message translates to:
  /// **'Kategorisizler'**
  String get onboardingCategoriesDefault;

  /// No description provided for @onboardingCategoriesDefaultLock.
  ///
  /// In tr, this message translates to:
  /// **'Silinemez & Düzenlenemez'**
  String get onboardingCategoriesDefaultLock;

  /// No description provided for @onboardingCategoriesChipDefault.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan Klasör'**
  String get onboardingCategoriesChipDefault;

  /// No description provided for @onboardingCategoriesChipCustom.
  ///
  /// In tr, this message translates to:
  /// **'Özel Kategoriler'**
  String get onboardingCategoriesChipCustom;

  /// No description provided for @onboardingCategoriesChipOrganize.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get onboardingCategoriesChipOrganize;

  /// No description provided for @onboardingTypesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şablonlarla hızlan'**
  String get onboardingTypesTitle;

  /// No description provided for @onboardingTypesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sık kullandığın alan gruplarını bir kez tanımla. Her yeni şifrede hazır gelsin.'**
  String get onboardingTypesSubtitle;

  /// No description provided for @onboardingTypesWithout.
  ///
  /// In tr, this message translates to:
  /// **'Tipsiz'**
  String get onboardingTypesWithout;

  /// No description provided for @onboardingTypesWith.
  ///
  /// In tr, this message translates to:
  /// **'Tip seçilince'**
  String get onboardingTypesWith;

  /// No description provided for @onboardingTypesChipTemplate.
  ///
  /// In tr, this message translates to:
  /// **'Şablon'**
  String get onboardingTypesChipTemplate;

  /// No description provided for @onboardingTypesChipSpeed.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Kayıt'**
  String get onboardingTypesChipSpeed;

  /// No description provided for @onboardingTypesChipCustomize.
  ///
  /// In tr, this message translates to:
  /// **'Özelleştir'**
  String get onboardingTypesChipCustomize;

  /// No description provided for @notifAutoLockTitle.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey Kilitlendi'**
  String get notifAutoLockTitle;

  /// No description provided for @notifAutoLockBody.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik kilit devreye girdi. Devam etmek için master şifrenizi girin.'**
  String get notifAutoLockBody;

  /// No description provided for @notifNewDeviceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Cihaz Girişi'**
  String get notifNewDeviceTitle;

  /// No description provided for @notifNewDeviceBody.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınıza yeni bir cihazdan giriş denemesi var. Siz değilseniz şifrenizi hemen değiştirin.'**
  String get notifNewDeviceBody;

  /// No description provided for @notifChannelName.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey Bildirimleri'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik hatırlatıcıları ve önemli bildirimler'**
  String get notifChannelDesc;

  /// No description provided for @biometricFaceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yüz Tanıma ile Aç'**
  String get biometricFaceLabel;

  /// No description provided for @biometricFingerprintLabel.
  ///
  /// In tr, this message translates to:
  /// **'Parmak İzi ile Aç'**
  String get biometricFingerprintLabel;

  /// No description provided for @biometricPinLabel.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz Kilidi ile Aç'**
  String get biometricPinLabel;

  /// No description provided for @biometricReason.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey\'e erişmek için kimliğinizi doğrulayın'**
  String get biometricReason;

  /// No description provided for @shortcutSupport.
  ///
  /// In tr, this message translates to:
  /// **'Destek Talebi'**
  String get shortcutSupport;

  /// No description provided for @shortcutVault.
  ///
  /// In tr, this message translates to:
  /// **'Kasama git'**
  String get shortcutVault;

  /// No description provided for @shortcutLibrary.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphaneye git'**
  String get shortcutLibrary;

  /// No description provided for @shortcutSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlara git'**
  String get shortcutSettings;

  /// No description provided for @shortcutNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre ekle'**
  String get shortcutNewPassword;

  /// No description provided for @shortcutSearch.
  ///
  /// In tr, this message translates to:
  /// **'Arama'**
  String get shortcutSearch;

  /// No description provided for @shortcutGenerator.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Üretici'**
  String get shortcutGenerator;

  /// No description provided for @shortcutNewPasswordVault.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre (kasam ekranı)'**
  String get shortcutNewPasswordVault;

  /// No description provided for @shortcutTabSwitch.
  ///
  /// In tr, this message translates to:
  /// **'Sekmeler arası geçiş'**
  String get shortcutTabSwitch;

  /// No description provided for @shortcutBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri git'**
  String get shortcutBack;

  /// No description provided for @authLoadingLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapılıyor...'**
  String get authLoadingLogin;

  /// No description provided for @authLoadingRegister.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluşturuluyor...'**
  String get authLoadingRegister;

  /// No description provided for @authErrorLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız.'**
  String get authErrorLogin;

  /// No description provided for @authErrorRegister.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarısız.'**
  String get authErrorRegister;

  /// No description provided for @vaultLoadingVault.
  ///
  /// In tr, this message translates to:
  /// **'Kasa yükleniyor...'**
  String get vaultLoadingVault;

  /// No description provided for @vaultLoadingSaving.
  ///
  /// In tr, this message translates to:
  /// **'Kaydediliyor...'**
  String get vaultLoadingSaving;

  /// No description provided for @vaultLoadingUpdating.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleniyor...'**
  String get vaultLoadingUpdating;

  /// No description provided for @vaultLoadingDeleting.
  ///
  /// In tr, this message translates to:
  /// **'Siliniyor...'**
  String get vaultLoadingDeleting;

  /// No description provided for @vaultLoadingMoving.
  ///
  /// In tr, this message translates to:
  /// **'Taşınıyor...'**
  String get vaultLoadingMoving;

  /// No description provided for @vaultLoadingDeletingCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıt siliniyor...'**
  String vaultLoadingDeletingCount(int count);

  /// No description provided for @vaultErrorTimeout.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu yanıt vermedi. Lütfen tekrar deneyin.'**
  String get vaultErrorTimeout;

  /// No description provided for @vaultErrorLoad.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemedi.'**
  String get vaultErrorLoad;

  /// No description provided for @vaultErrorOffline.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok.'**
  String get vaultErrorOffline;

  /// No description provided for @vaultSampleTitle.
  ///
  /// In tr, this message translates to:
  /// **'DeniKey Örnek Kayıt'**
  String get vaultSampleTitle;

  /// No description provided for @vaultSampleNotes.
  ///
  /// In tr, this message translates to:
  /// **'Bu otomatik oluşturulan bir örnek kayıttır. Kendi hesap bilgilerinizi ekledikten sonra silebilirsiniz.'**
  String get vaultSampleNotes;

  /// No description provided for @errorCouldNotLoad.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemedi'**
  String get errorCouldNotLoad;

  /// No description provided for @errorCouldNotCreate.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturulamadı'**
  String get errorCouldNotCreate;

  /// No description provided for @errorCouldNotUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Güncellenemedi'**
  String get errorCouldNotUpdate;

  /// No description provided for @errorCouldNotDelete.
  ///
  /// In tr, this message translates to:
  /// **'Silinemedi'**
  String get errorCouldNotDelete;

  /// No description provided for @offlineTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ne yazık ki internetsiz DeniKey\'e erişemezsiniz'**
  String get offlineTitle;

  /// No description provided for @offlineMessage.
  ///
  /// In tr, this message translates to:
  /// **'Merak etmeyin, bu bir sorun değildir. Hesabınız ve içerikleriniz güvende. Tekrar internet bağlantısı sağladığınızda tam erişim geri gelecektir.'**
  String get offlineMessage;

  /// No description provided for @addItemFieldNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alanı doldurmak zorunludur'**
  String get addItemFieldNameRequired;

  /// No description provided for @totpSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Authenticator Koruması'**
  String get totpSettingsTitle;

  /// No description provided for @totpSettingsActiveDesc.
  ///
  /// In tr, this message translates to:
  /// **'Girişlerde authenticator uygulamanızdan kod istenir'**
  String get totpSettingsActiveDesc;

  /// No description provided for @totpSettingsInactiveDesc.
  ///
  /// In tr, this message translates to:
  /// **'Girişlerde ek doğrulama kodu istenmez'**
  String get totpSettingsInactiveDesc;

  /// No description provided for @totpSetupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Authenticator Koruması Kurulumu'**
  String get totpSetupTitle;

  /// No description provided for @totpSetupStep1.
  ///
  /// In tr, this message translates to:
  /// **'1. QR Kodu Tarayın'**
  String get totpSetupStep1;

  /// No description provided for @totpSetupStep1Desc.
  ///
  /// In tr, this message translates to:
  /// **'Google Authenticator, Authy veya benzer bir uygulama ile aşağıdaki QR kodu tarayın.'**
  String get totpSetupStep1Desc;

  /// No description provided for @totpSetupStep2.
  ///
  /// In tr, this message translates to:
  /// **'2. Doğrulama Kodunu Girin'**
  String get totpSetupStep2;

  /// No description provided for @totpSetupStep2Desc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamanızın gösterdiği 6 haneli kodu girerek kurulumu tamamlayın.'**
  String get totpSetupStep2Desc;

  /// No description provided for @totpSetupManualKey.
  ///
  /// In tr, this message translates to:
  /// **'Elle Giriş için Anahtar'**
  String get totpSetupManualKey;

  /// No description provided for @totpSetupActivate.
  ///
  /// In tr, this message translates to:
  /// **'Etkinleştir'**
  String get totpSetupActivate;

  /// No description provided for @totpSetupLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Kurulum bilgileri yüklenemedi'**
  String get totpSetupLoadError;

  /// No description provided for @totpSecretCopied.
  ///
  /// In tr, this message translates to:
  /// **'Anahtar kopyalandı'**
  String get totpSecretCopied;

  /// No description provided for @totpCodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'6 haneli kod'**
  String get totpCodeLabel;

  /// No description provided for @totpInvalidCode.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz kod, tekrar deneyin'**
  String get totpInvalidCode;

  /// No description provided for @totpEnabledSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Authenticator Koruması etkinleştirildi'**
  String get totpEnabledSuccess;

  /// No description provided for @totpVerifyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Authenticator Koruması'**
  String get totpVerifyTitle;

  /// No description provided for @totpVerifyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Authenticator uygulamanızın gösterdiği 6 haneli kodu girin.'**
  String get totpVerifyDesc;

  /// No description provided for @totpVerifyButton.
  ///
  /// In tr, this message translates to:
  /// **'Doğrula'**
  String get totpVerifyButton;

  /// No description provided for @totpDisableTitle.
  ///
  /// In tr, this message translates to:
  /// **'Korumayı Devre Dışı Bırak'**
  String get totpDisableTitle;

  /// No description provided for @totpDisableDesc.
  ///
  /// In tr, this message translates to:
  /// **'Devre dışı bırakmak için master password\'ünüzü ve authenticator kodunuzu girin.'**
  String get totpDisableDesc;

  /// No description provided for @totpDisableMasterPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Master Password'**
  String get totpDisableMasterPasswordLabel;

  /// No description provided for @totpDisableMasterPasswordError.
  ///
  /// In tr, this message translates to:
  /// **'Master password hatalı'**
  String get totpDisableMasterPasswordError;

  /// No description provided for @totpDisableCodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Authenticator Kodu'**
  String get totpDisableCodeLabel;

  /// No description provided for @totpDisableCodeError.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz authenticator kodu'**
  String get totpDisableCodeError;

  /// No description provided for @totpDisabledSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Authenticator Koruması devre dışı bırakıldı'**
  String get totpDisabledSuccess;

  /// No description provided for @totpDisableConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Devre Dışı Bırak'**
  String get totpDisableConfirm;

  /// No description provided for @totpTrustDurationLabel.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama sıklığı'**
  String get totpTrustDurationLabel;

  /// No description provided for @totpTrustAlways.
  ///
  /// In tr, this message translates to:
  /// **'Her seferinde'**
  String get totpTrustAlways;

  /// No description provided for @totpTrust12h.
  ///
  /// In tr, this message translates to:
  /// **'12 saat'**
  String get totpTrust12h;

  /// No description provided for @totpTrust1d.
  ///
  /// In tr, this message translates to:
  /// **'1 gün'**
  String get totpTrust1d;

  /// No description provided for @totpTrust7d.
  ///
  /// In tr, this message translates to:
  /// **'7 gün'**
  String get totpTrust7d;

  /// No description provided for @totpTrust30d.
  ///
  /// In tr, this message translates to:
  /// **'30 gün'**
  String get totpTrust30d;

  /// No description provided for @totpTrust60d.
  ///
  /// In tr, this message translates to:
  /// **'60 gün'**
  String get totpTrust60d;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
