import 'dart:io';
import 'dart:async';
import 'dart:convert';
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
import 'core/localization/l10n.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/presentation/offline_screen.dart';

Future<void> _migrateSettingsFromLegacyPath(SharedPreferences prefs) async {
  if (prefs.getBool('settings_v2_migrated') == true) return;
  final home = Platform.environment['HOME'] ?? '';
  final oldFile = File('$home/.local/share/DeniKey/shared_preferences.json');
  if (oldFile.existsSync()) {
    try {
      final raw = await oldFile.readAsString();
      final old = Map<String, dynamic>.from(json.decode(raw) as Map);
      const stringKeys = ['theme_mode', 'app_locale'];
      const intKeys = ['clipboard_timeout_seconds', 'auto_lock_minutes'];
      const boolKeys = ['shortcuts_enabled'];
      for (final k in stringKeys) {
        if (!prefs.containsKey(k) && old.containsKey('flutter.$k')) {
          await prefs.setString(k, old['flutter.$k'] as String);
        }
      }
      for (final k in intKeys) {
        if (!prefs.containsKey(k) && old.containsKey('flutter.$k')) {
          await prefs.setInt(k, old['flutter.$k'] as int);
        }
      }
      for (final k in boolKeys) {
        if (!prefs.containsKey(k) && old.containsKey('flutter.$k')) {
          await prefs.setBool(k, old['flutter.$k'] as bool);
        }
      }
    } catch (_) {}
  }
  await prefs.setBool('settings_v2_migrated', true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux) {
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
    if (Platform.isLinux) await _migrateSettingsFromLegacyPath(prefs);
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

  }
  await NotificationService.instance.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

const _onyxBlack  = Color(0xFF090C08);
const _jetBlack   = Color(0xFF223841);
const _blazeOrange = Color(0xFFFF5900);
// Turuncuya karşıt soğuk vurgu — duotone glow ve ikincil aksanlar için
const _emberTeal  = Color(0xFF24C9B5);

ThemeData _buildTheme(Brightness brightness) {
  final seed = ColorScheme.fromSeed(
    seedColor: _blazeOrange,
    brightness: brightness,
  );

  final bool isDark = brightness == Brightness.dark;

  final ColorScheme cs;
  if (isDark) {
    cs = seed.copyWith(
      surface:                   _onyxBlack,
      surfaceContainerLowest:    const Color(0xFF050705),
      surfaceContainerLow:       const Color(0xFF101512),
      surfaceContainer:          const Color(0xFF161D1A),
      surfaceContainerHigh:      const Color(0xFF1D2A2C),
      surfaceContainerHighest:   _jetBlack,
      onSurface:                 const Color(0xFFEDF2EE),
      onSurfaceVariant:          const Color(0xFF9DAEA7),
      outline:                   const Color(0xFF3C4B47),
      outlineVariant:            const Color(0xFF27322E),
      primary:                   _blazeOrange,
      onPrimary:                 Colors.white,
      primaryContainer:          const Color(0xFF6B2800),
      onPrimaryContainer:        const Color(0xFFFFDBCC),
      secondary:                 _emberTeal,
      onSecondary:               const Color(0xFF00201C),
      secondaryContainer:        const Color(0xFF1F3A3C),
      onSecondaryContainer:      const Color(0xFFB6F0E6),
      tertiary:                  const Color(0xFFFFB59C),
      error:                     const Color(0xFFFF6B4A),
      onError:                   Colors.white,
    );
  } else {
    cs = seed.copyWith(
      surface:                   const Color(0xFFF7F6F3),
      surfaceContainerLowest:    Colors.white,
      surfaceContainerLow:       const Color(0xFFFFFFFF),
      surfaceContainer:          const Color(0xFFF1F0EC),
      surfaceContainerHigh:      const Color(0xFFEAE9E4),
      surfaceContainerHighest:   const Color(0xFFE4E3DD),
      onSurface:                 _onyxBlack,
      onSurfaceVariant:          const Color(0xFF5A645F),
      outline:                   const Color(0xFFC3C8C3),
      outlineVariant:            const Color(0xFFDEE2DD),
      primary:                   _blazeOrange,
      onPrimary:                 Colors.white,
      primaryContainer:          const Color(0xFFFFDDD0),
      onPrimaryContainer:        const Color(0xFF4A1800),
      secondary:                 const Color(0xFF0E8377),
      secondaryContainer:        const Color(0xFFB6F0E6),
      onSecondaryContainer:      const Color(0xFF00201C),
    );
  }

  // Tipografi hiyerarşisi — başlıklarda sıkı harf aralığı, gövdede ferah
  final base = ThemeData(brightness: brightness);
  final textTheme = base.textTheme.apply(
    bodyColor: cs.onSurface,
    displayColor: cs.onSurface,
  ).copyWith(
    displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1.0, color: cs.onSurface),
    headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: cs.onSurface),
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: cs.onSurface),
    titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: cs.onSurface),
    titleMedium: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: cs.onSurface),
    bodyLarge: TextStyle(fontSize: 15.5, height: 1.45, color: cs.onSurface),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: cs.onSurface),
    labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.1),
  );

  return ThemeData(
    colorScheme: cs,
    useMaterial3: true,
    textTheme: textTheme,
    scaffoldBackgroundColor: cs.surface,
    // InkRipple: shader derleme takılması yok, InkSparkle'dan hafif
    splashFactory: InkRipple.splashFactory,
    cardTheme: CardThemeData(
      elevation: 0,
      color: cs.surfaceContainer,
      shadowColor: Colors.black.withAlpha(isDark ? 120 : 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cs.outlineVariant),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 54)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _blazeOrange.withAlpha(90);
          }
          return _blazeOrange;
        }),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        overlayColor: WidgetStatePropertyAll(Colors.white.withAlpha(30)),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 0;
          return isDark ? 0 : 2;
        }),
        shadowColor: WidgetStatePropertyAll(_blazeOrange.withAlpha(110)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        foregroundColor: cs.onSurface,
        side: BorderSide(color: cs.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _blazeOrange,
        textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? cs.surfaceContainer : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      prefixIconColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.focused) ? _blazeOrange : cs.onSurfaceVariant),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) => TextStyle(
        color: states.contains(WidgetState.error)
            ? cs.error
            : states.contains(WidgetState.focused) ? _blazeOrange : cs.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      )),
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _blazeOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: cs.onSurface,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: cs.onSurface,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cs.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: cs.onSurface),
      contentTextStyle: TextStyle(fontSize: 14.5, height: 1.45, color: cs.onSurfaceVariant),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cs.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? const Color(0xFF1D2A2C) : _jetBlack,
      contentTextStyle: const TextStyle(color: Color(0xFFEDF2EE), fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainerHigh,
      side: BorderSide(color: cs.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface),
    ),
    dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 1),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      iconColor: cs.onSurfaceVariant,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _blazeOrange,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 2,
      extendedTextStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF11181A) : cs.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorColor: _blazeOrange.withAlpha(38),
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _blazeOrange, size: 26);
        }
        return IconThemeData(color: cs.onSurfaceVariant, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: _blazeOrange, fontSize: 12, fontWeight: FontWeight.w700);
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
    if (Platform.isLinux) {
      windowManager.addListener(this);
    } else {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    _boundsTimer?.cancel();
    if (Platform.isLinux) {
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
        location == '/master-lock' || location == '/force-update' ||
        location == '/totp-verify-unlock') {
      return;
    }
    if (autoLock.minutes != null && _blurTime != null) {
      final elapsed = DateTime.now().difference(_blurTime!).inMinutes;
      if (elapsed < autoLock.minutes!) return;
    }
    if (autoLock.minutes != null) {
      NotificationService.instance.showAutoLockNotification();
    }
    // Masaüstünde biometric yok; kilit ekranında master password tekrar
    // girilip key yeniden türetilir. Residency'yi azaltmak için kasadan da sil.
    if (Platform.isLinux) {
      await SecureStorage.instance.deleteMasterKey();
    }
    ref.read(routerProvider).go('/master-lock');
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
