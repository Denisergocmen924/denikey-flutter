import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/api_constants.dart';

class ForceUpdateScreen extends StatelessWidget {
  final String currentVersion;
  final String minimumVersion;

  const ForceUpdateScreen({
    super.key,
    required this.currentVersion,
    required this.minimumVersion,
  });

  static const _onyx   = Color(0xFF090C08);
  static const _orange = Color(0xFFFF5900);
  static const _cream  = Color(0xFFE8EDE9);
  static const _muted  = Color(0xFF9BABA4);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _onyx,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // İkon
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _orange, width: 2),
                    color: _orange.withAlpha(20),
                  ),
                  child: const Icon(
                    Icons.system_update_outlined,
                    size: 44,
                    color: _orange,
                  ),
                ),

                const SizedBox(height: 32),

                // Başlık
                const Text(
                  'Güncelleme Gerekli',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _cream,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Açıklama
                const Text(
                  'Bu sürüm artık desteklenmiyor.\nDevam etmek için lütfen uygulamayı güncelleyin.',
                  style: TextStyle(
                    fontSize: 15,
                    color: _muted,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Versiyon bilgisi kutusu
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                    color: Colors.white.withAlpha(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _VersionBadge(
                        label: 'Mevcut sürüm',
                        version: currentVersion,
                        color: Colors.redAccent,
                      ),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _VersionBadge(
                        label: 'Gerekli sürüm',
                        version: minimumVersion,
                        color: Colors.greenAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Güncelle butonu
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.download_outlined),
                    label: const Text(
                      'Güncelle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () => launchUrl(
                      Uri.parse(ApiConstants.releasesPage),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Alt not
                const Text(
                  'Bu bir hata değildir.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _muted,
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  final String label;
  final String version;
  final Color color;

  const _VersionBadge({
    required this.label,
    required this.version,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9BABA4)),
        ),
        const SizedBox(height: 4),
        Text(
          'v$version',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
