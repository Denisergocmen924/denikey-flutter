import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/vault/presentation/vault_screen.dart';
import '../../features/vault/presentation/vault_item_detail_screen.dart';
import '../../features/categories/presentation/category_screen.dart';
import '../../features/vault/presentation/add_vault_item_screen.dart';
import '../../features/categories/presentation/category_detail_screen.dart';
import '../storage/secure_storage.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
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
        builder: (context, state) => const CategoryScreen(),
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
    ],
  );
});

// Splash: token var mı kontrol et, yönlendir
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await SecureStorage.instance.getToken();
    if (mounted) {
      if (token != null) {
        context.go('/vault');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
