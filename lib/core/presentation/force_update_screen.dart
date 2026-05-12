import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/api_constants.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

class ForceUpdateScreen extends StatefulWidget {
  final String currentVersion;
  final String minimumVersion;

  const ForceUpdateScreen({
    super.key,
    required this.currentVersion,
    required this.minimumVersion,
  });

  @override
  State<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen> {
  static const _onyx   = Color(0xFF090C08);
  static const _orange = Color(0xFFFF5900);
  static const _cream  = Color(0xFFE8EDE9);
  static const _muted  = Color(0xFF9BABA4);

  bool _downloading = false;
  double _progress  = 0;
  String? _error;
  int _androidSdk   = 0;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) _loadAndroidSdk();
  }

  Future<void> _loadAndroidSdk() async {
    final info = await DeviceInfoPlugin().androidInfo;
    if (mounted) setState(() => _androidSdk = info.version.sdkInt);
  }

  String get _downloadUrl {
    final v = widget.minimumVersion;
    if (Platform.isAndroid) {
      return '${ApiConstants.releasesDownloadBase}/v$v/DeniKey-Android.apk';
    } else if (Platform.isWindows) {
      return '${ApiConstants.releasesDownloadBase}/v$v/DeniKey-Setup.exe';
    }
    return ApiConstants.releasesPage;
  }

  Future<void> _update() async {
    final l10n = AppLocalizations.of(context);

    if (Platform.isLinux) {
      await launchUrl(Uri.parse(ApiConstants.releasesPage), mode: LaunchMode.externalApplication);
      return;
    }

    if (Platform.isAndroid && _androidSdk >= 26) {
      final status = await Permission.requestInstallPackages.status;
      if (!status.isGranted) {
        if (mounted) _showInstallPermissionDialog();
        return;
      }
    }

    setState(() {
      _downloading = true;
      _progress    = 0;
      _error       = null;
    });

    try {
      final dir      = await getTemporaryDirectory();
      final fileName = Platform.isAndroid ? 'DeniKey-Update.apk' : 'DeniKey-Setup.exe';
      final savePath = '${dir.path}/$fileName';

      await Dio().download(
        _downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) setState(() => _progress = received / total);
        },
      );

      if (Platform.isAndroid) {
        final result = await OpenFile.open(savePath);
        if (result.type != ResultType.done) {
          setState(() => _error = l10n.forceUpdateInstallError(result.message));
        }
      } else if (Platform.isWindows) {
        final launched = await launchUrl(
          Uri.file(savePath),
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          setState(() => _error = l10n.forceUpdateInstallErrorFilePath(savePath));
        }
      }
    } catch (e) {
      setState(() => _error = l10n.forceUpdateError(e.toString()));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _showInstallPermissionDialog() {
    final l10n = AppLocalizations.of(context);
    final canOpenSettings = _androidSdk >= 26;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.forceUpdatePermissionTitle),
        content: Text(l10n.forceUpdatePermissionContent),
        actions: [
          if (canOpenSettings)
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await openAppSettings();
              },
              child: Text(l10n.forceUpdatePermissionOpenSettings),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.forceUpdatePermissionUnderstand),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

                Text(
                  l10n.forceUpdateTitle,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _cream,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  l10n.forceUpdateDescription,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _muted,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

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
                        label: l10n.forceUpdateCurrentVersion,
                        version: widget.currentVersion,
                        color: Colors.redAccent,
                      ),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _VersionBadge(
                        label: l10n.forceUpdateMinimumVersion,
                        version: widget.minimumVersion,
                        color: Colors.greenAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                if (_downloading) ...[
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(_orange),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.forceUpdateDownloading((_progress * 100).toInt()),
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                ] else ...[
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
                      label: Text(
                        l10n.forceUpdateButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: _update,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],

                const SizedBox(height: 16),

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
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9BABA4))),
        const SizedBox(height: 4),
        Text(
          'v$version',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}
