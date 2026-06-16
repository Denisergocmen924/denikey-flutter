// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get loginTagline => 'Ваши пароли в безопасности';

  @override
  String get loginUsernameLabel => 'Имя пользователя или Email';

  @override
  String get loginUsernameError => 'Требуется имя пользователя или email';

  @override
  String get loginUsernameMinError => 'Не менее 3 символов';

  @override
  String get loginPasswordLabel => 'Мастер-пароль';

  @override
  String get loginPasswordError => 'Пароль обязателен';

  @override
  String get loginPasswordMinError => 'Не менее 6 символов';

  @override
  String get loginSubmitButton => 'Войти';

  @override
  String get loginNoAccountQuestion => 'Нет аккаунта?';

  @override
  String get loginRegisterButton => 'Зарегистрироваться';

  @override
  String get loginError => 'Ошибка';

  @override
  String get registerAppBarTitle => 'Регистрация';

  @override
  String get registerHeading => 'Создать аккаунт';

  @override
  String get registerSubheading => 'Ваша личность остаётся конфиденциальной.';

  @override
  String get registerUsernameLabel => 'Имя пользователя';

  @override
  String get registerUsernameError => 'Требуется имя пользователя';

  @override
  String get registerUsernameMinError => 'Не менее 3 символов';

  @override
  String get registerUsernameMaxError => 'Не более 50 символов';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailError => 'Требуется email';

  @override
  String get registerEmailFormatError => 'Введите корректный email';

  @override
  String get registerPasswordLabel => 'Мастер-пароль';

  @override
  String get registerPasswordError => 'Пароль обязателен';

  @override
  String get registerPasswordMinError => 'Не менее 10 символов';

  @override
  String get registerConfirmLabel => 'Подтверждение пароля';

  @override
  String get registerConfirmError => 'Пароли не совпадают';

  @override
  String get registerBirthdateLabel => 'Дата рождения';

  @override
  String get registerBirthdateHelper => 'Выберите дату рождения';

  @override
  String get registerBirthdateSelect => 'Выбрать';

  @override
  String get registerBirthdateMissing => 'Пожалуйста, выберите дату рождения';

  @override
  String get registerAgeRestriction =>
      'Для использования DeniKey вам должно быть не менее 13 лет';

  @override
  String get registerSubmitButton => 'Зарегистрироваться';

  @override
  String get registerError => 'Ошибка';

  @override
  String get verifyEmailTitle => 'Подтверждение Email';

  @override
  String get verifyDeviceTitle => 'Подтверждение устройства';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Введите 6-значный код,\nотправленный на $email';
  }

  @override
  String verifyDeviceSubtitle(String email) {
    return 'Вы впервые входите с этого устройства.\nВведите 6-значный код, отправленный на $email.';
  }

  @override
  String get verifySpamWarning => 'Проверьте папку Спам/Нежелательные';

  @override
  String get verifyCodeError => 'Пожалуйста, введите 6-значный код';

  @override
  String get verifySubmitButton => 'Подтвердить';

  @override
  String get verifyResendButton => 'Отправить код повторно';

  @override
  String get verifySendSuccess => 'Код отправлен повторно';

  @override
  String get verifySendError => 'Не удалось отправить код';

  @override
  String get changeEmailTitle => 'Изменить Email';

  @override
  String get changeEmailHeading => 'Новый адрес Email';

  @override
  String get changeEmailDescription =>
      'На ваш новый email будет отправлен код подтверждения.';

  @override
  String get changeEmailLabel => 'Новый Email';

  @override
  String get changeEmailError => 'Требуется email';

  @override
  String get changeEmailFormatError => 'Введите корректный email';

  @override
  String get changeEmailSubmitButton => 'Отправить код';

  @override
  String get changeEmailApiError => 'Произошла ошибка';

  @override
  String get confirmEmailChangeTitle => 'Подтверждение Email';

  @override
  String get confirmEmailChangeHeading => 'Подтвердите код';

  @override
  String confirmEmailChangeDescription(String newEmail) {
    return 'Введите 6-значный код, отправленный на $newEmail.';
  }

  @override
  String get confirmEmailChangeCodeLabel => 'Код подтверждения';

  @override
  String get confirmEmailChangeCodeError => 'Требуется код';

  @override
  String get confirmEmailChangeCodeMinError => 'Введите 6-значный код';

  @override
  String get confirmEmailChangeSubmitButton => 'Подтвердить';

  @override
  String get confirmEmailChangeSuccess => 'Ваш email успешно обновлён';

  @override
  String get confirmEmailChangeApiError => 'Произошла ошибка';

  @override
  String get masterLockTitle => 'DeniKey заблокирован';

  @override
  String get masterLockPassword => 'Введите мастер-пароль для продолжения';

  @override
  String get masterLockBiometricExpired =>
      '7-дневный период биометрии истёк.\nВведите мастер-пароль в целях безопасности.';

  @override
  String get masterLockPasswordLabel => 'Мастер-пароль';

  @override
  String get masterLockPasswordError => 'Пароль обязателен';

  @override
  String get masterLockWrongPassword => 'Неверный мастер-пароль';

  @override
  String get masterLockAuthFailed => 'Ошибка аутентификации';

  @override
  String get masterLockBiometricNeeded =>
      'Пожалуйста, введите мастер-пароль один раз';

  @override
  String get masterLockButton => 'Разблокировать';

  @override
  String masterLockBiometricDaysRemaining(int days) {
    return 'Пароль потребуется через $days дн.';
  }

  @override
  String get masterLockBiometricTomorrow => 'Пароль потребуется завтра';

  @override
  String get masterLockDifferentAccount => 'Войти с другим аккаунтом';

  @override
  String get masterLockTooManyAttempts =>
      'Слишком много неверных попыток. Сессия завершена в целях безопасности.';

  @override
  String get masterLockDeriving => 'Создание ключа шифрования...';

  @override
  String get lockTitle => 'DeniKey заблокирован';

  @override
  String get lockDescription => 'Подтвердите личность для продолжения';

  @override
  String get lockBiometricButton => 'Разблокировать биометрией';

  @override
  String get lockLogoutButton => 'Выйти';

  @override
  String get lockAuthFailed => 'Ошибка аутентификации';

  @override
  String get deviceBannedTitle => 'Устройство заблокировано';

  @override
  String get deviceBannedDescription =>
      'Это устройство нельзя использовать для данного аккаунта.\nВладелец аккаунта ограничил ваш доступ.';

  @override
  String get deviceBannedBackButton => 'Назад';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAccountSection => 'АККАУНТ';

  @override
  String get settingsUsernameChange => 'Изменить имя пользователя';

  @override
  String get settingsEmailChange => 'Изменить Email';

  @override
  String get settingsMyDevices => 'Мои устройства';

  @override
  String get settingsAppSection => 'ПРИЛОЖЕНИЕ';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsPasswordGenerator => 'Генератор паролей';

  @override
  String get settingsAuditLog => 'История активности';

  @override
  String get settingsSupportTicket => 'Служба поддержки';

  @override
  String get settingsPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get settingsBiometricLock => 'Биометрическая блокировка';

  @override
  String settingsBiometricActive(int days) {
    return 'Активно  ·  Пароль через $days дн.';
  }

  @override
  String get settingsBiometricActiveTomorrow =>
      'Активно  ·  Пароль потребуется завтра';

  @override
  String get settingsBiometricExpired =>
      'Требуется мастер-пароль — обновится после разблокировки';

  @override
  String get settingsBiometricDescription =>
      'Быстрый доступ с отпечатком пальца или распознаванием лица.\nДля безопасности мастер-пароль будет запрашиваться каждые 7 дней.';

  @override
  String get settingsAutoLock => 'Автоблокировка';

  @override
  String settingsAutoLockEnabled(int minutes) {
    return 'Блокировать через $minutes мин';
  }

  @override
  String get settingsAutoLockFocusLoss =>
      'Без ограничений — блокировать при потере фокуса';

  @override
  String get settingsAutoLockDisabled => 'Запрашивать мастер-пароль при выходе';

  @override
  String get settingsClipboardTimeout => 'Очистка буфера';

  @override
  String settingsClipboardTimeoutActive(int timeout) {
    return 'Скопированный пароль удалится через $timeout сек';
  }

  @override
  String get settingsClipboardTimeoutDisabled =>
      'Без ограничений — буфер не очищается автоматически';

  @override
  String get settingsKeyboardShortcuts => 'Горячие клавиши';

  @override
  String get settingsKeyboardHint => 'Ctrl+1/2/3, +, ←→, Esc и др.';

  @override
  String get settingsDarkMode => 'Тёмная тема';

  @override
  String get settingsDarkModeSystem => 'Следовать системе';

  @override
  String get settingsDarkModeEnabled => 'Вкл';

  @override
  String get settingsDarkModeDisabled => 'Выкл';

  @override
  String get settingsHowToUse => 'КАК ИСПОЛЬЗОВАТЬ';

  @override
  String get settingsDiscoverApp => 'Изучить приложение';

  @override
  String get settingsDiscoverAppDescription => 'Обзор всех возможностей';

  @override
  String get settingsHelp => 'Помощь';

  @override
  String get settingsHelpAddPassword => 'Добавление пароля';

  @override
  String get settingsHelpAddPasswordContent =>
      'Перейдите на вкладку \"Мой сейф\" в нижнем меню. Нажмите кнопку \"+ Новый пароль\" справа внизу. Введите название сайта, имя пользователя и пароль; сохраните.';

  @override
  String get settingsHelpPasswordGenerator => 'Генератор паролей';

  @override
  String get settingsHelpPasswordGeneratorContent =>
      'На экране Приложение → Генератор паролей можно создавать надёжные пароли, выбирая длину, регистр, цифры и специальные символы.';

  @override
  String get settingsHelpCategories => 'Категории и типы';

  @override
  String get settingsHelpCategoriesContent =>
      'На вкладке «Библиотека» можно организовать пароли по категориям и создавать новые типы элементов.';

  @override
  String get settingsHelpTrash => 'Корзина';

  @override
  String get settingsHelpTrashContent =>
      'Удалённые пароли хранятся в корзине 7 дней. Доступ — через значок корзины в правом верхнем углу экрана Сейфа.';

  @override
  String get settingsHelpZeroKnowledge => 'Безопасность с нулевым знанием';

  @override
  String get settingsHelpZeroKnowledgeContent =>
      'В DeniKey ваш мастер-пароль никогда не отправляется на сервер и нигде не хранится. Пароли шифруются на устройстве ключом, полученным алгоритмом Argon2id, в формате AES-256-GCM; этот ключ существует только на вашем устройстве. На сервер передаются только зашифрованные данные. Если вы забудете мастер-пароль, восстановить данные невозможно — это неизбежное следствие настоящей безопасности с нулевым знанием.';

  @override
  String get settingsLogout => 'Выйти';

  @override
  String get settingsDeleteAccount => 'Удалить аккаунт навсегда';

  @override
  String get settingsDeleteAccountWarning =>
      'Все данные будут удалены безвозвратно';

  @override
  String settingsVersion(String version) {
    return 'DeniKey v$version';
  }

  @override
  String get settingsDevicesTitle => 'Мои устройства';

  @override
  String get settingsDevicesEmpty => 'Нет зарегистрированных устройств';

  @override
  String get settingsDevicesError => 'Не удалось загрузить устройства';

  @override
  String get settingsDeviceRefresh => 'Обновить';

  @override
  String get settingsDeviceStatusActive => 'Активно';

  @override
  String get settingsDeviceStatusPassive => 'Пассивно';

  @override
  String get settingsDeviceStatusBanned => 'Заблокировано';

  @override
  String get settingsDeviceRevoke => 'Завершить сессию';

  @override
  String get settingsDeviceRevokeSuccess => 'Сессия завершена';

  @override
  String get settingsDeviceBan => 'Заблокировать устройство';

  @override
  String get settingsDeviceBanSuccess => 'Устройство заблокировано';

  @override
  String get settingsDeviceUnban => 'Разблокировать устройство';

  @override
  String get settingsDeviceUnbanSuccess => 'Блокировка устройства снята';

  @override
  String get settingsDeviceActionFailed => 'Действие не выполнено';

  @override
  String get settingsDeviceRemove => 'Удалить устройство';

  @override
  String get settingsDeviceRemoveConfirm =>
      'Устройство будет удалено навсегда. Вы уверены?';

  @override
  String get settingsDeviceRemoveSuccess => 'Устройство удалено';

  @override
  String get settingsDeviceRename => 'Переименовать';

  @override
  String get settingsDeviceRenameHint => 'Имя устройства';

  @override
  String get settingsDeviceRenameSuccess => 'Имя устройства обновлено';

  @override
  String get settingsUsernameChangeTitle => 'Изменить имя пользователя';

  @override
  String get settingsUsernameChangeHint => 'Новое имя пользователя';

  @override
  String get settingsUsernameChangeError => 'Не может быть пустым';

  @override
  String get settingsUsernameChangeMinError => 'Не менее 3 символов';

  @override
  String get settingsUsernameChangePatternError =>
      'Допустимы только буквы, цифры и _';

  @override
  String get settingsUsernameChangeSaved => 'Имя пользователя обновлено';

  @override
  String get settingsUsernameChangeFailed => 'Не удалось обновить';

  @override
  String get settingsDeleteAccountStep1 => 'Удалить аккаунт — Шаг 1/4';

  @override
  String get settingsDeleteAccountWarningContent =>
      'Это действие нельзя отменить. Все ваши данные будут удалены безвозвратно.';

  @override
  String get settingsDeleteAccountUsernameHint => 'Введите имя пользователя';

  @override
  String get settingsDeleteAccountStep2 => 'Удалить аккаунт — Шаг 2/4';

  @override
  String get settingsDeleteAccountPasswordHint => 'Введите мастер-пароль';

  @override
  String get settingsDeleteAccountStep3 => 'Удалить аккаунт — Шаг 3/4';

  @override
  String get settingsDeleteAccountConfirm =>
      'Вы уверены, что хотите удалить аккаунт?';

  @override
  String settingsDeleteAccountCountdownWait(int seconds) {
    return 'Нужно подождать $seconds секунд...';
  }

  @override
  String get settingsDeleteAccountCountdownReady => 'Вы можете продолжить.';

  @override
  String get settingsDeleteAccountYesConfirm => 'Да, продолжить';

  @override
  String get settingsDeleteAccountStep4 => 'Удалить аккаунт — Шаг 4/4';

  @override
  String get settingsDeleteAccountFinalMessage =>
      'Последний шаг: введите пароль ещё раз.';

  @override
  String get settingsDeleteAccountPasswordConfirmHint =>
      'Повторите мастер-пароль';

  @override
  String get settingsDeleteAccountFinalButton => 'Удалить аккаунт навсегда';

  @override
  String get settingsDeleteAccountFailed => 'Не удалось удалить аккаунт';

  @override
  String get settingsDeleteAccountCancel => 'Отмена';

  @override
  String get settingsDeleteAccountContinue => 'Продолжить';

  @override
  String get privacyPolicyTitle => 'Политика конфиденциальности';

  @override
  String get privacyPolicyLastUpdate => 'Последнее обновление: апрель 2026';

  @override
  String get privacyPolicySection1Title => '1. Введение';

  @override
  String get privacyPolicySection1Body =>
      'DeniKey («приложение», «мы», «сервис») — менеджер паролей с архитектурой нулевого знания. Эта Политика конфиденциальности объясняет, какие данные собираются при использовании приложения, как они обрабатываются и каковы ваши права.';

  @override
  String get privacyPolicySection2Title => '2. Собираемые данные';

  @override
  String get privacyPolicySection2Body =>
      '• Email и имя пользователя — для создания аккаунта и аутентификации.\n• Производное значение (хэш) мастер-пароля — открытый текст никогда не хранится.\n• Зашифрованные данные сейфа — отправляются на сервер после шифрования AES-256-GCM на вашем устройстве; только вы можете прочитать содержимое.\n• Токены сессий и идентификатор устройства — для управления несколькими устройствами.\n• Журналы аудита — для мониторинга безопасности вашего аккаунта, доступны только вам.';

  @override
  String get privacyPolicySection3Title => '3. Архитектура нулевого знания';

  @override
  String get privacyPolicySection3Body =>
      'DeniKey никогда не отправляет ваш мастер-пароль на сервер и нигде его не хранит. Данные сейфа шифруются на вашем устройстве ключом, полученным алгоритмом Argon2id, в формате AES-256-GCM. Наши серверы хранят только зашифрованные данные; технически мы не можем получить доступ к вашему содержимому.\n\nЕсли вы забудете мастер-пароль, восстановить данные невозможно — это неизбежное следствие настоящей безопасности с нулевым знанием.';

  @override
  String get privacyPolicySection4Title => '4. Использование данных';

  @override
  String get privacyPolicySection4Body =>
      'Собранные данные используются только для:\n• Создания и управления вашим аккаунтом\n• Аутентификации и безопасности сессий\n• Уведомлений о подтверждении email и сбросе пароля\n• Ответов на ваши обращения в поддержку\n\nВаши данные не передаются третьим лицам и не используются в рекламных целях.';

  @override
  String get privacyPolicySection5Title => '5. Безопасность данных';

  @override
  String get privacyPolicySection5Body =>
      '• Все коммуникации зашифрованы через HTTPS/TLS.\n• Данные сейфа хранятся в зашифрованном виде на сервере.\n• Пароли производятся с помощью Argon2id (память: 64 МБ, итерации: 3, параллелизм: 2); устойчивы к атакам методом перебора.\n• JWT-токены краткосрочны и управляются механизмом обновления.';

  @override
  String get privacyPolicySection6Title => '6. Удаление аккаунта';

  @override
  String get privacyPolicySection6Body =>
      'Вы можете удалить аккаунт в любое время через Настройки → Удалить аккаунт навсегда. Удаление требует 4-шагового подтверждения, все ваши данные (элементы сейфа, категории, журналы аудита) будут удалены безвозвратно. Это действие нельзя отменить.';

  @override
  String get privacyPolicySection7Title => '7. Конфиденциальность детей';

  @override
  String get privacyPolicySection7Body =>
      'DeniKey не предназначен для детей до 13 лет. Мы намеренно не собираем данные этой возрастной группы.';

  @override
  String get privacyPolicySection8Title => '8. Изменения политики';

  @override
  String get privacyPolicySection8Body =>
      'Мы можем обновлять эту политику. О важных изменениях вы будете уведомлены на зарегистрированный email. Актуальная политика всегда доступна в приложении.';

  @override
  String get privacyPolicySection9Title => '9. Контакты';

  @override
  String get privacyPolicySection9Body =>
      'По вопросам конфиденциальности вы можете создать обращение в поддержку или воспользоваться экраном «Служба поддержки» в приложении.';

  @override
  String get vaultTitle => 'DeniKey';

  @override
  String get vaultSearchTooltip => 'Поиск';

  @override
  String get vaultTrashTooltip => 'Корзина';

  @override
  String get vaultRefreshTooltip => 'Обновить';

  @override
  String get vaultOfflineWarning =>
      'Доступ к сейфу недоступен без подключения к интернету';

  @override
  String get vaultOfflineWarningDesktop => 'Режим офлайн — только чтение';

  @override
  String get vaultBulkDeleteTitle => 'Массовое удаление';

  @override
  String vaultBulkDeleteMessage(int count) {
    return '$count записей будет перемещено в корзину. Продолжить?';
  }

  @override
  String get vaultBulkSelectAll => 'Все';

  @override
  String vaultBulkMoveTitle(int count) {
    return 'Переместить $count записей';
  }

  @override
  String get vaultBulkMoveUncategorized => 'Без категории';

  @override
  String get vaultCategoryEmpty => 'В этой категории нет паролей';

  @override
  String get vaultEmpty => 'Паролей пока нет';

  @override
  String get vaultEmptyHint => 'Добавьте новый пароль с помощью +';

  @override
  String get vaultFavoritesSection => 'Избранное';

  @override
  String get vaultOthersSection => 'Остальные';

  @override
  String get vaultFavoritesAdd => 'Добавить в избранное';

  @override
  String get vaultFavoritesRemove => 'Убрать из избранного';

  @override
  String get vaultAddButton => 'Новый пароль';

  @override
  String get vaultBulkDeleteButton => 'Удалить';

  @override
  String get vaultBulkMoveButton => 'Переместить';

  @override
  String get vaultBulkFavoritesButton => 'В избранное';

  @override
  String get vaultBulkFavoritesRemoveButton => 'Убрать из избранного';

  @override
  String get vaultLoading => 'Загрузка...';

  @override
  String get vaultError => 'Ошибка';

  @override
  String get vaultRetry => 'Повторить';

  @override
  String vaultBulkSelectionCount(int count) {
    return '$count выбрано';
  }

  @override
  String get addItemStep0 => 'Выбрать категорию';

  @override
  String get addItemStep2 => 'Ввести данные';

  @override
  String get addItemUncategorized => 'Без категории';

  @override
  String get addItemUncategorizedSubtitle => 'Сохранить без категории';

  @override
  String get addItemCreateCategory => 'Создать категорию';

  @override
  String get addItemCreateCategorySubtitle => 'Добавить новую категорию';

  @override
  String get addItemNewCategory => 'Новая категория';

  @override
  String get addItemNewCategoryName => 'Название категории';

  @override
  String get addItemTypeNameLabel => 'Название типа';

  @override
  String get addItemTypeSelectIcon => 'Выбрать иконку';

  @override
  String get addItemTypeFixedFields => 'Фиксированные поля';

  @override
  String get addItemTypeFieldAdd => 'Добавить поле';

  @override
  String get addItemTypeFieldDefault =>
      'Поля не добавлены — по умолчанию будет создано поле «Пароль».';

  @override
  String get addItemTypeFieldName => 'Название поля';

  @override
  String get addItemTypeFieldType => 'Тип';

  @override
  String get addItemTypeFieldTypeText => 'Текст';

  @override
  String get addItemTypeFieldTypeSecret => 'Секрет';

  @override
  String get addItemTypeFieldTypeNumber => 'Число';

  @override
  String get addItemTypeFieldTypeDate => 'Дата';

  @override
  String get addItemTitleLabel => 'Заголовок *';

  @override
  String get addItemTitleHint => 'Напр.: Instagram, Gmail, Netflix';

  @override
  String get addItemExtraFieldKeyLabel => 'Название поля';

  @override
  String get addItemExtraFieldValueLabel => 'Значение';

  @override
  String get addItemAddFieldButton => 'Добавить поле';

  @override
  String get addItemSaveButton => 'Сохранить';

  @override
  String get addItemPasswordStrengthVeryWeak => 'Очень слабый';

  @override
  String get addItemPasswordStrengthWeak => 'Слабый';

  @override
  String get addItemPasswordStrengthMedium => 'Средний';

  @override
  String get addItemPasswordStrengthStrong => 'Надёжный';

  @override
  String get addItemPasswordStrengthVeryStrong => 'Очень надёжный';

  @override
  String get addItemErrorSave => 'Произошла ошибка при добавлении записи.';

  @override
  String get addItemCategoryCreate => 'Создать';

  @override
  String get addItemTypeCreate => 'Добавить';

  @override
  String get addItemCancel => 'Отмена';

  @override
  String get detailPasswordLabel => 'Пароль';

  @override
  String get detailCategoryLabel => 'Папка';

  @override
  String get detailCategoryUncategorized => 'Без категории';

  @override
  String get detailCategoryMove => 'Переместить в папку';

  @override
  String get detailExternalLinkTitle => 'Внешняя ссылка';

  @override
  String detailExternalLinkMessage(String url) {
    return 'DeniKey собирается открыть эту ссылку:\n\n$url';
  }

  @override
  String get detailExternalLinkDeny => 'Запретить';

  @override
  String get detailExternalLinkOnce => 'Только этот раз';

  @override
  String get detailExternalLinkNoAsk => 'Больше не спрашивать';

  @override
  String get detailDeleteTitle => 'Удалить';

  @override
  String get detailDeleteMessage =>
      'Вы уверены, что хотите удалить этот пароль?';

  @override
  String get detailDeleteButton => 'Удалить';

  @override
  String get detailFavoritesAdd => 'Добавить в избранное';

  @override
  String get detailFavoritesRemove => 'Убрать из избранного';

  @override
  String get detailPasswordHistory => 'История паролей';

  @override
  String get detailEditButton => 'Редактировать';

  @override
  String get detailCancelEdit => 'Отмена';

  @override
  String get detailEditTitle => 'Заголовок';

  @override
  String get detailEditPassword => 'Пароль';

  @override
  String get detailEditCustomFieldKeyLabel => 'Заголовок';

  @override
  String get detailEditCustomFieldValueLabel => 'Содержимое';

  @override
  String get detailEditSaveButton => 'Сохранить';

  @override
  String get detailEditErrorBlankTitle => 'Заголовок не может быть пустым';

  @override
  String get detailEditErrorGeneral => 'Не удалось обновить, попробуйте снова';

  @override
  String detailInfoTilePasswordCopied(String label, int timeout) {
    return '$label скопирован, будет удалён через $timeout сек';
  }

  @override
  String detailInfoTileCopied(String label) {
    return '$label скопирован';
  }

  @override
  String get detailLinkOpen => 'Открыть ссылку';

  @override
  String detailLoadError(String error) {
    return 'Не удалось загрузить данные: $error';
  }

  @override
  String get detailRetry => 'Повторить';

  @override
  String get searchHint => 'Поиск...';

  @override
  String get searchEmpty => 'Начните вводить для поиска';

  @override
  String searchNoResults(String query) {
    return 'По запросу \"$query\" ничего не найдено';
  }

  @override
  String passwordHistoryTitle(String itemTitle) {
    return '$itemTitle — История';
  }

  @override
  String get passwordHistoryClear => 'Очистить историю';

  @override
  String get passwordHistoryClearTitle => 'Очистить историю';

  @override
  String get passwordHistoryClearMessage => 'Удалить всю историю паролей?';

  @override
  String get passwordHistoryEmpty => 'Истории паролей нет';

  @override
  String get passwordHistoryEmptyHint =>
      'Предыдущие версии появятся здесь при обновлении пароля';

  @override
  String passwordHistoryCopy(int timeout) {
    return 'Пароль скопирован, будет удалён через $timeout сек';
  }

  @override
  String get passwordHistoryCopyNoTimeout => 'Пароль скопирован';

  @override
  String get passwordHistoryError => 'Не удалось загрузить';

  @override
  String get passwordHistoryRetry => 'Повторить';

  @override
  String get libraryTitle => 'Библиотека';

  @override
  String get libraryCategoriesTab => 'Категории';

  @override
  String get libraryTypesTab => 'Типы';

  @override
  String get libraryAddCategory => 'Новая категория';

  @override
  String get libraryCategoryName => 'Название категории';

  @override
  String get libraryCategoryColorSelect => 'Выбрать цвет';

  @override
  String get libraryDeleteCategoryTitle => 'Удалить';

  @override
  String get libraryDeleteCategoryMessage =>
      'Вы уверены, что хотите удалить эту категорию?';

  @override
  String get libraryDeleteSystemCategory =>
      'Системные категории нельзя удалять.';

  @override
  String get libraryDeleteSystemType => 'Системные типы нельзя удалять.';

  @override
  String get libraryEmptyCategories => 'Категорий пока нет';

  @override
  String get libraryEmptyTypes => 'Типов пока нет';

  @override
  String get librarySystemLabel => 'Система';

  @override
  String libraryTypeFieldCount(int count) {
    return '$count полей';
  }

  @override
  String get libraryCancel => 'Отмена';

  @override
  String get libraryAddButton => 'Добавить';

  @override
  String get categoryDetailEmpty => 'В этой категории пока нет элементов';

  @override
  String get categoryDetailItem => 'Без названия';

  @override
  String get passwordGeneratorTitle => 'Генератор паролей';

  @override
  String get passwordGeneratorHint => 'Нажмите кнопку для генерации пароля';

  @override
  String get passwordGeneratorGenerate => 'Сгенерировать пароль';

  @override
  String get passwordGeneratorLength => 'Длина';

  @override
  String get passwordGeneratorCharacterTypes => 'Типы символов';

  @override
  String get passwordGeneratorUppercase => 'Заглавные (A–Z)';

  @override
  String get passwordGeneratorLowercase => 'Строчные (a–z)';

  @override
  String get passwordGeneratorNumbers => 'Цифры (0–9)';

  @override
  String get passwordGeneratorSymbols => 'Символы (!@#\$...)';

  @override
  String get passwordGeneratorCopy => 'Копировать';

  @override
  String passwordGeneratorCopySuccess(int timeout) {
    return 'Пароль скопирован, будет удалён через $timeout сек';
  }

  @override
  String get passwordGeneratorCopySuccessNoTimeout => 'Пароль скопирован';

  @override
  String get trashTitle => 'Корзина';

  @override
  String get trashEmptyButton => 'Удалить все';

  @override
  String get trashEmptyTitle => 'Очистить корзину';

  @override
  String get trashEmptyMessage =>
      'Все элементы будут удалены безвозвратно. Это действие нельзя отменить.';

  @override
  String get trashDeleteTitle => 'Удалить навсегда';

  @override
  String trashDeleteMessage(String title) {
    return 'Удалить «$title» безвозвратно?';
  }

  @override
  String get trashDeleteButton => 'Удалить';

  @override
  String get trashEmpty => 'Корзина пуста';

  @override
  String get trashEmptyHint => 'Удалённые элементы хранятся здесь 7 дней';

  @override
  String trashDeleteFor(String date) {
    return 'Будет удалён $date';
  }

  @override
  String get trashRestore => 'Восстановить';

  @override
  String get trashDeletePermanent => 'Удалить навсегда';

  @override
  String get trashError => 'Ошибка';

  @override
  String get trashRetry => 'Повторить';

  @override
  String get trashCancel => 'Отмена';

  @override
  String get auditLogTitle => 'История активности';

  @override
  String get auditLogFilterAll => 'Все';

  @override
  String get auditLogFilterAccount => 'Аккаунт';

  @override
  String get auditLogFilterSecurity => 'Безопасность';

  @override
  String get auditLogFilterVault => 'Сейф';

  @override
  String get auditLogActionRegister => 'Регистрация';

  @override
  String get auditLogActionLoginSuccess => 'Вход выполнен';

  @override
  String get auditLogActionLoginFailed => 'Неудачная попытка входа';

  @override
  String get auditLogActionLoginNewDevice => 'Вход с нового устройства';

  @override
  String get auditLogActionLogout => 'Выход выполнен';

  @override
  String get auditLogActionDeviceVerified => 'Устройство подтверждено';

  @override
  String get auditLogActionEmailChanged => 'Email изменён';

  @override
  String get auditLogActionPasswordReset => 'Пароль сброшен';

  @override
  String get auditLogActionVaultItemCreated => 'Пароль добавлен';

  @override
  String get auditLogActionVaultItemUpdated => 'Пароль обновлён';

  @override
  String get auditLogActionVaultItemDeleted => 'Пароль удалён';

  @override
  String get auditLogUnknownAction => 'Неизвестное действие';

  @override
  String get auditLogEmpty => 'Активности пока нет';

  @override
  String auditLogEmptyCategory(String category) {
    return 'Нет записей в категории $category';
  }

  @override
  String get auditLogError => 'Ошибка';

  @override
  String get auditLogRetry => 'Повторить';

  @override
  String get supportTicketTitle => 'Поддержка';

  @override
  String get supportTicketMyTickets => 'Мои обращения';

  @override
  String get supportTicketNew => 'Новое обращение';

  @override
  String get supportTicketQuestion => 'Как мы можем помочь?';

  @override
  String get supportTicketCategoryLabel => 'Категория';

  @override
  String get supportTicketCategoryBug => 'Сообщение об ошибке';

  @override
  String get supportTicketCategorySuggestion => 'Предложение';

  @override
  String get supportTicketCategoryOther => 'Другое';

  @override
  String get supportTicketSubjectLabel => 'Тема';

  @override
  String get supportTicketSubjectError => 'Тема обязательна';

  @override
  String get supportTicketSubjectMinError => 'Не менее 5 символов';

  @override
  String get supportTicketMessageLabel => 'Ваше сообщение';

  @override
  String get supportTicketMessageError => 'Сообщение обязательно';

  @override
  String get supportTicketMessageMinError => 'Не менее 20 символов';

  @override
  String get supportTicketPriorityLabel => 'Приоритет';

  @override
  String get supportTicketPriorityLow => 'Низкий';

  @override
  String get supportTicketPriorityNormal => 'Обычный';

  @override
  String get supportTicketPriorityHigh => 'Высокий';

  @override
  String get supportTicketSubmitButton => 'Отправить';

  @override
  String get supportTicketStatusOpen => 'Открыто';

  @override
  String get supportTicketStatusInProgress => 'В работе';

  @override
  String get supportTicketStatusClosed => 'Закрыто';

  @override
  String get supportTicketAdminReply => 'Ответ поддержки';

  @override
  String get supportTicketWaitingReply => 'Ожидание ответа...';

  @override
  String get supportTicketReplied => 'Получен ответ';

  @override
  String get supportTicketWaitingReplyLong => 'Ожидание ответа';

  @override
  String get supportTicketSuccess => 'Ваше обращение отправлено';

  @override
  String get supportTicketError => 'Произошла ошибка';

  @override
  String get supportTicketLoadingError => 'Не удалось загрузить обращения';

  @override
  String get supportTicketLoadingRetry => 'Повторить';

  @override
  String get supportTicketDetailMessage => 'Ваше сообщение';

  @override
  String get supportTicketDeleteConfirmTitle => 'Удалить запрос?';

  @override
  String get supportTicketDeleteConfirmMessage =>
      'Этот запрос поддержки будет удалён без возможности восстановления.';

  @override
  String get supportTicketDeleteCancel => 'Отмена';

  @override
  String get supportTicketDeleteConfirm => 'Удалить';

  @override
  String get supportTicketDeleteSuccess => 'Запрос удалён';

  @override
  String get forceUpdateTitle => 'Требуется обновление';

  @override
  String get forceUpdateDescription =>
      'Эта версия больше не поддерживается.\nПожалуйста, обновите приложение для продолжения.';

  @override
  String get forceUpdateCurrentVersion => 'Текущая версия';

  @override
  String get forceUpdateMinimumVersion => 'Требуемая версия';

  @override
  String get forceUpdateButton => 'Обновить';

  @override
  String get forceUpdateButtonResume => 'Продолжить';

  @override
  String forceUpdateDownloading(int progress) {
    return 'Загрузка... %$progress';
  }

  @override
  String forceUpdateError(String error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String forceUpdateInstallError(String error) {
    return 'Не удалось запустить установку: $error';
  }

  @override
  String get forceUpdatePermissionTitle => 'Требуется разрешение';

  @override
  String get forceUpdatePermissionContent =>
      'Для установки APK необходимо разрешение «Установка из неизвестных источников».\n\nНастройки → Приложения → DeniKey → Установка из неизвестных источников → Разрешить\n\nПосле предоставления разрешения нажмите «Обновить» снова.';

  @override
  String get forceUpdatePermissionOpenSettings => 'Открыть настройки';

  @override
  String get forceUpdatePermissionUnderstand => 'Понятно';

  @override
  String get navBarSupport => 'Поддержка';

  @override
  String get navBarLibrary => 'Библиотека';

  @override
  String get navBarVault => 'Мой сейф';

  @override
  String get navBarGenerator => 'Генератор';

  @override
  String get navBarSettings => 'Настройки';

  @override
  String get desktopOnboardingTitle => 'Горячие клавиши';

  @override
  String get desktopOnboardingDescription =>
      'Попробуйте эти сочетания клавиш для более быстрой работы с DeniKey.';

  @override
  String get desktopOnboardingShortcut1 => 'Мой сейф / Библиотека / Настройки';

  @override
  String get desktopOnboardingShortcut2 => 'Добавить новый пароль';

  @override
  String get desktopOnboardingShortcut3 => 'Поиск';

  @override
  String get desktopOnboardingShortcut4 => 'Генератор паролей';

  @override
  String get desktopOnboardingShortcut5 => 'Переключение между вкладками';

  @override
  String get desktopOnboardingShortcut6 => 'Назад / закрыть';

  @override
  String get desktopOnboardingButton => 'Понятно';

  @override
  String get splashSubtitle => 'Нулевое знание · Полная безопасность';

  @override
  String get settingsAutoLockUnlimited => 'Без ограничений';

  @override
  String settingsAutoLockMinutesChip(int minutes) {
    return '$minutes мин';
  }

  @override
  String settingsClipboardSecondsChip(int seconds) {
    return '$seconds сек';
  }

  @override
  String get settingsClipboardUnlimited => 'Без ограничений';

  @override
  String get settingsDeviceJustNow => 'Только что';

  @override
  String settingsDeviceMinutesAgo(int minutes) {
    return '$minutes мин. назад';
  }

  @override
  String settingsDeviceHoursAgo(int hours) {
    return '$hours ч. назад';
  }

  @override
  String settingsDeviceDaysAgo(int days) {
    return '$days дн. назад';
  }

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingClose => 'Закрыть';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в DeniKey';

  @override
  String get onboardingWelcomeSubtitle =>
      'Ваши пароли, карты и цифровые удостоверения в одном безопасном месте — только в ваших руках.';

  @override
  String get onboardingChipZeroKnowledge => 'Нулевое знание';

  @override
  String get onboardingChipMultiPlatform => 'Мультиплатформа';

  @override
  String get onboardingChipSync => 'Мгновенная синхронизация';

  @override
  String get onboardingVaultTitle => 'Хранилище хранит всё';

  @override
  String get onboardingVaultSubtitle =>
      'Пароли, карты, заметки и пользовательские поля. Копируйте одним касанием, скрывайте поля по желанию.';

  @override
  String get onboardingVaultActionCopy => 'Копировать';

  @override
  String get onboardingVaultActionShow => 'Показать';

  @override
  String get onboardingVaultActionEdit => 'Изменить';

  @override
  String get onboardingVaultMockBankCard => 'Банковская карта';

  @override
  String get onboardingChipQuickAdd => 'Быстрое добавление';

  @override
  String get onboardingChipFavorites => 'Избранное';

  @override
  String get onboardingChipHiddenField => 'Скрытое поле';

  @override
  String get onboardingChipTrash => 'Корзина';

  @override
  String get onboardingLibraryCategorySocialMedia => 'Соц. сети';

  @override
  String get onboardingLibraryCategoryWork => 'Работа';

  @override
  String get onboardingChipCustomize => 'Настроить';

  @override
  String get onboardingGeneratorTitle => 'Создавайте надёжные пароли';

  @override
  String get onboardingGeneratorSubtitle =>
      'Создавайте невзламываемые пароли одним касанием — выбирайте длину, регистр, цифры и специальные символы.';

  @override
  String get onboardingGeneratorSectionLabel => 'Генератор паролей';

  @override
  String get onboardingGeneratorStrengthLabel => 'Сила:';

  @override
  String get onboardingGeneratorStrengthVeryStrong => 'Очень надёжный';

  @override
  String onboardingGeneratorLengthOption(int n) {
    return 'Длина: $n';
  }

  @override
  String get onboardingChipRefresh => 'Обновить';

  @override
  String get onboardingSecurityTitle => 'Полный контроль в ваших руках';

  @override
  String get onboardingSecuritySubtitle =>
      'Управляйте безопасностью с биометрией, автоблокировкой, блокировкой устройств и журналом аудита.';

  @override
  String get onboardingSecurityBiometric => 'Биометрия';

  @override
  String get onboardingSecurityBiometricDesc =>
      'Быстрый доступ по отпечатку пальца';

  @override
  String get onboardingSecurityAutoLock => 'Автоблокировка';

  @override
  String get onboardingSecurityAutoLockDesc =>
      'Блокировка по таймауту или потере фокуса';

  @override
  String get onboardingSecurityDeviceManagement => 'Управление устройствами';

  @override
  String get onboardingSecurityDeviceManagementDesc =>
      'Просмотр и отзыв сессий';

  @override
  String get onboardingSecurityAuditLog => 'Журнал аудита';

  @override
  String get onboardingSecurityAuditLogDesc => 'Отслеживайте каждое действие';

  @override
  String get onboardingSecurityZeroKnowledgeTitle =>
      'Архитектура нулевого знания';

  @override
  String get onboardingSecurityZeroKnowledgeDesc =>
      'Ваш мастер-пароль никогда не отправляется на сервер.';

  @override
  String get onboardingReadyTitle => 'Готовы начать?';

  @override
  String get onboardingReadySubtitle =>
      'Создайте аккаунт или войдите. Безопасность больше не сложна.';

  @override
  String get onboardingReplayTitle => 'Вы всё вспомнили!';

  @override
  String get onboardingReplaySubtitle =>
      'По вопросам свяжитесь с нами через Настройки → Поддержка.';

  @override
  String get onboardingSummaryZeroKnowledge =>
      'Нулевое знание — данные только ваши';

  @override
  String get onboardingSummaryAddPassword =>
      'Хранилище → добавляйте и управляйте паролями';

  @override
  String get onboardingSummaryGenerator => 'Создавайте надёжные пароли';

  @override
  String get onboardingSummaryBiometric => 'Быстрый вход с биометрией';

  @override
  String get vaultItemUntitled => 'Без названия';

  @override
  String get vaultItemDetailFallbackTitle => 'Детали';

  @override
  String get categoriesUncategorized => 'Без категории';

  @override
  String get networkError => 'Не удалось подключиться к серверу';

  @override
  String get addItemTypeCreateTitle => 'Создать новый тип';

  @override
  String get addItemTypeFieldsLabel => 'Поля';

  @override
  String get onboardingCategoriesTitle => 'Организуй с категориями';

  @override
  String get onboardingCategoriesSubtitle =>
      'Группируй пароли по папкам. Папка «Без категории» всегда на месте и не может быть удалена.';

  @override
  String get onboardingCategoriesDefault => 'Без категории';

  @override
  String get onboardingCategoriesDefaultLock =>
      'Нельзя удалить или переименовать';

  @override
  String get onboardingCategoriesChipDefault => 'Папка по умолчанию';

  @override
  String get onboardingCategoriesChipCustom => 'Свои категории';

  @override
  String get onboardingCategoriesChipOrganize => 'Упорядочить';

  @override
  String get onboardingTypesTitle => 'Ускорься с шаблонами';

  @override
  String get onboardingTypesSubtitle =>
      'Определи группы полей один раз. Они будут готовы при каждом добавлении нового пароля.';

  @override
  String get onboardingTypesWithout => 'Без типа';

  @override
  String get onboardingTypesWith => 'С типом';

  @override
  String get onboardingTypesChipTemplate => 'Шаблон';

  @override
  String get onboardingTypesChipSpeed => 'Быстрое сохранение';

  @override
  String get onboardingTypesChipCustomize => 'Настроить';

  @override
  String get notifAutoLockTitle => 'DeniKey заблокирован';

  @override
  String get notifAutoLockBody =>
      'Автоблокировка активирована. Введите мастер-пароль для продолжения.';

  @override
  String get notifNewDeviceTitle => 'Вход с нового устройства';

  @override
  String get notifNewDeviceBody =>
      'Новое устройство пытается получить доступ к вашему аккаунту. Если это не вы, немедленно смените пароль.';

  @override
  String get notifChannelName => 'Уведомления DeniKey';

  @override
  String get notifChannelDesc =>
      'Напоминания безопасности и важные уведомления';

  @override
  String get biometricFaceLabel => 'Разблокировать с Face ID';

  @override
  String get biometricFingerprintLabel => 'Разблокировать по отпечатку';

  @override
  String get biometricPinLabel => 'Разблокировать с PIN-кодом';

  @override
  String get biometricReason => 'Подтвердите личность для доступа к DeniKey';

  @override
  String get shortcutSupport => 'Служба поддержки';

  @override
  String get shortcutVault => 'Перейти в хранилище';

  @override
  String get shortcutLibrary => 'Перейти в библиотеку';

  @override
  String get shortcutSettings => 'Перейти в настройки';

  @override
  String get shortcutNewPassword => 'Добавить новый пароль';

  @override
  String get shortcutSearch => 'Поиск';

  @override
  String get shortcutGenerator => 'Генератор паролей';

  @override
  String get shortcutNewPasswordVault => 'Новый пароль (экран хранилища)';

  @override
  String get shortcutTabSwitch => 'Переключение между вкладками';

  @override
  String get shortcutBack => 'Назад';

  @override
  String get authLoadingLogin => 'Выполняется вход...';

  @override
  String get authLoadingRegister => 'Создание аккаунта...';

  @override
  String get authErrorLogin => 'Ошибка входа.';

  @override
  String get authErrorRegister => 'Ошибка регистрации.';

  @override
  String get vaultLoadingVault => 'Загрузка хранилища...';

  @override
  String get vaultLoadingSaving => 'Сохранение...';

  @override
  String get vaultLoadingUpdating => 'Обновление...';

  @override
  String get vaultLoadingDeleting => 'Удаление...';

  @override
  String get vaultLoadingMoving => 'Перемещение...';

  @override
  String vaultLoadingDeletingCount(int count) {
    return 'Удаление $count записей...';
  }

  @override
  String get vaultErrorTimeout => 'Сервер не отвечает. Попробуйте ещё раз.';

  @override
  String get vaultErrorLoad => 'Не удалось загрузить.';

  @override
  String get vaultErrorOffline => 'Нет подключения к интернету.';

  @override
  String get vaultSampleTitle => 'Образец записи DeniKey';

  @override
  String get vaultSampleNotes =>
      'Это автоматически созданная образцовая запись. Вы можете удалить её после добавления своих данных.';

  @override
  String get errorCouldNotLoad => 'Не удалось загрузить';

  @override
  String get errorCouldNotCreate => 'Не удалось создать';

  @override
  String get errorCouldNotUpdate => 'Не удалось обновить';

  @override
  String get errorCouldNotDelete => 'Не удалось удалить';

  @override
  String get offlineTitle =>
      'К сожалению, без интернета вы не можете получить доступ к DeniKey';

  @override
  String get offlineMessage =>
      'Не волнуйтесь, это не проблема. Ваш аккаунт и содержимое в безопасности. Полный доступ вернётся, когда вы снова подключитесь к интернету.';

  @override
  String get addItemFieldNameRequired => 'Это поле обязательно для заполнения';

  @override
  String get totpSettingsTitle => 'Защита Authenticator';

  @override
  String get totpSettingsActiveDesc =>
      'При каждом входе потребуется код из приложения';

  @override
  String get totpSettingsInactiveDesc =>
      'Дополнительный код при входе не требуется';

  @override
  String get totpSetupTitle => 'Настройка защиты Authenticator';

  @override
  String get totpSetupStep1 => '1. Отсканируйте QR-код';

  @override
  String get totpSetupStep1Desc =>
      'Отсканируйте QR-код ниже с помощью Google Authenticator, Authy или аналогичного приложения.';

  @override
  String get totpSetupStep2 => '2. Введите код подтверждения';

  @override
  String get totpSetupStep2Desc =>
      'Введите 6-значный код из приложения для завершения настройки.';

  @override
  String get totpSetupManualKey => 'Ключ для ручного ввода';

  @override
  String get totpSetupActivate => 'Активировать';

  @override
  String get totpSetupLoadError => 'Не удалось загрузить данные настройки';

  @override
  String get totpSecretCopied => 'Ключ скопирован';

  @override
  String get totpCodeLabel => '6-значный код';

  @override
  String get totpInvalidCode => 'Неверный код, попробуйте ещё раз';

  @override
  String get totpEnabledSuccess => 'Защита Authenticator включена';

  @override
  String get totpVerifyTitle => 'Защита Authenticator';

  @override
  String get totpVerifyDesc =>
      'Введите 6-значный код из вашего приложения-аутентификатора.';

  @override
  String get totpVerifyButton => 'Подтвердить';

  @override
  String get totpDisableTitle => 'Отключить защиту';

  @override
  String get totpDisableDesc =>
      'Введите мастер-пароль и код аутентификатора для отключения защиты.';

  @override
  String get totpDisableMasterPasswordLabel => 'Мастер-пароль';

  @override
  String get totpDisableMasterPasswordError => 'Неверный мастер-пароль';

  @override
  String get totpDisableCodeLabel => 'Код аутентификатора';

  @override
  String get totpDisableCodeError => 'Неверный код аутентификатора';

  @override
  String get totpDisabledSuccess => 'Защита Authenticator отключена';

  @override
  String get totpDisableConfirm => 'Отключить';

  @override
  String get totpTrustDurationLabel => 'Частота проверки';

  @override
  String get totpTrustAlways => 'Каждый раз';

  @override
  String get totpTrust12h => '12 часов';

  @override
  String get totpTrust1d => '1 день';

  @override
  String get totpTrust7d => '7 дней';

  @override
  String get totpTrust30d => '30 дней';

  @override
  String get totpTrust60d => '60 дней';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';
}
