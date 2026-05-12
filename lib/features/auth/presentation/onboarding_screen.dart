import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

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
  bool _canAdvance = true;

  static const _orange  = Color(0xFFFF5900);
  static const _muted   = Color(0xFF9BABA4);
  static const _border  = Color(0xFF1E2820);

  late final AnimationController _pulseCtrl;
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _pulseCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _triggerShake() {
    HapticFeedback.mediumImpact();
    _shakeCtrl.forward(from: 0);
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

  void _prev() {
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (!_canAdvance) return;
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLast = _currentPage == 6;
    return Scaffold(
      backgroundColor: _kOnyx,
      body: SafeArea(
        child: Column(
          children: [
            // Üst bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: _muted, size: 18),
                      onPressed: _prev,
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  Text(
                    '${_currentPage + 1} / 7',
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Sayfalar
            Expanded(
              child: AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeAnim.value, 0),
                  child: child,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragEnd: (details) {
                    if (!_canAdvance) _triggerShake();
                  },
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) {
                      setState(() {
                        _currentPage = i;
                        _canAdvance = false;
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted && _currentPage == i) {
                          setState(() => _canAdvance = true);
                        }
                      });
                    },
                    children: [
                      _WelcomePage(pulseCtrl: _pulseCtrl),
                      const _VaultPage(),
                      const _CategoriesPage(),
                      const _TypesPage(),
                      const _GeneratorPage(),
                      const _SecurityPage(),
                      _ReadyPage(isReplay: widget.isReplay),
                    ],
                  ),
                ),
              ),
            ),

            // Nokta göstergesi
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (i) {
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
                  onPressed: isLast ? _finish : (_canAdvance ? _next : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    disabledBackgroundColor: _orange.withAlpha(100),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isLast
                        ? (widget.isReplay ? l10n.onboardingClose : l10n.onboardingStart)
                        : l10n.onboardingNext,
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
                child: Text(
                  l10n.privacyPolicyTitle,
                  style: const TextStyle(
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
          Expanded(flex: 5, child: Center(child: visual)),
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
    final l10n = AppLocalizations.of(context);
    return _PageShell(
      visual: AnimatedBuilder(
        animation: pulseCtrl,
        builder: (context, child) {
          final glow = pulseCtrl.value;
          return Stack(
            alignment: Alignment.center,
            children: [
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
      title: l10n.onboardingWelcomeTitle,
      subtitle: l10n.onboardingWelcomeSubtitle,
      chips: [
        _FeatureChip(icon: Icons.lock_outline, label: l10n.onboardingChipZeroKnowledge),
        _FeatureChip(icon: Icons.devices_outlined, label: l10n.onboardingChipMultiPlatform),
        _FeatureChip(icon: Icons.sync_outlined, label: l10n.onboardingChipSync),
      ],
    );
  }
}

// ─── SAYFA 2: KASAM ─────────────────────────────────────────────────────────

class _VaultPage extends StatelessWidget {
  const _VaultPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              _MiniTag(icon: Icons.copy_outlined, label: l10n.onboardingVaultActionCopy),
              const SizedBox(width: 6),
              _MiniTag(icon: Icons.visibility_outlined, label: l10n.onboardingVaultActionShow),
              const SizedBox(width: 6),
              _MiniTag(icon: Icons.edit_outlined, label: l10n.onboardingVaultActionEdit),
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
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.onboardingVaultMockBankCard, style: const TextStyle(color: _kCream, fontSize: 13, fontWeight: FontWeight.w600)),
                  const Text('•••• •••• •••• 4242', style: TextStyle(color: _kMuted, fontSize: 11)),
                ],
              )),
            ]),
          ]),
        ],
      ),
      title: l10n.onboardingVaultTitle,
      subtitle: l10n.onboardingVaultSubtitle,
      chips: [
        _FeatureChip(icon: Icons.add_circle_outline, label: l10n.onboardingChipQuickAdd),
        _FeatureChip(icon: Icons.star_outline, label: l10n.onboardingChipFavorites),
        _FeatureChip(icon: Icons.lock_outline, label: l10n.onboardingChipHiddenField),
        _FeatureChip(icon: Icons.delete_outline, label: l10n.onboardingChipTrash),
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

// ─── SAYFA 3: KATEGORİLER ────────────────────────────────────────────────────

class _CategoriesPage extends StatelessWidget {
  const _CategoriesPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PageShell(
      visual: _MockCard(
        padding: const EdgeInsets.all(0),
        children: [
          // Sistem kategorisi — kilitli
          _FolderRow(
            icon: Icons.inbox_outlined,
            color: const Color(0xFF888780),
            label: l10n.onboardingCategoriesDefault,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xFFFF5900).withAlpha(20),
                    border: Border.all(
                        color: const Color(0xFFFF5900).withAlpha(60)),
                  ),
                  child: Text(
                    l10n.onboardingCategoriesDefaultLock,
                    style: const TextStyle(
                        color: Color(0xFFFF5900),
                        fontSize: 9,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.lock_outline, size: 14, color: Color(0xFF888780)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E2820)),
          // Örnek kullanıcı kategorileri
          _FolderRow(
            icon: Icons.work_outline,
            color: const Color(0xFF854F0B),
            label: l10n.onboardingLibraryCategoryWork,
            trailing: const Icon(Icons.chevron_right, size: 14, color: Color(0xFF9BABA4)),
          ),
          const Divider(height: 1, color: Color(0xFF1E2820)),
          _FolderRow(
            icon: Icons.language_outlined,
            color: const Color(0xFF534AB7),
            label: l10n.onboardingLibraryCategorySocialMedia,
            trailing: const Icon(Icons.chevron_right, size: 14, color: Color(0xFF9BABA4)),
          ),
          const Divider(height: 1, color: Color(0xFF1E2820)),
          // Yeni ekle butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: _kOrange.withAlpha(20),
                    border: Border.all(color: _kOrange.withAlpha(60)),
                  ),
                  child: const Icon(Icons.add, size: 16, color: _kOrange),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.addItemCreateCategory,
                  style: const TextStyle(
                      color: _kOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      title: l10n.onboardingCategoriesTitle,
      subtitle: l10n.onboardingCategoriesSubtitle,
      chips: [
        _FeatureChip(icon: Icons.lock_outline, label: l10n.onboardingCategoriesChipDefault),
        _FeatureChip(icon: Icons.folder_outlined, label: l10n.onboardingCategoriesChipCustom),
        _FeatureChip(icon: Icons.sort_outlined, label: l10n.onboardingCategoriesChipOrganize),
      ],
    );
  }
}

class _FolderRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Widget trailing;

  const _FolderRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: color.withAlpha(30),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  color: _kCream, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ─── SAYFA 4: TİPLER ────────────────────────────────────────────────────────

class _TypesPage extends StatefulWidget {
  const _TypesPage();

  @override
  State<_TypesPage> createState() => _TypesPageState();
}

class _TypesPageState extends State<_TypesPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PageShell(
      visual: Row(
        children: [
          // Sol: tipsiz
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.onboardingTypesWithout,
                    style: const TextStyle(
                        color: _kMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _MockCard(
                  padding: const EdgeInsets.all(10),
                  children: [
                    _EmptyFieldHint(),
                    const SizedBox(height: 6),
                    _EmptyFieldHint(),
                    const SizedBox(height: 6),
                    _EmptyFieldHint(),
                    const SizedBox(height: 8),
                    Container(
                      height: 26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFF1E2820)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 12, color: _kMuted),
                          const SizedBox(width: 4),
                          Text(l10n.addItemAddFieldButton,
                              style: const TextStyle(
                                  color: _kMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Sağ: tip seçilince
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.onboardingTypesWith,
                    style: const TextStyle(
                        color: _kOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                // Tip kartı
                FadeTransition(
                  opacity: _fade,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _kOrange.withAlpha(20),
                      border:
                          Border.all(color: _kOrange.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 14, color: _kOrange),
                        const SizedBox(width: 6),
                        const Text('Giriş Bilgileri',
                            style: TextStyle(
                                color: _kOrange,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                _MockCard(
                  padding: const EdgeInsets.all(10),
                  children: [
                    FadeTransition(
                        opacity: _fade,
                        child: _FilledFieldHint('Kullanıcı Adı')),
                    const SizedBox(height: 6),
                    FadeTransition(
                        opacity: _fade,
                        child: _FilledFieldHint('Şifre', isSecret: true)),
                    const SizedBox(height: 6),
                    FadeTransition(
                        opacity: _fade, child: _FilledFieldHint('Not')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      title: l10n.onboardingTypesTitle,
      subtitle: l10n.onboardingTypesSubtitle,
      chips: [
        _FeatureChip(icon: Icons.extension_outlined, label: l10n.onboardingTypesChipTemplate),
        _FeatureChip(icon: Icons.bolt_outlined, label: l10n.onboardingTypesChipSpeed),
        _FeatureChip(icon: Icons.tune_outlined, label: l10n.onboardingTypesChipCustomize),
      ],
    );
  }
}

class _EmptyFieldHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFF1A2020),
        border: Border.all(color: const Color(0xFF1E2820)),
      ),
    );
  }
}

class _FilledFieldHint extends StatelessWidget {
  final String label;
  final bool isSecret;
  const _FilledFieldHint(this.label, {this.isSecret = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFF1A2020),
        border: Border.all(color: _kOrange.withAlpha(60)),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(color: _kMuted, fontSize: 10)),
          const Spacer(),
          if (isSecret)
            const Icon(Icons.visibility_off_outlined,
                size: 12, color: _kMuted),
        ],
      ),
    );
  }
}

// ─── SAYFA 4: ŞİFRE ÜRETİCİ ─────────────────────────────────────────────────

class _GeneratorPage extends StatelessWidget {
  const _GeneratorPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PageShell(
      visual: _MockCard(children: [
        Row(children: [
          const Icon(Icons.auto_fix_high_outlined, size: 16, color: _kOrange),
          const SizedBox(width: 6),
          Text(l10n.onboardingGeneratorSectionLabel,
              style: const TextStyle(color: _kOrange, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
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
        Row(children: [
          Text(l10n.onboardingGeneratorStrengthLabel,
              style: const TextStyle(color: _kMuted, fontSize: 11)),
          const SizedBox(width: 6),
          Text(l10n.onboardingGeneratorStrengthVeryStrong,
              style: const TextStyle(color: _kGreen, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: const LinearProgressIndicator(
            value: 0.92,
            minHeight: 6,
            backgroundColor: _kBorder,
            valueColor: AlwaysStoppedAnimation(_kGreen),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(spacing: 6, runSpacing: 6, children: [
          _OptionChip(label: l10n.onboardingGeneratorLengthOption(16)),
          const _OptionChip(label: 'A-Z'),
          const _OptionChip(label: 'a-z'),
          const _OptionChip(label: '0-9'),
          const _OptionChip(label: '!@#\$', active: true),
        ]),
      ]),
      title: l10n.onboardingGeneratorTitle,
      subtitle: l10n.onboardingGeneratorSubtitle,
      chips: [
        _FeatureChip(icon: Icons.tune_outlined, label: l10n.onboardingChipCustomize),
        _FeatureChip(icon: Icons.copy_outlined, label: l10n.onboardingVaultActionCopy),
        _FeatureChip(icon: Icons.refresh_outlined, label: l10n.onboardingChipRefresh),
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
    final l10n = AppLocalizations.of(context);
    return _PageShell(
      visual: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(child: _SecurityTile(
              icon: Icons.fingerprint_rounded,
              label: l10n.onboardingSecurityBiometric,
              desc: l10n.onboardingSecurityBiometricDesc,
              color: _kOrange,
            )),
            const SizedBox(width: 10),
            Expanded(child: _SecurityTile(
              icon: Icons.lock_clock_outlined,
              label: l10n.onboardingSecurityAutoLock,
              desc: l10n.onboardingSecurityAutoLockDesc,
              color: const Color(0xFF42A5F5),
            )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _SecurityTile(
              icon: Icons.devices_outlined,
              label: l10n.onboardingSecurityDeviceManagement,
              desc: l10n.onboardingSecurityDeviceManagementDesc,
              color: const Color(0xFF66BB6A),
            )),
            const SizedBox(width: 10),
            Expanded(child: _SecurityTile(
              icon: Icons.history_edu_outlined,
              label: l10n.onboardingSecurityAuditLog,
              desc: l10n.onboardingSecurityAuditLogDesc,
              color: const Color(0xFFAB47BC),
            )),
          ]),
          const SizedBox(height: 10),
          _MockCard(padding: const EdgeInsets.all(12), children: [
            Row(children: [
              const Icon(Icons.verified_user_outlined, size: 14, color: _kOrange),
              const SizedBox(width: 6),
              Text(l10n.onboardingSecurityZeroKnowledgeTitle,
                  style: const TextStyle(color: _kCream, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Text(l10n.onboardingSecurityZeroKnowledgeDesc,
                style: const TextStyle(color: _kMuted, fontSize: 11)),
          ]),
        ],
      ),
      title: l10n.onboardingSecurityTitle,
      subtitle: l10n.onboardingSecuritySubtitle,
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
    final l10n = AppLocalizations.of(context);
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Column(children: [
              _SummaryRow(icon: Icons.shield_rounded, text: l10n.onboardingSummaryZeroKnowledge),
              const Divider(height: 16, color: _kBorder),
              _SummaryRow(icon: Icons.add_circle_outline, text: l10n.onboardingSummaryAddPassword),
              const Divider(height: 16, color: _kBorder),
              _SummaryRow(icon: Icons.auto_fix_high_outlined, text: l10n.onboardingSummaryGenerator),
              const Divider(height: 16, color: _kBorder),
              _SummaryRow(icon: Icons.fingerprint_rounded, text: l10n.onboardingSummaryBiometric),
            ]),
          ),
        ],
      ),
      title: isReplay ? l10n.onboardingReplayTitle : l10n.onboardingReadyTitle,
      subtitle: isReplay ? l10n.onboardingReplaySubtitle : l10n.onboardingReadySubtitle,
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
