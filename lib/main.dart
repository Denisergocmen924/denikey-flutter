import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/auto_lock_provider.dart';
import 'core/notifications/notification_service.dart';
import 'core/presentation/loading_overlay.dart';
import 'core/presentation/app_shortcuts.dart';
import 'core/storage/secure_storage.dart';
import 'core/services/tray_service.dart';
import 'core/localization/l10n.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/presentation/offline_screen.dart';

// Tek instance kilidi için sabit port
const _kSingleInstancePort = 47821;
ServerSocket? _singleInstanceServer;
bool _windowReady = false;
bool _pendingShow = false;

Future<ServerSocket?> _acquireSingleInstanceLock() async {
  try {
    // Bu port'u bind edebildiysek → ilk instance'ız
    return await ServerSocket.bind(InternetAddress.loopbackIPv4, _kSingleInstancePort);
  } on SocketException {
    // Port zaten dolu → başka instance var, onu uyar ve çık
    try {
      final socket = await Socket.connect(
        InternetAddress.loopbackIPv4,
        _kSingleInstancePort,
        timeout: const Duration(seconds: 2),
      );
      socket.write('show');
      await socket.flush();
      await socket.close();
    } catch (_) {}
    return null;
  }
}

void _listenForSecondInstance() {
  _singleInstanceServer?.listen((client) {
    client.listen(
      (_) {
        if (_windowReady) {
          windowManager.show();
          windowManager.focus();
        } else {
          _pendingShow = true;
        }
        client.destroy();
      },
      onError: (_) => client.destroy(),
    );
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    _singleInstanceServer = await _acquireSingleInstanceLock();
    if (_singleInstanceServer == null) {
      // Başka instance var, o pencereyi öne getirdi, bu process çıkıyor
      exit(0);
    }
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
      // windowManager hazır olduktan sonra listener'ı başlat
      _windowReady = true;
      if (_pendingShow) {
        _pendingShow = false;
        await windowManager.show();
        await windowManager.focus();
      }
      _listenForSecondInstance();
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

class _MyAppState extends ConsumerState<MyApp> with WindowListener, WidgetsBindingObserver {
  bool _wasBlurred = false;
  DateTime? _blurTime;
  Timer? _boundsTimer;

  @override
  void initState() {
    super.initState();
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      windowManager.addListener(this);
    } else {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    _boundsTimer?.cancel();
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      windowManager.removeListener(this);
    } else {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  void _saveWindowBounds() {
    _boundsTimer?.cancel();
    _boundsTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final size  = await windowManager.getSize();
        final pos   = await windowManager.getPosition();
        final prefs = await SharedPreferences.getInstance();
        prefs.setDouble('win_w', size.width);
        prefs.setDouble('win_h', size.height);
        prefs.setDouble('win_x', pos.dx);
        prefs.setDouble('win_y', pos.dy);
      } catch (_) {}
    });
  }

  @override
  void onWindowResize() => _saveWindowBounds();

  @override
  void onWindowMove() => _saveWindowBounds();

  // Android / iOS yaşam döngüsü
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasBlurred = true;
      _blurTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _onResume();
    }
  }

  Future<void> _onResume() async {
    if (!_wasBlurred) return;
    _wasBlurred = false;
    final autoLock = ref.read(autoLockProvider);
    if (!autoLock.enabled) return;
    final token = await SecureStorage.instance.getToken();
    if (token == null) return;
    if (!mounted) return;
    final location = ref.read(routerProvider)
        .routerDelegate.currentConfiguration.uri.toString();
    if (location == '/splash' || location == '/login' ||
        location == '/register' || location == '/lock' ||
        location == '/master-lock') {
      return;
    }
    if (autoLock.minutes != null && _blurTime != null) {
      final elapsed = DateTime.now().difference(_blurTime!).inMinutes;
      if (elapsed < autoLock.minutes!) return;
    }
    if (autoLock.minutes != null) {
      NotificationService.instance.showAutoLockNotification();
    }
    ref.read(routerProvider).go('/master-lock');
  }

  @override
  void onWindowClose() async {
    if (!Platform.isWindows) return;
    await TrayService.instance.destroy();
    exit(0);
  }

  @override
  void onWindowBlur() {
    _wasBlurred = true;
    _blurTime = DateTime.now();
  }

  @override
  void onWindowFocus() => _onResume();

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'DeniKey',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      locale: locale,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        L10n.update(AppLocalizations.of(context));
        return Consumer(
          builder: (context, ref, _) {
            final isOffline = ref.watch(connectivityProvider).valueOrNull ?? false;
            if (isOffline) return const OfflineScreen();
            return LoadingOverlay(
              key: loadingOverlayKey,
              child: AppShortcuts(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
