import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isReplay;
  const OnboardingScreen({super.key, this.isReplay = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  static const _orange  = Color(0xFFFF5900);
  static const _muted   = Color(0xFF9BABA4);
  static const _border  = Color(0xFF1E2820);

  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (!widget.isReplay) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
    }
    if (!mounted) return;
    if (widget.isReplay) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  void _next() {
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == 5;
    return Scaffold(
      backgroundColor: _kOnyx,
      body: SafeArea(
        child: Column(
          children: [
            // Üst bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sayfa sayacı
                  Text(
                    '${_currentPage + 1} / 6',
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                  // Atla
                  if (!isLast)
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Atla',
                          style: TextStyle(color: _muted, fontSize: 14)),
                    )
                  else
                    const SizedBox(width: 60),
                ],
              ),
            ),

            // Sayfalar
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(pulseCtrl: _pulseCtrl),
                  const _VaultPage(),
                  const _LibraryPage(),
                  const _GeneratorPage(),
                  const _SecurityPage(),
                  _ReadyPage(isReplay: widget.isReplay),
                ],
              ),
            ),

            // Nokta göstergesi
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: active ? _orange : _border,
                    ),
                  );
                }),
              ),
            ),

            // İleri / Başla butonu
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 8),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLast ? _finish : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isLast
                        ? (widget.isReplay ? 'Kapat' : 'Başla')
                        : 'İleri',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),

            if (!widget.isReplay)
              TextButton(
                onPressed: () => context.push('/privacy-policy'),
                child: const Text(
                  'Gizlilik Politikası',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF9BABA4),
                  ),
                ),
              ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─── RENK SABİTLERİ (tüm sayfa widget'larında kullanılır) ───────────────────

const _kOnyx   = Color(0xFF090C08);
const _kOrange = Color(0xFFFF5900);
const _kMuted  = Color(0xFF9BABA4);
const _kCream  = Color(0xFFE8EDE9);
const _kCard   = Color(0xFF131A16);
const _kBorder = Color(0xFF1E2820);
const _kGreen  = Color(0xFF4CAF50);

// ─── YARDIMCI WİDGET'LAR ────────────────────────────────────────────────────

class _PageShell extends StatelessWidget {
  final Widget visual;
  final String title;
  final String subtitle;
  final List<_FeatureChip> chips;

  const _PageShell({
    required this.visual,
    required this.title,
    required this.subtitle,
    this.chips = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Görsel alan
          Expanded(flex: 5, child: Center(child: visual)),
          // Metin
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _kCream,
                    letterSpacing: -0.4,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _kMuted,
                    height: 1.6,
                  ),
                ),
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: chips,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    const c = _kOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: c.withAlpha(20),
        border: Border.all(color: c.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MockCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;

  const _MockCard({required this.children, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

// ─── SAYFA 1: HOŞ GELDİNİZ ──────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final AnimationController pulseCtrl;
  const _WelcomePage({required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      visual: AnimatedBuilder(
        animation: pulseCtrl,
        builder: (_, __) {
          final glow = pulseCtrl.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Dış halka
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _kOrange.withAlpha((30 + (glow * 40)).toInt()),
                    width: 1.5,
                  ),
                ),
              ),
              // İç halka
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _kOrange.withAlpha((60 + (glow * 60)).toInt()),
                    width: 1.5,
                  ),
                  color: _kOrange.withAlpha((10 + (glow * 10).toInt())),
                ),
              ),
              // Merkez
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCard,
                  border: Border.all(color: _kOrange.withAlpha(120), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _kOrange.withAlpha((30 + (glow * 40).toInt())),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.shield_rounded, size: 48, color: _kOrange),
              ),
            ],
          );
        },
      ),
      title: 'DeniKey\'e Hoş Geldiniz',
      subtitle: 'Şifreleriniz, kartlarınız ve dijital kimlikleriniz tek bir güvenli yerde — yalnızca sizin elinizde.',
      chips: const [
        _FeatureChip(icon: Icons.lock_outline, label: 'Sıfır Bilgi'),
        _FeatureChip(icon: Icons.devices_outlined, label: 'Çok Platform'),
        _FeatureChip(icon: Icons.sync_outlined, label: 'Anlık Senkron'),
      ],
    );
  }
}

// ─── SAYFA 2: KASAM ─────────────────────────────────────────────────────────

class _VaultPage extends StatelessWidget {
  const _VaultPage();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      visual: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MockCard(children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _kOrange.withAlpha(30),
                ),
                child: const Icon(Icons.language_outlined, size: 18, color: _kOrange),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instagram', style: TextStyle(color: _kCream, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('kullanici@email.com', style: TextStyle(color: _kMuted, fontSize: 11)),
                ],
              )),
              const Icon(Icons.star_rounded, size: 16, color: _kOrange),
            ]),
            const SizedBox(height: 10),
            Container(height: 1, color: _kBorder),
            const SizedBox(height: 10),
            Row(children: [
              _MiniTag(icon: Icons.copy_outlined, label: 'Kopyala'),
              const SizedBox(width: 6),
              _MiniTag(icon: Icons.visibility_outlined, label: 'Göster'),
              const SizedBox(width: 6),
              _MiniTag(icon: Icons.edit_outlined, label: 'Düzenle'),
            ]),
          ]),
          const SizedBox(height: 10),
          _MockCard(children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF1565C0).withAlpha(40),
                ),
                child: const Icon(Icons.credit_card_outlined, size: 18, color: Color(0xFF42A5F5)),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Banka Kartı', style: TextStyle(color: _kCream, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('•••• •••• •••• 4242', style: TextStyle(color: _kMuted, fontSize: 11)),
                ],
              )),
            ]),
          ]),
        ],
      ),
      title: 'Kasanız Her Şeyi Saklar',
      subtitle: 'Şifreler, kartlar, notlar ve özel alanlar. Tek dokunuşla kopyalayın, gizli alanları isteğe göre maskeleyin.',
      chips: const [
        _FeatureChip(icon: Icons.add_circle_outline, label: 'Hızlı Ekle'),
        _FeatureChip(icon: Icons.star_outline, label: 'Favoriler'),
        _FeatureChip(icon: Icons.lock_outline, label: 'Gizli Alan'),
        _FeatureChip(icon: Icons.delete_outline, label: 'Çöp Kutusu'),
      ],
    );
  }
}

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: _kBorder,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: _kMuted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: _kMuted, fontSize: 10)),
      ]),
    );
  }
}

// ─── SAYFA 3: KÜTÜPHANE ─────────────────────────────────────────────────────

class _LibraryPage extends StatelessWidget {
  const _LibraryPage();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      visual: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(child: _CategoryCard(
              icon: Icons.language_outlined,
              label: 'Sosyal Medya',
              count: '4 şifre',
              color: _kOrange,
            )),
            const SizedBox(width: 10),
            Expanded(child: _CategoryCard(
              icon: Icons.account_balance_outlined,
              label: 'Bankacılık',
              count: '2 şifre',
              color: const Color(0xFF42A5F5),
            )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _CategoryCard(
              icon: Icons.work_outline,
              label: 'İş',
              count: '6 şifre',
              color: const Color(0xFF66BB6A),
            )),
            const SizedBox(width: 10),
            Expanded(child: _CategoryCard(
              icon: Icons.devices_outlined,
              label: 'Cihazlar',
              count: '3 şifre',
              color: const Color(0xFFAB47BC),
            )),
          ]),
          const SizedBox(height: 10),
          _MockCard(padding: const EdgeInsets.all(12), children: [
            const Row(children: [
              Icon(Icons.grid_view_outlined, size: 14, color: _kOrange),
              SizedBox(width: 6),
              Text('Öğe Türleri', style: TextStyle(color: _kCream, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            const Text(
              'Kredi Kartı, Kimlik, SSH Anahtarı, Wi-Fi ve daha fazlası...',
              style: TextStyle(color: _kMuted, fontSize: 11),
            ),
          ]),
        ],
      ),
      title: 'Organize Edin',
      subtitle: 'Kategorilerle şifrelerinizi düzenleyin. Öğe türleri ile kredi kartı, kimlik belgesi ve daha fazlasını saklayın.',
      chips: const [
        _FeatureChip(icon: Icons.folder_outlined, label: 'Kategoriler'),
        _FeatureChip(icon: Icons.extension_outlined, label: 'Öğe Türleri'),
        _FeatureChip(icon: Icons.add_box_outlined, label: 'Özelleştir'),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withAlpha(25),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: _kCream, fontSize: 12, fontWeight: FontWeight.w600)),
        Text(count, style: const TextStyle(color: _kMuted, fontSize: 10)),
      ]),
    );
  }
}

// ─── SAYFA 4: ŞİFRE ÜRETİCİ ─────────────────────────────────────────────────

class _GeneratorPage extends StatelessWidget {
  const _GeneratorPage();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      visual: _MockCard(children: [
        const Row(children: [
          Icon(Icons.auto_fix_high_outlined, size: 16, color: _kOrange),
          SizedBox(width: 6),
          Text('Şifre Üretici', style: TextStyle(color: _kOrange, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        // Üretilen şifre
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _kOnyx,
            border: Border.all(color: _kOrange.withAlpha(60)),
          ),
          child: const Text(
            'Kx#9mP\$vL2@nQr',
            style: TextStyle(
              color: _kCream,
              fontSize: 15,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Güç göstergesi
        const Row(children: [
          Text('Güç:', style: TextStyle(color: _kMuted, fontSize: 11)),
          SizedBox(width: 6),
          Text('Çok Güçlü', style: TextStyle(color: _kGreen, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: 0.92,
            minHeight: 6,
            backgroundColor: _kBorder,
            valueColor: const AlwaysStoppedAnimation(_kGreen),
          ),
        ),
        const SizedBox(height: 14),
        // Seçenekler
        Wrap(spacing: 6, runSpacing: 6, children: const [
          _OptionChip(label: 'Uzunluk: 16'),
          _OptionChip(label: 'A-Z'),
          _OptionChip(label: 'a-z'),
          _OptionChip(label: '0-9'),
          _OptionChip(label: '!@#\$', active: true),
        ]),
      ]),
      title: 'Güçlü Şifreler Üretin',
      subtitle: 'Uzunluk, büyük/küçük harf, rakam ve özel karakter seçenekleriyle tek tıkta kırılması zor şifreler oluşturun.',
      chips: const [
        _FeatureChip(icon: Icons.tune_outlined, label: 'Özelleştir'),
        _FeatureChip(icon: Icons.copy_outlined, label: 'Kopyala'),
        _FeatureChip(icon: Icons.refresh_outlined, label: 'Yenile'),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool active;
  const _OptionChip({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: active ? _kOrange.withAlpha(30) : _kBorder,
        border: Border.all(color: active ? _kOrange.withAlpha(80) : Colors.transparent),
      ),
      child: Text(label, style: TextStyle(
        color: active ? _kOrange : _kMuted,
        fontSize: 11,
        fontWeight: active ? FontWeight.w600 : FontWeight.normal,
      )),
    );
  }
}

// ─── SAYFA 5: GÜVENLİK ──────────────────────────────────────────────────────

class _SecurityPage extends StatelessWidget {
  const _SecurityPage();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      visual: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(child: _SecurityTile(
              icon: Icons.fingerprint_rounded,
              label: 'Biyometrik',
              desc: 'Parmak izi ile hızlı erişim',
              color: _kOrange,
            )),
            const SizedBox(width: 10),
            Expanded(child: _SecurityTile(
              icon: Icons.lock_clock_outlined,
              label: 'Otomatik Kilit',
              desc: 'Süre veya odak kaybıyla kilitle',
              color: const Color(0xFF42A5F5),
            )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _SecurityTile(
              icon: Icons.devices_outlined,
              label: 'Cihaz Yönetimi',
              desc: 'Oturumları görüntüle ve sonlandır',
              color: const Color(0xFF66BB6A),
            )),
            const SizedBox(width: 10),
            Expanded(child: _SecurityTile(
              icon: Icons.history_edu_outlined,
              label: 'Denetim Kaydı',
              desc: 'Her işlemi takip et',
              color: const Color(0xFFAB47BC),
            )),
          ]),
          const SizedBox(height: 10),
          _MockCard(padding: const EdgeInsets.all(12), children: [
            const Row(children: [
              Icon(Icons.verified_user_outlined, size: 14, color: _kOrange),
              SizedBox(width: 6),
              Text('Sıfır Bilgi Mimarisi', style: TextStyle(color: _kCream, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            const Text(
              'Master şifreniz hiçbir zaman sunucuya gönderilmez.',
              style: TextStyle(color: _kMuted, fontSize: 11),
            ),
          ]),
        ],
      ),
      title: 'Tam Kontrol Sizde',
      subtitle: 'Parmak izi, otomatik kilit, cihaz yasaklama ve denetim kaydı ile güvenliğinizi her açıdan yönetin.',
      chips: const [
        _FeatureChip(icon: Icons.shield_outlined, label: 'AES-256-GCM'),
        _FeatureChip(icon: Icons.key_outlined, label: 'Argon2id'),
      ],
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;

  const _SecurityTile({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: _kCream, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(color: _kMuted, fontSize: 10, height: 1.4)),
      ]),
    );
  }
}

// ─── SAYFA 6: HAZIR ─────────────────────────────────────────────────────────

class _ReadyPage extends StatelessWidget {
  final bool isReplay;
  const _ReadyPage({required this.isReplay});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      visual: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kCard,
              border: Border.all(color: _kOrange.withAlpha(100), width: 2),
              boxShadow: [
                BoxShadow(color: _kOrange.withAlpha(40), blurRadius: 30, spreadRadius: 4),
              ],
            ),
            child: const Icon(Icons.rocket_launch_rounded, size: 50, color: _kOrange),
          ),
          const SizedBox(height: 24),
          // Özet kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Column(children: [
              _SummaryRow(icon: Icons.shield_rounded, text: 'Sıfır bilgi — veriler yalnızca sizin'),
              const Divider(height: 16, color: _kBorder),
              _SummaryRow(icon: Icons.add_circle_outline, text: 'Kasam → şifre ekle ve yönet'),
              const Divider(height: 16, color: _kBorder),
              _SummaryRow(icon: Icons.auto_fix_high_outlined, text: 'Güçlü şifreler üret'),
              const Divider(height: 16, color: _kBorder),
              _SummaryRow(icon: Icons.fingerprint_rounded, text: 'Biyometrik ile hızlı giriş'),
            ]),
          ),
        ],
      ),
      title: isReplay ? 'Her Şeyi Hatırladınız!' : 'Başlamaya Hazır mısınız?',
      subtitle: isReplay
          ? 'Sorularınız için Ayarlar → Destek Talebi kısmından bize ulaşabilirsiniz.'
          : 'Hesap oluşturun ya da giriş yapın. Güvenlik artık karmaşık değil.',
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SummaryRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: _kOrange),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(color: _kCream, fontSize: 12))),
    ]);
  }
}
