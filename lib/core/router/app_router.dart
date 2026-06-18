import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/master_lock_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/auth/presentation/change_email_screen.dart';
import '../../features/auth/presentation/confirm_email_change_screen.dart';
import '../../features/auth/presentation/settings_screen.dart';
import '../../features/vault/presentation/vault_screen.dart';
import '../../features/vault/presentation/vault_item_detail_screen.dart';
import '../../features/vault/presentation/search_screen.dart';
import '../../features/categories/presentation/library_screen.dart';
import '../../features/vault/presentation/add_vault_item_screen.dart';
import '../../features/categories/presentation/category_detail_screen.dart';
import '../../features/password_generator/presentation/password_generator_screen.dart';
import '../../features/audit_log/presentation/audit_log_screen.dart';
import '../../features/support_ticket/presentation/support_ticket_screen.dart';
import '../../features/trash/presentation/trash_screen.dart';
import '../presentation/splash_screen.dart';
import '../presentation/force_update_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/privacy_policy_screen.dart';
import '../../features/auth/presentation/device_banned_screen.dart';
import '../../features/auth/presentation/totp_setup_screen.dart';
import '../../features/auth/presentation/totp_verify_login_screen.dart';
import '../../features/auth/presentation/totp_verify_unlock_screen.dart';

const _publicPaths = {
  '/splash', '/login', '/register', '/verify-email',
  '/onboarding',
  '/privacy-policy', '/device-banned', '/force-update',
  '/totp-verify-login',
};

// Fade + hafif yukarı kayma — ana ekranlar arası geçiş
Page<void> _fadePage(LocalKey key, Widget child) => CustomTransitionPage(
  key: key,
  child: child,
  transitionDuration: const Duration(milliseconds: 220),
  reverseTransitionDuration: const Duration(milliseconds: 180),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  },
);

// Aşağıdan yukarı kayma — detay / modal ekranlar
Page<void> _slideUpPage(LocalKey key, Widget child) => CustomTransitionPage(
  key: key,
  child: child,
  transitionDuration: const Duration(milliseconds: 280),
  reverseTransitionDuration: const Duration(milliseconds: 220),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    return SlideTransition(position: slide, child: child);
  },
);

final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final loc = state.matchedLocation;
    if (_publicPaths.contains(loc)) return null;
    final token = await SecureStorage.instance.getToken();
    if (token == null) return '/login';
    if (loc == '/master-lock') return null;
    final masterKey = await SecureStorage.instance.getMasterKey();
    if (masterKey == null) return '/master-lock';
    return null;
  },
  routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/force-update',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return ForceUpdateScreen(
            currentVersion: extra['current'] ?? '',
            minimumVersion: extra['minimum'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          OnboardingScreen(isReplay: state.extra as bool? ?? false),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/master-lock',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          const MasterLockScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _fadePage(
            state.pageKey,
            VerifyEmailScreen(
              userId: extra['user_id'],
              email: extra['email'],
              purpose: extra['purpose'] ?? 'register',
              masterPassword: extra['master_password'],
              emailVerifyToken: extra['email_verify_token'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/vault',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          const VaultScreen(),
        ),
        routes: [
          GoRoute(
            path: 'detail',
            pageBuilder: (context, state) {
              final item = state.extra as Map<String, dynamic>;
              return _slideUpPage(
                state.pageKey,
                VaultItemDetailScreen(item: item),
              );
            },
          ),
          GoRoute(
            path: 'add',
            pageBuilder: (context, state) => _slideUpPage(
              state.pageKey,
              const AddVaultItemScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/add-item',
        pageBuilder: (context, state) => _slideUpPage(
          state.pageKey,
          const AddVaultItemScreen(),
        ),
      ),
      GoRoute(
        path: '/categories',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          const LibraryScreen(),
        ),
        routes: [
          GoRoute(
            path: 'detail',
            pageBuilder: (context, state) {
              final cat = state.extra as Map<String, dynamic>;
              return _slideUpPage(
                state.pageKey,
                CategoryDetailScreen(category: cat),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/change-email',
        pageBuilder: (context, state) => _slideUpPage(
          state.pageKey,
          const ChangeEmailScreen(),
        ),
      ),
      GoRoute(
        path: '/confirm-email-change',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _slideUpPage(
            state.pageKey,
            ConfirmEmailChangeScreen(newEmail: extra['new_email'] as String),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/password-generator',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          const PasswordGeneratorScreen(),
        ),
      ),
      GoRoute(
        path: '/audit-log',
        pageBuilder: (context, state) => _slideUpPage(
          state.pageKey,
          const AuditLogScreen(),
        ),
      ),
      GoRoute(
        path: '/support-ticket',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          const SupportTicketScreen(),
        ),
      ),
      GoRoute(
        path: '/lock',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          const MasterLockScreen(),
        ),
      ),
      GoRoute(
        path: '/trash',
        pageBuilder: (context, state) => _slideUpPage(
          state.pageKey,
          const TrashScreen(),
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => _slideUpPage(
          state.pageKey,
          const SearchScreen(),
        ),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/device-banned',
        builder: (context, state) => const DeviceBannedScreen(),
      ),
      GoRoute(
        path: '/totp-setup',
        pageBuilder: (context, state) => _slideUpPage(
          state.pageKey,
          const TotpSetupScreen(),
        ),
      ),
      GoRoute(
        path: '/totp-verify-login',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          const TotpVerifyLoginScreen(),
        ),
      ),
      GoRoute(
        path: '/totp-verify-unlock',
        pageBuilder: (context, state) => _fadePage(
          state.pageKey,
          const TotpVerifyUnlockScreen(),
        ),
      ),
    ],
);

final routerProvider = Provider<GoRouter>((ref) => router);
