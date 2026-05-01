import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/master_lock_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
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

final router = GoRouter(
  initialLocation: '/splash',
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
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/master-lock',
        builder: (context, state) => const MasterLockScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return VerifyEmailScreen(
            userId: extra['user_id'],
            email: extra['email'],
            purpose: extra['purpose'] ?? 'register',
            masterPassword: extra['master_password'],
          );
        },
      ),
      GoRoute(
        path: '/vault',
        builder: (context, state) => const VaultScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final item = state.extra as Map<String, dynamic>;
              return VaultItemDetailScreen(item: item);
            },
          ),
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddVaultItemScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/add-item',
        builder: (context, state) => const AddVaultItemScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const LibraryScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final cat = state.extra as Map<String, dynamic>;
              return CategoryDetailScreen(category: cat);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            userId: extra['user_id'] as String? ?? '',
            email: extra['email'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/change-email',
        builder: (context, state) => const ChangeEmailScreen(),
      ),
      GoRoute(
        path: '/confirm-email-change',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ConfirmEmailChangeScreen(newEmail: extra['new_email'] as String);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/password-generator',
        builder: (context, state) => const PasswordGeneratorScreen(),
      ),
      GoRoute(
        path: '/audit-log',
        builder: (context, state) => const AuditLogScreen(),
      ),
      GoRoute(
        path: '/support-ticket',
        builder: (context, state) => const SupportTicketScreen(),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const MasterLockScreen(),
      ),
      GoRoute(
        path: '/trash',
        builder: (context, state) => const TrashScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
);

final routerProvider = Provider<GoRouter>((ref) => router);

