// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTagline => 'Your passwords are safe';

  @override
  String get loginUsernameLabel => 'Username or Email';

  @override
  String get loginUsernameError => 'Username or email is required';

  @override
  String get loginUsernameMinError => 'At least 3 characters';

  @override
  String get loginPasswordLabel => 'Master Password';

  @override
  String get loginPasswordError => 'Password is required';

  @override
  String get loginPasswordMinError => 'At least 6 characters';

  @override
  String get loginSubmitButton => 'Sign In';

  @override
  String get loginNoAccountQuestion => 'Don\'t have an account?';

  @override
  String get loginRegisterButton => 'Sign Up';

  @override
  String get loginForgotButton => 'Forgot Password';

  @override
  String get loginError => 'Error';

  @override
  String get registerAppBarTitle => 'Sign Up';

  @override
  String get registerHeading => 'Create Account';

  @override
  String get registerSubheading => 'Your identity stays private.';

  @override
  String get registerUsernameLabel => 'Username';

  @override
  String get registerUsernameError => 'Username is required';

  @override
  String get registerUsernameMinError => 'At least 3 characters';

  @override
  String get registerUsernameMaxError => 'At most 50 characters';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailError => 'Email is required';

  @override
  String get registerEmailFormatError => 'Enter a valid email';

  @override
  String get registerPasswordLabel => 'Master Password';

  @override
  String get registerPasswordError => 'Password is required';

  @override
  String get registerPasswordMinError => 'At least 6 characters';

  @override
  String get registerConfirmLabel => 'Confirm Password';

  @override
  String get registerConfirmError => 'Passwords do not match';

  @override
  String get registerBirthdateLabel => 'Date of Birth';

  @override
  String get registerBirthdateHelper => 'Select Your Date of Birth';

  @override
  String get registerBirthdateSelect => 'Select';

  @override
  String get registerBirthdateMissing => 'Please select your date of birth';

  @override
  String get registerAgeRestriction =>
      'You must be at least 13 years old to use DeniKey';

  @override
  String get registerSubmitButton => 'Sign Up';

  @override
  String get registerError => 'Error';

  @override
  String get verifyEmailTitle => 'Email Verification';

  @override
  String get verifyDeviceTitle => 'Device Verification';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Enter the 6-digit code\nsent to $email';
  }

  @override
  String verifyDeviceSubtitle(String email) {
    return 'This is your first sign-in from this device.\nEnter the 6-digit code sent to $email.';
  }

  @override
  String get verifySpamWarning => 'Check your Spam/Junk folder';

  @override
  String get verifyCodeError => 'Please enter the 6-digit code';

  @override
  String get verifySubmitButton => 'Verify';

  @override
  String get verifyResendButton => 'Resend code';

  @override
  String get verifySendSuccess => 'Code resent';

  @override
  String get verifySendError => 'Failed to send code';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordHeading => 'Password Reset';

  @override
  String get forgotPasswordDescription =>
      'A verification code will be sent to your registered email.';

  @override
  String get forgotPasswordEmailLabel => 'Email';

  @override
  String get forgotPasswordEmailError => 'Email is required';

  @override
  String get forgotPasswordEmailFormatError => 'Enter a valid email';

  @override
  String get forgotPasswordSubmitButton => 'Send Code';

  @override
  String get forgotPasswordError =>
      'Failed to send verification code, please try again';

  @override
  String get forgotPasswordApiError => 'An error occurred';

  @override
  String get resetPasswordTitle => 'Set New Password';

  @override
  String get resetPasswordHeading => 'Reset Your Password';

  @override
  String resetPasswordDescription(String email) {
    return 'Enter the code sent to $email and your new password.';
  }

  @override
  String get resetPasswordCodeLabel => 'Verification Code';

  @override
  String get resetPasswordCodeError => 'Code is required';

  @override
  String get resetPasswordCodeMinError => 'Enter the 6-digit code';

  @override
  String get resetPasswordNewLabel => 'New Master Password';

  @override
  String get resetPasswordNewError => 'Password is required';

  @override
  String get resetPasswordNewMinError => 'At least 8 characters';

  @override
  String get resetPasswordConfirmLabel => 'Confirm Password';

  @override
  String get resetPasswordConfirmError => 'Password confirmation is required';

  @override
  String get resetPasswordConfirmMismatch => 'Passwords do not match';

  @override
  String get resetPasswordSubmitButton => 'Reset Password';

  @override
  String get resetPasswordSuccess =>
      'Your password has been reset successfully';

  @override
  String get resetPasswordApiError => 'An error occurred';

  @override
  String get changeEmailTitle => 'Change Email';

  @override
  String get changeEmailHeading => 'New Email Address';

  @override
  String get changeEmailDescription =>
      'A verification code will be sent to your new email address.';

  @override
  String get changeEmailLabel => 'New Email';

  @override
  String get changeEmailError => 'Email is required';

  @override
  String get changeEmailFormatError => 'Enter a valid email';

  @override
  String get changeEmailSubmitButton => 'Send Code';

  @override
  String get changeEmailApiError => 'An error occurred';

  @override
  String get confirmEmailChangeTitle => 'Email Verification';

  @override
  String get confirmEmailChangeHeading => 'Verify Code';

  @override
  String confirmEmailChangeDescription(String newEmail) {
    return 'Enter the 6-digit code sent to $newEmail.';
  }

  @override
  String get confirmEmailChangeCodeLabel => 'Verification Code';

  @override
  String get confirmEmailChangeCodeError => 'Code is required';

  @override
  String get confirmEmailChangeCodeMinError => 'Enter the 6-digit code';

  @override
  String get confirmEmailChangeSubmitButton => 'Confirm';

  @override
  String get confirmEmailChangeSuccess =>
      'Your email address has been updated successfully';

  @override
  String get confirmEmailChangeApiError => 'An error occurred';

  @override
  String get masterLockTitle => 'DeniKey Locked';

  @override
  String get masterLockPassword => 'Enter your master password to continue';

  @override
  String get masterLockBiometricExpired =>
      'Your 7-day biometric period has expired.\nPlease enter your master password for security.';

  @override
  String get masterLockPasswordLabel => 'Master Password';

  @override
  String get masterLockPasswordError => 'Password is required';

  @override
  String get masterLockWrongPassword => 'Wrong master password';

  @override
  String get masterLockAuthFailed => 'Authentication failed';

  @override
  String get masterLockBiometricNeeded =>
      'Please enter your master password once';

  @override
  String get masterLockButton => 'Unlock';

  @override
  String masterLockBiometricDaysRemaining(int days) {
    return 'Password required in $days days';
  }

  @override
  String get masterLockBiometricTomorrow => 'Password required tomorrow';

  @override
  String get masterLockDifferentAccount => 'Sign in with a different account';

  @override
  String get lockTitle => 'DeniKey Locked';

  @override
  String get lockDescription => 'Verify your identity to continue';

  @override
  String get lockBiometricButton => 'Unlock with Biometrics';

  @override
  String get lockLogoutButton => 'Sign Out';

  @override
  String get lockAuthFailed => 'Authentication failed';

  @override
  String get deviceBannedTitle => 'Device Banned';

  @override
  String get deviceBannedDescription =>
      'This device cannot be used for this account.\nYour access has been restricted by the account owner.';

  @override
  String get deviceBannedBackButton => 'Go Back';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSection => 'ACCOUNT';

  @override
  String get settingsUsernameChange => 'Change Username';

  @override
  String get settingsEmailChange => 'Change Email';

  @override
  String get settingsMyDevices => 'My Devices';

  @override
  String get settingsAppSection => 'APP';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsPasswordGenerator => 'Password Generator';

  @override
  String get settingsAuditLog => 'Activity History';

  @override
  String get settingsSupportTicket => 'Support Ticket';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsBiometricLock => 'Biometric Lock';

  @override
  String settingsBiometricActive(int days) {
    return 'Active  ·  Password required in $days days';
  }

  @override
  String get settingsBiometricActiveTomorrow =>
      'Active  ·  Password required tomorrow';

  @override
  String get settingsBiometricExpired =>
      'Master password required — will renew on unlock';

  @override
  String get settingsBiometricDescription =>
      'Quick access with fingerprint or face recognition.\nFor your security, your master password will be required every 7 days.';

  @override
  String get settingsAutoLock => 'Auto Lock';

  @override
  String settingsAutoLockEnabled(int minutes) {
    return 'Lock after $minutes min';
  }

  @override
  String get settingsAutoLockFocusLoss => 'Unlimited — lock on focus loss';

  @override
  String get settingsAutoLockDisabled => 'Require master password on exit';

  @override
  String get settingsClipboardTimeout => 'Clipboard Clear';

  @override
  String settingsClipboardTimeoutActive(int timeout) {
    return 'Copied password will be cleared after $timeout sec';
  }

  @override
  String get settingsClipboardTimeoutDisabled =>
      'Unlimited — clipboard will not be cleared automatically';

  @override
  String get settingsKeyboardShortcuts => 'Keyboard Shortcuts';

  @override
  String get settingsKeyboardHint => 'Ctrl+1/2/3, +, ←→, Esc etc.';

  @override
  String get settingsDarkMode => 'Dark Theme';

  @override
  String get settingsDarkModeSystem => 'Follow system';

  @override
  String get settingsDarkModeEnabled => 'On';

  @override
  String get settingsDarkModeDisabled => 'Off';

  @override
  String get settingsHowToUse => 'HOW TO USE';

  @override
  String get settingsDiscoverApp => 'Discover the App';

  @override
  String get settingsDiscoverAppDescription => 'Overview of all features';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsHelpAddPassword => 'Adding a Password';

  @override
  String get settingsHelpAddPasswordContent =>
      'Go to the \"My Vault\" tab from the bottom menu. Tap the \"+ New Password\" button at the bottom right. Enter the site name, username and password; save.';

  @override
  String get settingsHelpPasswordGenerator => 'Password Generator';

  @override
  String get settingsHelpPasswordGeneratorContent =>
      'From the App → Password Generator screen, you can generate strong passwords with options for length, uppercase/lowercase, numbers and special characters.';

  @override
  String get settingsHelpCategories => 'Categories & Types';

  @override
  String get settingsHelpCategoriesContent =>
      'In the \"Library\" tab you can organize your passwords into categories and create new item types.';

  @override
  String get settingsHelpTrash => 'Trash';

  @override
  String get settingsHelpTrashContent =>
      'Deleted passwords are kept in the Trash for 7 days. You can access it from the trash icon in the top right corner of the Vault screen.';

  @override
  String get settingsHelpZeroKnowledge => 'Zero-Knowledge Security';

  @override
  String get settingsHelpZeroKnowledgeContent =>
      'In DeniKey, your master password is never sent to the server and never stored anywhere. Your passwords are encrypted on your device using a key derived by the Argon2id algorithm in AES-256-GCM format; this key exists only on your device. Only encrypted data is sent to the server. If you forget your master password, there is no way to recover your data — this is the inevitable consequence of true zero-knowledge security.';

  @override
  String get settingsLogout => 'Sign Out';

  @override
  String get settingsDeleteAccount => 'Permanently Delete Account';

  @override
  String get settingsDeleteAccountWarning =>
      'All data will be deleted, this cannot be undone';

  @override
  String settingsVersion(String version) {
    return 'DeniKey v$version';
  }

  @override
  String get settingsDevicesTitle => 'My Devices';

  @override
  String get settingsDevicesEmpty => 'No registered devices';

  @override
  String get settingsDevicesError => 'Failed to load devices';

  @override
  String get settingsDeviceRefresh => 'Refresh';

  @override
  String get settingsDeviceStatusActive => 'Active';

  @override
  String get settingsDeviceStatusPassive => 'Passive';

  @override
  String get settingsDeviceStatusBanned => 'Banned';

  @override
  String get settingsDeviceRevoke => 'Revoke Session';

  @override
  String get settingsDeviceRevokeSuccess => 'Session revoked';

  @override
  String get settingsDeviceBan => 'Ban Device';

  @override
  String get settingsDeviceBanSuccess => 'Device banned';

  @override
  String get settingsDeviceUnban => 'Unban Device';

  @override
  String get settingsDeviceUnbanSuccess => 'Device ban lifted';

  @override
  String get settingsDeviceActionFailed => 'Action failed';

  @override
  String get settingsUsernameChangeTitle => 'Change Username';

  @override
  String get settingsUsernameChangeHint => 'New username';

  @override
  String get settingsUsernameChangeError => 'Cannot be empty';

  @override
  String get settingsUsernameChangeMinError => 'At least 3 characters';

  @override
  String get settingsUsernameChangePatternError =>
      'Only letters, numbers and _ allowed';

  @override
  String get settingsUsernameChangeSaved => 'Username updated';

  @override
  String get settingsUsernameChangeFailed => 'Failed to update';

  @override
  String get settingsDeleteAccountStep1 => 'Delete Account — Step 1/4';

  @override
  String get settingsDeleteAccountWarningContent =>
      'This action cannot be undone. All your data will be permanently deleted.';

  @override
  String get settingsDeleteAccountUsernameHint => 'Enter your username';

  @override
  String get settingsDeleteAccountStep2 => 'Delete Account — Step 2/4';

  @override
  String get settingsDeleteAccountPasswordHint => 'Enter your master password';

  @override
  String get settingsDeleteAccountStep3 => 'Delete Account — Step 3/4';

  @override
  String get settingsDeleteAccountConfirm =>
      'Are you sure you want to delete your account?';

  @override
  String settingsDeleteAccountCountdownWait(int seconds) {
    return 'You must wait $seconds seconds...';
  }

  @override
  String get settingsDeleteAccountCountdownReady => 'You may continue.';

  @override
  String get settingsDeleteAccountYesConfirm => 'Yes, Continue';

  @override
  String get settingsDeleteAccountStep4 => 'Delete Account — Step 4/4';

  @override
  String get settingsDeleteAccountFinalMessage =>
      'Final step: enter your password one more time.';

  @override
  String get settingsDeleteAccountPasswordConfirmHint =>
      'Re-enter your master password';

  @override
  String get settingsDeleteAccountFinalButton => 'Permanently Delete Account';

  @override
  String get settingsDeleteAccountFailed => 'Failed to delete account';

  @override
  String get settingsDeleteAccountCancel => 'Cancel';

  @override
  String get settingsDeleteAccountContinue => 'Continue';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyLastUpdate => 'Last updated: April 2026';

  @override
  String get privacyPolicySection1Title => '1. Introduction';

  @override
  String get privacyPolicySection1Body =>
      'DeniKey (\"app\", \"we\", \"service\") is a password manager that operates with zero-knowledge architecture. This Privacy Policy explains what data is collected when using the app, how it is processed, and your rights.';

  @override
  String get privacyPolicySection2Title => '2. Data Collected';

  @override
  String get privacyPolicySection2Body =>
      '• Email address and username — for account creation and authentication.\n• Derived verification value (hash) of your master password — plaintext is never stored.\n• Encrypted vault data — sent to the server after being encrypted with AES-256-GCM on your device; only you can read its contents.\n• Session tokens and device ID — for multi-device management.\n• Audit logs — for monitoring your account security, accessible only to you.';

  @override
  String get privacyPolicySection3Title => '3. Zero-Knowledge Architecture';

  @override
  String get privacyPolicySection3Body =>
      'DeniKey never sends your master password to the server and never stores it anywhere. Your vault data is encrypted on your device using a key derived by the Argon2id algorithm in AES-256-GCM format. Our servers only store encrypted data; we have no technical ability to access your content.\n\nIf you forget your master password, there is no way to recover your data — this is the inevitable consequence of true zero-knowledge security.';

  @override
  String get privacyPolicySection4Title => '4. Data Usage';

  @override
  String get privacyPolicySection4Body =>
      'The data we collect is used only for:\n• Creating and managing your account\n• Authentication and session security\n• Email verification and password reset notifications\n• Responding to your support requests\n\nYour data is not shared with third parties or used for advertising.';

  @override
  String get privacyPolicySection5Title => '5. Data Security';

  @override
  String get privacyPolicySection5Body =>
      '• All communications are encrypted via HTTPS/TLS.\n• Vault data is stored encrypted on the server.\n• Passwords are derived with Argon2id (memory: 64 MB, iterations: 3, parallelism: 2); resistant to brute-force attacks.\n• JWT tokens are short-lived and managed with a refresh mechanism.';

  @override
  String get privacyPolicySection6Title => '6. Account Deletion';

  @override
  String get privacyPolicySection6Body =>
      'You can delete your account at any time from Settings → Permanently Delete Account. Deletion requires 4-step confirmation and all your data (vault items, categories, audit logs) will be permanently removed. This action cannot be undone.';

  @override
  String get privacyPolicySection7Title => '7. Children\'s Privacy';

  @override
  String get privacyPolicySection7Body =>
      'DeniKey is not intended for children under 13. We do not knowingly collect data from this age group.';

  @override
  String get privacyPolicySection8Title => '8. Policy Changes';

  @override
  String get privacyPolicySection8Body =>
      'We may update this policy. Important changes will be notified to your registered email address. The current policy is always accessible from within the app.';

  @override
  String get privacyPolicySection9Title => '9. Contact';

  @override
  String get privacyPolicySection9Body =>
      'For privacy-related questions, you can create a support ticket or use the Support Ticket screen within the app.';

  @override
  String get vaultTitle => 'DeniKey';

  @override
  String get vaultSearchTooltip => 'Search';

  @override
  String get vaultTrashTooltip => 'Trash';

  @override
  String get vaultRefreshTooltip => 'Refresh';

  @override
  String get vaultOfflineWarning =>
      'You cannot access your vault without an internet connection';

  @override
  String get vaultOfflineWarningDesktop => 'Offline mode — Read only';

  @override
  String get vaultBulkDeleteTitle => 'Bulk Delete';

  @override
  String vaultBulkDeleteMessage(int count) {
    return '$count records will be moved to trash. Continue?';
  }

  @override
  String get vaultBulkSelectAll => 'All';

  @override
  String vaultBulkMoveTitle(int count) {
    return 'Move $count records';
  }

  @override
  String get vaultBulkMoveUncategorized => 'Uncategorized';

  @override
  String get vaultCategoryEmpty => 'No passwords in this category';

  @override
  String get vaultEmpty => 'No passwords yet';

  @override
  String get vaultEmptyHint => 'Add a new password with +';

  @override
  String get vaultFavoritesSection => 'Favorites';

  @override
  String get vaultOthersSection => 'Others';

  @override
  String get vaultFavoritesAdd => 'Add to favorites';

  @override
  String get vaultFavoritesRemove => 'Remove from favorites';

  @override
  String get vaultAddButton => 'New Password';

  @override
  String get vaultBulkDeleteButton => 'Delete';

  @override
  String get vaultBulkMoveButton => 'Move';

  @override
  String get vaultBulkFavoritesButton => 'Add to favorites';

  @override
  String get vaultBulkFavoritesRemoveButton => 'Remove from favorites';

  @override
  String get vaultLoading => 'Loading...';

  @override
  String get vaultError => 'Error';

  @override
  String get vaultRetry => 'Retry';

  @override
  String vaultBulkSelectionCount(int count) {
    return '$count selected';
  }

  @override
  String get addItemStep0 => 'Select Category';

  @override
  String get addItemStep1 => 'Select Type';

  @override
  String get addItemStep2 => 'Enter Details';

  @override
  String get addItemUncategorized => 'Uncategorized';

  @override
  String get addItemUncategorizedSubtitle => 'Store under uncategorized';

  @override
  String get addItemCreateCategory => 'Create Category';

  @override
  String get addItemCreateCategorySubtitle => 'Add new category';

  @override
  String get addItemSelectType => 'Select Type';

  @override
  String get addItemNewCategory => 'New Category';

  @override
  String get addItemNewCategoryName => 'Category Name';

  @override
  String get addItemColorSelect => 'Select Color';

  @override
  String get addItemNewItemType => 'New Type';

  @override
  String get addItemTypeNameLabel => 'Type Name';

  @override
  String get addItemTypeSelectIcon => 'Select Icon';

  @override
  String get addItemTypeSelectColor => 'Select Color';

  @override
  String get addItemTypeFixedFields => 'Fixed Fields';

  @override
  String get addItemTypeFieldAdd => 'Add Field';

  @override
  String get addItemTypeFieldDefault =>
      'No fields added — a \"Password\" field will be created by default.';

  @override
  String get addItemTypeFieldName => 'Field Name';

  @override
  String get addItemTypeFieldType => 'Type';

  @override
  String get addItemTypeFieldTypeText => 'Text';

  @override
  String get addItemTypeFieldTypeSecret => 'Secret';

  @override
  String get addItemTypeFieldTypeNumber => 'Number';

  @override
  String get addItemTypeFieldTypeDate => 'Date';

  @override
  String get addItemTitleLabel => 'Title *';

  @override
  String get addItemTitleHint => 'e.g. Instagram, Gmail, Netflix';

  @override
  String get addItemUrlLabel => 'Website (URL)';

  @override
  String get addItemUrlHint => 'e.g. https://instagram.com';

  @override
  String get addItemExtraFieldKeyLabel => 'Field Name';

  @override
  String get addItemExtraFieldValueLabel => 'Value';

  @override
  String get addItemAddFieldButton => 'Add Field';

  @override
  String get addItemSaveButton => 'Save';

  @override
  String get addItemPasswordStrengthVeryWeak => 'Very Weak';

  @override
  String get addItemPasswordStrengthWeak => 'Weak';

  @override
  String get addItemPasswordStrengthMedium => 'Medium';

  @override
  String get addItemPasswordStrengthStrong => 'Strong';

  @override
  String get addItemPasswordStrengthVeryStrong => 'Very Strong';

  @override
  String get addItemErrorSave => 'An error occurred while adding the record.';

  @override
  String get addItemCategoryCreate => 'Create';

  @override
  String get addItemTypeCreate => 'Add';

  @override
  String get addItemCancel => 'Cancel';

  @override
  String get detailPasswordLabel => 'Password';

  @override
  String get detailExtraInfoSection => 'Additional Info';

  @override
  String get detailCategoryLabel => 'Folder';

  @override
  String get detailCategoryUncategorized => 'Uncategorized';

  @override
  String get detailCategoryMove => 'Move to Folder';

  @override
  String get detailExternalLinkTitle => 'External Link';

  @override
  String detailExternalLinkMessage(String url) {
    return 'DeniKey is about to open this link:\n\n$url';
  }

  @override
  String get detailExternalLinkDeny => 'Deny';

  @override
  String get detailExternalLinkOnce => 'This Time Only';

  @override
  String get detailExternalLinkNoAsk => 'Don\'t Ask Again';

  @override
  String get detailDeleteTitle => 'Delete';

  @override
  String get detailDeleteMessage =>
      'Are you sure you want to delete this password?';

  @override
  String get detailDeleteButton => 'Delete';

  @override
  String get detailFavoritesAdd => 'Add to favorites';

  @override
  String get detailFavoritesRemove => 'Remove from favorites';

  @override
  String get detailPasswordHistory => 'Password History';

  @override
  String get detailEditButton => 'Edit';

  @override
  String get detailCancelEdit => 'Cancel';

  @override
  String get detailEditTitle => 'Title';

  @override
  String get detailEditUrl => 'Website (URL)';

  @override
  String get detailEditPassword => 'Password';

  @override
  String get detailEditCustomFieldKeyLabel => 'Title';

  @override
  String get detailEditCustomFieldValueLabel => 'Content';

  @override
  String get detailEditSaveButton => 'Save';

  @override
  String get detailEditErrorBlankTitle => 'Title cannot be empty';

  @override
  String get detailEditErrorGeneral => 'Failed to update, please try again';

  @override
  String detailInfoTilePasswordCopied(String label, int timeout) {
    return '$label copied, will be cleared in $timeout seconds';
  }

  @override
  String detailInfoTileCopied(String label) {
    return '$label copied';
  }

  @override
  String get detailLinkOpen => 'Open Link';

  @override
  String detailLoadError(String error) {
    return 'Failed to load info: $error';
  }

  @override
  String get detailRetry => 'Retry';

  @override
  String get searchHint => 'Search...';

  @override
  String get searchEmpty => 'Start typing to search';

  @override
  String searchNoResults(String query) {
    return 'No results found for \"$query\"';
  }

  @override
  String passwordHistoryTitle(String itemTitle) {
    return '$itemTitle — History';
  }

  @override
  String get passwordHistoryClear => 'Clear History';

  @override
  String get passwordHistoryClearTitle => 'Clear History';

  @override
  String get passwordHistoryClearMessage => 'Delete all password history?';

  @override
  String get passwordHistoryEmpty => 'No password history';

  @override
  String get passwordHistoryEmptyHint =>
      'Previous versions will appear here when the password is updated';

  @override
  String get passwordHistoryCopy =>
      'Password copied, will be cleared in 30 sec';

  @override
  String get passwordHistoryLoading => 'Loading...';

  @override
  String get passwordHistoryError => 'Failed to load';

  @override
  String get passwordHistoryRetry => 'Retry';

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryCategoriesTab => 'Categories';

  @override
  String get libraryTypesTab => 'Types';

  @override
  String get libraryAddCategory => 'New Category';

  @override
  String get libraryCategoryName => 'Category Name';

  @override
  String get libraryCategoryColorSelect => 'Select Color';

  @override
  String get libraryDeleteCategoryTitle => 'Delete';

  @override
  String get libraryDeleteCategoryMessage =>
      'Are you sure you want to delete this category?';

  @override
  String get libraryDeleteSystemCategory =>
      'System categories cannot be deleted.';

  @override
  String get libraryDeleteSystemType => 'System types cannot be deleted.';

  @override
  String get libraryEmptyCategories => 'No categories yet';

  @override
  String get libraryEmptyTypes => 'No types yet';

  @override
  String get librarySystemLabel => 'System';

  @override
  String get librarySystemLock => 'Locked';

  @override
  String libraryTypeFieldCount(int count) {
    return '$count fields';
  }

  @override
  String get libraryCancel => 'Cancel';

  @override
  String get libraryAddButton => 'Add';

  @override
  String get categoryDetailEmpty => 'No items in this category yet';

  @override
  String get categoryDetailItem => 'Unnamed';

  @override
  String get passwordGeneratorTitle => 'Password Generator';

  @override
  String get passwordGeneratorHint => 'Press the button to generate a password';

  @override
  String get passwordGeneratorGenerate => 'Generate Password';

  @override
  String get passwordGeneratorLength => 'Length';

  @override
  String get passwordGeneratorCharacterTypes => 'Character Types';

  @override
  String get passwordGeneratorUppercase => 'Uppercase (A–Z)';

  @override
  String get passwordGeneratorLowercase => 'Lowercase (a–z)';

  @override
  String get passwordGeneratorNumbers => 'Numbers (0–9)';

  @override
  String get passwordGeneratorSymbols => 'Symbols (!@#\$...)';

  @override
  String get passwordGeneratorCopy => 'Copy';

  @override
  String get passwordGeneratorCopySuccess =>
      'Password copied, will be cleared in 30 sec';

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashEmptyButton => 'Delete All';

  @override
  String get trashEmptyTitle => 'Empty Trash';

  @override
  String get trashEmptyMessage =>
      'All items will be permanently deleted. This action cannot be undone.';

  @override
  String get trashDeleteTitle => 'Permanently Delete';

  @override
  String trashDeleteMessage(String title) {
    return 'Permanently delete \"$title\"?';
  }

  @override
  String get trashDeleteButton => 'Delete';

  @override
  String get trashEmpty => 'Trash is empty';

  @override
  String get trashEmptyHint => 'Deleted items are kept here for 7 days';

  @override
  String trashDeleteFor(String date) {
    return 'Will be permanently deleted on $date';
  }

  @override
  String get trashRestore => 'Restore';

  @override
  String get trashDeletePermanent => 'Permanently Delete';

  @override
  String get trashLoading => 'Loading...';

  @override
  String get trashError => 'Error';

  @override
  String get trashRetry => 'Retry';

  @override
  String get trashCancel => 'Cancel';

  @override
  String get auditLogTitle => 'Activity History';

  @override
  String get auditLogFilterAll => 'All';

  @override
  String get auditLogFilterAccount => 'Account';

  @override
  String get auditLogFilterSecurity => 'Security';

  @override
  String get auditLogFilterVault => 'Vault';

  @override
  String get auditLogActionRegister => 'Registered';

  @override
  String get auditLogActionLoginSuccess => 'Signed In';

  @override
  String get auditLogActionLoginFailed => 'Failed Sign In';

  @override
  String get auditLogActionLoginNewDevice => 'New Device Sign In';

  @override
  String get auditLogActionLogout => 'Signed Out';

  @override
  String get auditLogActionDeviceVerified => 'Device Verified';

  @override
  String get auditLogActionEmailChanged => 'Email Changed';

  @override
  String get auditLogActionPasswordReset => 'Password Reset';

  @override
  String get auditLogActionVaultItemCreated => 'Password Added';

  @override
  String get auditLogActionVaultItemUpdated => 'Password Updated';

  @override
  String get auditLogActionVaultItemDeleted => 'Password Deleted';

  @override
  String get auditLogUnknownAction => 'Unknown Action';

  @override
  String get auditLogEmpty => 'No activity yet';

  @override
  String auditLogEmptyCategory(String category) {
    return 'No records in $category category';
  }

  @override
  String get auditLogLoading => 'Loading...';

  @override
  String get auditLogError => 'Error';

  @override
  String get auditLogRetry => 'Retry';

  @override
  String get supportTicketTitle => 'Support';

  @override
  String get supportTicketMyTickets => 'My Tickets';

  @override
  String get supportTicketNew => 'New Ticket';

  @override
  String get supportTicketQuestion => 'How can we help you?';

  @override
  String get supportTicketCategoryLabel => 'Category';

  @override
  String get supportTicketCategoryBug => 'Bug Report';

  @override
  String get supportTicketCategorySuggestion => 'Suggestion';

  @override
  String get supportTicketCategoryOther => 'Other';

  @override
  String get supportTicketSubjectLabel => 'Subject';

  @override
  String get supportTicketSubjectError => 'Subject is required';

  @override
  String get supportTicketSubjectMinError => 'At least 5 characters';

  @override
  String get supportTicketMessageLabel => 'Your Message';

  @override
  String get supportTicketMessageError => 'Message is required';

  @override
  String get supportTicketMessageMinError => 'At least 20 characters';

  @override
  String get supportTicketPriorityLabel => 'Priority';

  @override
  String get supportTicketPriorityLow => 'Low';

  @override
  String get supportTicketPriorityNormal => 'Normal';

  @override
  String get supportTicketPriorityHigh => 'High';

  @override
  String get supportTicketSubmitButton => 'Submit';

  @override
  String get supportTicketStatusOpen => 'Open';

  @override
  String get supportTicketStatusInProgress => 'In Progress';

  @override
  String get supportTicketStatusClosed => 'Closed';

  @override
  String get supportTicketYourMessage => 'Your Message';

  @override
  String get supportTicketAdminReply => 'Support Reply';

  @override
  String get supportTicketWaitingReply => 'Waiting for reply...';

  @override
  String get supportTicketReplied => 'Replied';

  @override
  String get supportTicketWaitingReplyLong => 'Waiting for reply';

  @override
  String get supportTicketSuccess => 'Your support ticket has been submitted';

  @override
  String get supportTicketError => 'An error occurred';

  @override
  String get supportTicketLoadingError => 'Failed to load tickets';

  @override
  String get supportTicketLoadingRetry => 'Retry';

  @override
  String get supportTicketDetailMessage => 'Your Message';

  @override
  String get supportTicketDeleteConfirmTitle => 'Delete Ticket?';

  @override
  String get supportTicketDeleteConfirmMessage =>
      'This support ticket will be permanently deleted.';

  @override
  String get supportTicketDeleteCancel => 'Cancel';

  @override
  String get supportTicketDeleteConfirm => 'Delete';

  @override
  String get supportTicketDeleteSuccess => 'Ticket deleted';

  @override
  String get supportTicketDeleteError => 'Could not delete ticket';

  @override
  String get forceUpdateTitle => 'Update Required';

  @override
  String get forceUpdateDescription =>
      'This version is no longer supported.\nPlease update the app to continue.';

  @override
  String get forceUpdateCurrentVersion => 'Current version';

  @override
  String get forceUpdateMinimumVersion => 'Required version';

  @override
  String get forceUpdateButton => 'Update';

  @override
  String get forceUpdateButtonResume => 'Resume';

  @override
  String forceUpdateDownloading(int progress) {
    return 'Downloading... %$progress';
  }

  @override
  String forceUpdateError(String error) {
    return 'Download failed: $error';
  }

  @override
  String forceUpdateInstallError(String error) {
    return 'Failed to start installation: $error';
  }

  @override
  String forceUpdateInstallErrorFilePath(String filePath) {
    return 'Failed to start installation. File: $filePath';
  }

  @override
  String get forceUpdatePermissionTitle => 'Permission Required';

  @override
  String get forceUpdatePermissionContent =>
      'To install the APK, you need to grant \"Install unknown apps\" permission.\n\nSettings → Apps → DeniKey → Install unknown apps → Allow\n\nAfter granting permission, tap \"Update\" again.';

  @override
  String get forceUpdatePermissionOpenSettings => 'Open Settings';

  @override
  String get forceUpdatePermissionUnderstand => 'Got It';

  @override
  String get navBarSupport => 'Support';

  @override
  String get navBarLibrary => 'Library';

  @override
  String get navBarVault => 'My Vault';

  @override
  String get navBarGenerator => 'Generator';

  @override
  String get navBarSettings => 'Settings';

  @override
  String get desktopOnboardingTitle => 'Desktop Shortcuts';

  @override
  String get desktopOnboardingDescription =>
      'Try these shortcuts to use DeniKey faster.';

  @override
  String get desktopOnboardingShortcut1 => 'My Vault / Library / Settings';

  @override
  String get desktopOnboardingShortcut2 => 'Add new password';

  @override
  String get desktopOnboardingShortcut3 => 'Search';

  @override
  String get desktopOnboardingShortcut4 => 'Password Generator';

  @override
  String get desktopOnboardingShortcut5 => 'Switch between tabs';

  @override
  String get desktopOnboardingShortcut6 => 'Go back / close';

  @override
  String get desktopOnboardingWindowsNote =>
      'The X button closes the app. You can also exit by right-clicking the system tray icon.';

  @override
  String get desktopOnboardingButton => 'Got It';

  @override
  String get splashSubtitle => 'Zero Knowledge · Full Security';

  @override
  String get splashVersionPrefix => 'v';

  @override
  String get settingsAutoLockUnlimited => 'Unlimited';

  @override
  String settingsAutoLockMinutesChip(int minutes) {
    return '$minutes min';
  }

  @override
  String settingsClipboardSecondsChip(int seconds) {
    return '$seconds sec';
  }

  @override
  String get settingsClipboardUnlimited => 'Unlimited';

  @override
  String get settingsDeviceJustNow => 'Just now';

  @override
  String settingsDeviceMinutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String settingsDeviceHoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String settingsDeviceDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get onboardingClose => 'Close';

  @override
  String get onboardingWelcomeTitle => 'Welcome to DeniKey';

  @override
  String get onboardingWelcomeSubtitle =>
      'Your passwords, cards, and digital identities in one secure place — only in your hands.';

  @override
  String get onboardingChipZeroKnowledge => 'Zero Knowledge';

  @override
  String get onboardingChipMultiPlatform => 'Multi-Platform';

  @override
  String get onboardingChipSync => 'Instant Sync';

  @override
  String get onboardingVaultTitle => 'Your Vault Stores Everything';

  @override
  String get onboardingVaultSubtitle =>
      'Passwords, cards, notes, and custom fields. Copy with one tap, mask sensitive fields on demand.';

  @override
  String get onboardingVaultActionCopy => 'Copy';

  @override
  String get onboardingVaultActionShow => 'Show';

  @override
  String get onboardingVaultActionEdit => 'Edit';

  @override
  String get onboardingVaultMockBankCard => 'Bank Card';

  @override
  String get onboardingChipQuickAdd => 'Quick Add';

  @override
  String get onboardingChipFavorites => 'Favorites';

  @override
  String get onboardingChipHiddenField => 'Hidden Field';

  @override
  String get onboardingChipTrash => 'Trash';

  @override
  String get onboardingLibraryTitle => 'Stay Organized';

  @override
  String get onboardingLibrarySubtitle =>
      'Organize passwords with categories. Store credit cards, IDs, and more with item types.';

  @override
  String get onboardingLibraryCategorySocialMedia => 'Social Media';

  @override
  String get onboardingLibraryCategoryBanking => 'Banking';

  @override
  String get onboardingLibraryCategoryWork => 'Work';

  @override
  String get onboardingLibraryCategoryDevices => 'Devices';

  @override
  String onboardingLibraryPasswordCount(int count) {
    return '$count passwords';
  }

  @override
  String get onboardingLibraryItemTypesHeader => 'Item Types';

  @override
  String get onboardingLibraryItemTypesDesc =>
      'Credit Card, ID, SSH Key, Wi-Fi and more...';

  @override
  String get onboardingChipCategories => 'Categories';

  @override
  String get onboardingChipItemTypes => 'Item Types';

  @override
  String get onboardingChipCustomize => 'Customize';

  @override
  String get onboardingGeneratorTitle => 'Generate Strong Passwords';

  @override
  String get onboardingGeneratorSubtitle =>
      'Create unbreakable passwords with one tap — choose length, uppercase, lowercase, digits, and special characters.';

  @override
  String get onboardingGeneratorSectionLabel => 'Password Generator';

  @override
  String get onboardingGeneratorStrengthLabel => 'Strength:';

  @override
  String get onboardingGeneratorStrengthVeryStrong => 'Very Strong';

  @override
  String onboardingGeneratorLengthOption(int n) {
    return 'Length: $n';
  }

  @override
  String get onboardingChipRefresh => 'Refresh';

  @override
  String get onboardingSecurityTitle => 'Full Control Is Yours';

  @override
  String get onboardingSecuritySubtitle =>
      'Manage your security from every angle with fingerprint, auto-lock, device banning, and audit log.';

  @override
  String get onboardingSecurityBiometric => 'Biometric';

  @override
  String get onboardingSecurityBiometricDesc => 'Quick access with fingerprint';

  @override
  String get onboardingSecurityAutoLock => 'Auto Lock';

  @override
  String get onboardingSecurityAutoLockDesc => 'Lock on timeout or focus loss';

  @override
  String get onboardingSecurityDeviceManagement => 'Device Management';

  @override
  String get onboardingSecurityDeviceManagementDesc =>
      'View and revoke sessions';

  @override
  String get onboardingSecurityAuditLog => 'Audit Log';

  @override
  String get onboardingSecurityAuditLogDesc => 'Track every action';

  @override
  String get onboardingSecurityZeroKnowledgeTitle =>
      'Zero-Knowledge Architecture';

  @override
  String get onboardingSecurityZeroKnowledgeDesc =>
      'Your master password is never sent to the server.';

  @override
  String get onboardingReadyTitle => 'Ready to Get Started?';

  @override
  String get onboardingReadySubtitle =>
      'Create an account or sign in. Security is no longer complicated.';

  @override
  String get onboardingReplayTitle => 'You Remember Everything!';

  @override
  String get onboardingReplaySubtitle =>
      'For questions, contact us via Settings → Support Ticket.';

  @override
  String get onboardingSummaryZeroKnowledge =>
      'Zero knowledge — your data belongs only to you';

  @override
  String get onboardingSummaryAddPassword => 'Vault → add and manage passwords';

  @override
  String get onboardingSummaryGenerator => 'Generate strong passwords';

  @override
  String get onboardingSummaryBiometric => 'Quick login with biometrics';

  @override
  String get vaultItemUntitled => 'Untitled';

  @override
  String get vaultItemDetailFallbackTitle => 'Details';

  @override
  String get categoriesUncategorized => 'Uncategorized';

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String get networkError => 'Could not connect to server';

  @override
  String get addItemTypeCreateTitle => 'Create New Type';

  @override
  String get addItemTypeFieldsLabel => 'Fields';

  @override
  String get onboardingCategoriesTitle => 'Organize with categories';

  @override
  String get onboardingCategoriesSubtitle =>
      'Group your passwords into folders. Uncategorized is always there and cannot be deleted.';

  @override
  String get onboardingCategoriesDefault => 'Uncategorized';

  @override
  String get onboardingCategoriesDefaultLock => 'Cannot be deleted or renamed';

  @override
  String get onboardingCategoriesChipDefault => 'Default Folder';

  @override
  String get onboardingCategoriesChipCustom => 'Custom Categories';

  @override
  String get onboardingCategoriesChipOrganize => 'Organize';

  @override
  String get onboardingTypesTitle => 'Speed up with templates';

  @override
  String get onboardingTypesSubtitle =>
      'Define your common field groups once. They\'ll be ready every time you add a new password.';

  @override
  String get onboardingTypesWithout => 'Without a type';

  @override
  String get onboardingTypesWith => 'With a type';

  @override
  String get onboardingTypesWithoutDesc => 'Add field, add field, add field...';

  @override
  String get onboardingTypesWithDesc => 'Fields are ready to go!';

  @override
  String get onboardingTypesChipTemplate => 'Template';

  @override
  String get onboardingTypesChipSpeed => 'Quick Save';

  @override
  String get onboardingTypesChipCustomize => 'Customize';

  @override
  String get notifAutoLockTitle => 'DeniKey Locked';

  @override
  String get notifAutoLockBody =>
      'Auto-lock activated. Enter your master password to continue.';

  @override
  String get notifNewDeviceTitle => 'New Device Login';

  @override
  String get notifNewDeviceBody =>
      'A new device attempted to access your account. If this wasn\'t you, change your password immediately.';

  @override
  String get notifChannelName => 'DeniKey Notifications';

  @override
  String get notifChannelDesc =>
      'Security reminders and important notifications';

  @override
  String get biometricFaceLabel => 'Unlock with Face ID';

  @override
  String get biometricFingerprintLabel => 'Unlock with Fingerprint';

  @override
  String get biometricPinLabel => 'Unlock with Device PIN';

  @override
  String get biometricReason => 'Authenticate to access DeniKey';

  @override
  String get trayOpen => 'Open DeniKey';

  @override
  String get trayExit => 'Exit';

  @override
  String get shortcutSupport => 'Support Ticket';

  @override
  String get shortcutVault => 'Go to Vault';

  @override
  String get shortcutLibrary => 'Go to Library';

  @override
  String get shortcutSettings => 'Go to Settings';

  @override
  String get shortcutNewPassword => 'Add new password';

  @override
  String get shortcutSearch => 'Search';

  @override
  String get shortcutGenerator => 'Password Generator';

  @override
  String get shortcutNewPasswordVault => 'New password (vault screen)';

  @override
  String get shortcutTabSwitch => 'Switch between tabs';

  @override
  String get shortcutBack => 'Go back';

  @override
  String get authLoadingLogin => 'Signing in...';

  @override
  String get authLoadingRegister => 'Creating account...';

  @override
  String get authErrorLogin => 'Login failed.';

  @override
  String get authErrorRegister => 'Registration failed.';

  @override
  String get vaultLoadingVault => 'Loading vault...';

  @override
  String get vaultLoadingSaving => 'Saving...';

  @override
  String get vaultLoadingUpdating => 'Updating...';

  @override
  String get vaultLoadingDeleting => 'Deleting...';

  @override
  String get vaultLoadingMoving => 'Moving...';

  @override
  String vaultLoadingDeletingCount(int count) {
    return 'Deleting $count records...';
  }

  @override
  String get vaultErrorTimeout => 'Server did not respond. Please try again.';

  @override
  String get vaultErrorLoad => 'Could not load.';

  @override
  String get vaultErrorOffline => 'No internet connection.';

  @override
  String get vaultSampleTitle => 'DeniKey Sample Entry';

  @override
  String get vaultSampleNotes =>
      'This is an automatically created sample entry. You can delete it after adding your own account details.';

  @override
  String get errorCouldNotLoad => 'Could not load';

  @override
  String get errorCouldNotCreate => 'Could not create';

  @override
  String get errorCouldNotUpdate => 'Could not update';

  @override
  String get errorCouldNotDelete => 'Could not delete';

  @override
  String get offlineTitle =>
      'Unfortunately, you can\'t access DeniKey without internet';

  @override
  String get offlineMessage =>
      'Don\'t worry, this is not a problem. Your account and content are safe. Full access will return when you reconnect to the internet.';

  @override
  String get addItemFieldNameRequired => 'This field is required';
}
