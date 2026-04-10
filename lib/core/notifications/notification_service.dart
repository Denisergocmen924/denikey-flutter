import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _lastReminderKey = 'last_security_reminder';

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

  /// Haftalık güvenlik hatırlatıcısı — son bildirimden 7 gün geçtiyse göster
  Future<void> scheduleWeeklySecurityReminder() async {
    if (!_isSupported) return;

    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_lastReminderKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const weekMs = 7 * 24 * 60 * 60 * 1000;

    if (now - lastMs < weekMs) return; // Henüz 7 gün geçmedi

    await _showNotification(
      id: 1001,
      title: 'DeniKey Güvenlik Hatırlatıcısı',
      body: 'Şifrelerinizi düzenli güncellemeniz güvenliğinizi artırır. '
          'Uzun süredir değiştirilmemiş şifrelerinizi kontrol edin.',
    );

    await prefs.setInt(_lastReminderKey, now);
  }

  /// Yeni cihaz girişi bildirimi
  Future<void> showNewDeviceAlert() async {
    if (!_isSupported) return;
    await _showNotification(
      id: 1002,
      title: 'Yeni Cihaz Girişi',
      body: 'Hesabınıza yeni bir cihazdan giriş denemesi var. '
          'Siz değilseniz şifrenizi hemen değiştirin.',
    );
  }

  /// Anlık bildirim gönder
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'denikey_channel',
      'DeniKey Bildirimleri',
      channelDescription: 'Güvenlik hatırlatıcıları ve önemli bildirimler',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(id, title, body, details);
  }
}
