import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../localization/l10n.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // Linux'ta flutter_local_notifications desteği yok
  bool get _isSupported => Platform.isAndroid || Platform.isIOS;

  Future<void> initialize() async {
    if (!_isSupported) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );

    // Android 13+ izin iste
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Otomatik kilit bildirimi (sadece süre ile kilit açıksa)
  Future<void> showAutoLockNotification() async {
    if (!_isSupported) return;
    await _showNotification(
      id: 1003,
      title: L10n.s.notifAutoLockTitle,
      body: L10n.s.notifAutoLockBody,
    );
  }

  /// Yeni cihaz girişi bildirimi
  Future<void> showNewDeviceAlert() async {
    if (!_isSupported) return;
    await _showNotification(
      id: 1002,
      title: L10n.s.notifNewDeviceTitle,
      body: L10n.s.notifNewDeviceBody,
    );
  }

  /// Anlık bildirim gönder
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'denikey_channel',
      L10n.s.notifChannelName,
      channelDescription: L10n.s.notifChannelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(id, title, body, details);
  }
}
