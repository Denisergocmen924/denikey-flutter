import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  static const _onyx          = Color(0xFF090C08);
  static const _orange        = Color(0xFFFF5900);
  static const _textSecondary = Color(0xFF9BABA4);
  static const _cardBg        = Color(0xFF131A16);

  static const _pages = [
    _OnboardingPage(
      icon: Icons.shield_rounded,
      title: 'DeniKey\'e Hoş Geldiniz',
      description:
          'Şifreleriniz, kredi kartlarınız ve dijital kimlikleriniz artık tek bir güvenli yerde.',
    ),
    _OnboardingPage(
      icon: Icons.lock_person_rounded,
      title: 'Sıfır Bilgi Mimarisi',
      description:
          'Verileriniz cihazınızda şifrelenir. Sunucularımız şifrelerinizi hiçbir zaman göremez.',
    ),
    _OnboardingPage(
      icon: Icons.devices_rounded,
      title: 'Her Platformda Güvenlik',
      description:
          'Android, Windows ve Linux\'ta kesintisiz çalışır. Verileriniz her zaman yanınızda.',
    ),
    _OnboardingPage(
      icon: Icons.rocket_launch_rounded,
      title: 'Başlamaya Hazır mısınız?',
      description:
          'Hesap oluşturun ya da giriş yapın. Güvenlik artık karmaşık değil.',
      isLast: true,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    context.go('/login');
  }

  void _nextPage() {
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _onyx,
      body: SafeArea(
        child: Column(
          children: [
            // Atla butonu
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 20),
                child: _currentPage < _pages.length - 1
                    ? TextButton(
                        onPressed: _finish,
                        child: const Text(
                          'Atla',
                          style: TextStyle(color: _textSecondary, fontSize: 14),
                        ),
                      )
                    : const SizedBox(height: 44),
              ),
            ),

            // Sayfalar
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _PageContent(page: _pages[i]),
              ),
            ),

            // Nokta göstergesi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == _currentPage ? _orange : _cardBg,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // İleri / Başla butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _currentPage < _pages.length - 1 ? _nextPage : _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'İleri' : 'Başla',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Gizlilik politikası linki
            TextButton(
              onPressed: () => context.push('/privacy-policy'),
              child: const Text(
                'Gizlilik Politikası',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF9BABA4),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final bool isLast;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    this.isLast = false,
  });
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;

  const _PageContent({required this.page});

  static const _orange      = Color(0xFFFF5900);
  static const _textPrimary = Color(0xFFE8EDE9);
  static const _textSecondary = Color(0xFF9BABA4);
  static const _cardBg      = Color(0xFF131A16);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: _orange.withAlpha(60), width: 2),
            ),
            child: Icon(page.icon, size: 56, color: _orange),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: _textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
