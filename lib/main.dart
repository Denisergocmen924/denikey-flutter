import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/auto_lock_provider.dart';
import 'core/notifications/notification_service.dart';
import 'core/presentation/loading_overlay.dart';
import 'core/presentation/app_shortcuts.dart';
import 'core/storage/secure_storage.dart';
import 'core/services/tray_service.dart';

// Tek instance kilidi için sabit port
const _kSingleInstancePort = 47821;

Future<ServerSocket?> _acquireSingleInstanceLock() async {
  try {
    // Bu port'u bind edebildiysek → ilk instance'ız
    return await ServerSocket.bind(InternetAddress.loopbackIPv4, _kSingleInstancePort);
  } on SocketException {
    // Port zaten dolu → başka instance var, onu uyar ve çık
    try {
      final socket = await Socket.connect(InternetAddress.loopbackIPv4, _kSingleInstancePort,
          timeout: const Duration(seconds: 1));
      socket.write('show');
      await socket.flush();
      await socket.close();
    } catch (_) {}
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    final server = await _acquireSingleInstanceLock();
    if (server == null) {
      // Başka instance var, o pencereyi öne getirdi, bu process çıkıyor
      exit(0);
    }
    // Gelen 'show' mesajlarını dinle (başka instance tetiklediğinde)
    server.listen((client) {
      client.listen((_) {
        windowManager.show();
        windowManager.focus();
        client.destroy();
      });
    });
  }

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await windowManager.ensureInitialized();
    const options = WindowOptions(
      backgroundColor: Color(0xFF090C08),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'DeniKey',
    );

    final prefs = await SharedPreferences.getInstance();
    final savedX = prefs.getDouble('win_x');
    final savedY = prefs.getDouble('win_y');
    final savedW = prefs.getDouble('win_w');
    final savedH = prefs.getDouble('win_h');

    await windowManager.waitUntilReadyToShow(options, () async {
      if (savedW != null && savedH != null) {
        await windowManager.setSize(Size(savedW, savedH));
        if (savedX != null && savedY != null) {
          await windowManager.setPosition(Offset(savedX, savedY));
        }
        await windowManager.show();
        await windowManager.focus();
      } else {
        await windowManager.show();
        await Future.delayed(const Duration(milliseconds: 150));
        await windowManager.maximize();
        await windowManager.focus();
      }
    });

    if (Platform.isWindows) {
      await windowManager.setPreventClose(true);
      await TrayService.instance.init();
    }
  }
  await NotificationService.instance.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

const _onyxBlack  = Color(0xFF090C08);
const _jetBlack   = Color(0xFF223841);
const _blazeOrange = Color(0xFFFF5900);

ThemeData _buildTheme(Brightness brightness) {
  final seed = ColorScheme.fromSeed(
    seedColor: _blazeOrange,
    brightness: brightness,
  );

  final ColorScheme cs;
  if (brightness == Brightness.dark) {
    cs = seed.copyWith(
      surface:                   _onyxBlack,
      surfaceContainerLowest:    const Color(0xFF050705),
      surfaceContainerLow:       const Color(0xFF111410),
      surfaceContainer:          const Color(0xFF181C1A),
      surfaceContainerHigh:      const Color(0xFF1E2830),
      surfaceContainerHighest:   _jetBlack,
      onSurface:                 const Color(0xFFE8EDE9),
      onSurfaceVariant:          const Color(0xFF9BABA4),
      outline:                   const Color(0xFF455550),
      outlineVariant:            const Color(0xFF2A3530),
      primary:                   _blazeOrange,
      onPrimary:                 Colors.white,
      primaryContainer:          const Color(0xFF6B2800),
      onPrimaryContainer:        const Color(0xFFFFDBCC),
      secondary:                 _jetBlack,
      onSecondary:               const Color(0xFFE8EDE9),
      secondaryContainer:        const Color(0xFF2E4550),
      onSecondaryContainer:      const Color(0xFFD0E4EC),
      error:                     const Color(0xFFFF6B4A),
      onError:                   Colors.white,
    );
  } else {
    cs = seed.copyWith(
      surface:     const Color(0xFFF5F5F2),
      onSurface:   _onyxBlack,
      primary:     _blazeOrange,
      onPrimary:   Colors.white,
      primaryContainer: const Color(0xFFFFDDD0),
      onPrimaryContainer: const Color(0xFF4A1800),
    );
  }

  return ThemeData(
    colorScheme: cs,
    useMaterial3: true,
    scaffoldBackgroundColor: cs.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cs.outlineVariant),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        backgroundColor: _blazeOrange,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: cs.onSurface,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      backgroundColor: brightness == Brightness.dark
          ? _jetBlack
          : cs.surfaceContainerHighest,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorColor: _blazeOrange.withAlpha(40),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _blazeOrange);
        }
        return IconThemeData(color: cs.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: _blazeOrange, fontSize: 12, fontWeight: FontWeight.w600);
        }
        return TextStyle(color: cs.onSurfaceVariant, fontSize: 12);
      }),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WindowListener {
  bool _wasBlurred = false;
  DateTime? _blurTime;

  @override
  void initState() {
    super.initState();
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowClose() async {
    if (!Platform.isWindows) return;
    // Boyut ve pozisyonu kaydet, sonra tamamen kapat
    final size = await windowManager.getSize();
    final pos = await windowManager.getPosition();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('win_w', size.width);
    await prefs.setDouble('win_h', size.height);
    await prefs.setDouble('win_x', pos.dx);
    await prefs.setDouble('win_y', pos.dy);
    await TrayService.instance.destroy();
    await windowManager.destroy();
  }

  @override
  void onWindowBlur() {
    _wasBlurred = true;
    _blurTime = DateTime.now();
  }

  @override
  void onWindowFocus() async {
    if (!_wasBlurred) return;
    _wasBlurred = false;
    final autoLock = ref.read(autoLockProvider);
    if (!autoLock.enabled) return;
    final token = await SecureStorage.instance.getToken();
    if (token == null) return;
    if (!mounted) return;
    // Splash veya login ekranındaysa kilitleme
    final location = ref.read(routerProvider).state.uri.toString();
    if (location == '/splash' || location == '/login' ||
        location == '/register' || location == '/lock') {
      return;
    }
    // Süre kontrolü: minutes null ise süresiz → her zaman kilitle
    if (autoLock.minutes != null && _blurTime != null) {
      final elapsed = DateTime.now().difference(_blurTime!).inMinutes;
      if (elapsed < autoLock.minutes!) return;
    }
    ref.read(routerProvider).go('/master-lock');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'DeniKey',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => LoadingOverlay(
        key: loadingOverlayKey,
        child: AppShortcuts(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
