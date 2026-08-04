// "Onyx & Ember" tasarım dilinin liste/içerik ekranları için ortak yapı taşları.
//
// Ekranlar renk, köşe yarıçapı ve gölge değerlerini elle yazmaz — buradan ve
// temadan alır. Aynı bileşen 8+ ekranda tekrar ettiği için kopyalamak yerine
// tek noktada tutulur; görsel dil değişince tek dosya güncellenir.

import 'package:flutter/material.dart';

/// Marka renkleri — tema `colorScheme` üzerinden de gelir, ancak vurgu
/// (accent) parametresi alan bileşenlerde doğrudan referans gerekir.
const kBlaze = Color(0xFFFF5900);
const kTeal = Color(0xFF24C9B5);

/// Duotone ikon kümesi — liste satırlarının ve başlıkların sol tarafındaki
/// yumuşak gradyanlı kare ikon.
class DuotoneIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const DuotoneIcon(
    this.icon, {
    super.key,
    this.color = kBlaze,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withAlpha(55), color.withAlpha(20)],
        ),
        borderRadius: BorderRadius.circular(size * 0.29),
        border: Border.all(color: color.withAlpha(55)),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

/// Liste satırı kartı — dolgulu yüzey, ince kenar, vurgulandığında renkli
/// kenarlık. Gölge kullanılmaz: uzun listelerde blur scroll jank'ine yol açar.
class AppListCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? accent;
  final EdgeInsets padding;

  const AppListCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.accent,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor =
        accent != null ? accent!.withAlpha(70) : cs.outlineVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cs.surfaceContainer,
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Boş durum — büyük duotone ikon + başlık + isteğe bağlı ipucu.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accent;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.accent = kBlaze,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DuotoneIcon(icon, color: accent, size: 84),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Hata durumu — boş durumla aynı iskelet, kırmızı vurgu + yeniden dene.
class AppErrorState extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppEmptyState(
      icon: Icons.error_outline,
      title: message,
      accent: cs.error,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh, size: 18),
        label: Text(retryLabel),
      ),
    );
  }
}

/// Bölüm başlığı — sıkı harf aralıklı, küçük puntolu, sönük renkli etiket.
class AppSectionTitle extends StatelessWidget {
  final String text;
  final Color accent;

  const AppSectionTitle(this.text, {super.key, this.accent = kBlaze});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Küçük durum rozeti — denetim kaydı / cihaz durumu gibi kısa etiketler.
class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const AppStatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: color,
        ),
      ),
    );
  }
}
