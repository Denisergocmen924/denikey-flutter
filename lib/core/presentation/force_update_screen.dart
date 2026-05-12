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

class _ForceUpdateScreenState extends State<ForceUpdateScreen>
    with WidgetsBindingObserver {
  static const _onyx   = Color(0xFF090C08);
  static const _orange = Color(0xFFFF5900);
  static const _cream  = Color(0xFFE8EDE9);
  static const _muted  = Color(0xFF9BABA4);
  static const _green  = Color(0xFF4CAF50);

  bool _downloading          = false;
  bool _isPaused             = false;
  double _progress           = 0;
  String? _error;
  int _androidSdk            = 0;
  bool _hasInstallPermission = false;
  CancelToken? _cancelToken;
  int _downloadedBytes       = 0;
  String? _savePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid) _loadAndroidSdk();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _downloading) {
      _pauseDownload();
    } else if (state == AppLifecycleState.resumed) {
      if (Platform.isAndroid && _androidSdk >= 26) _checkInstallPermission();
      if (_isPaused) _resumeDownload();
    }
  }

  Future<void> _loadAndroidSdk() async {
    final info = await DeviceInfoPlugin().androidInfo;
    if (!mounted) return;
    setState(() => _androidSdk = info.version.sdkInt);
    if (_androidSdk >= 26) _checkInstallPermission();
  }

  Future<void> _checkInstallPermission() async {
    final status = await Permission.requestInstallPackages.status;
    if (mounted) setState(() => _hasInstallPermission = status.isGranted);
  }

  String get _installPath {
    if (Platform.isWindows) {
      return File(Platform.resolvedExecutable).parent.path;
    }
    return '';
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
      _downloading     = true;
      _isPaused        = false;
      _downloadedBytes = 0;
      _progress        = 0;
      _error           = null;
    });

    await _startDownload();
  }

  Future<void> _startDownload() async {
    final l10n = AppLocalizations.of(context);
    try {
      final dir      = await getTemporaryDirectory();
      final fileName = Platform.isAndroid ? 'DeniKey-Update.apk' : 'DeniKey-Setup.exe';
      _savePath = '${dir.path}/$fileName';

      if (_downloadedBytes == 0) {
        final existing = File(_savePath!);
        if (await existing.exists()) await existing.delete();
      }

      _cancelToken = CancelToken();

      final response = await Dio().get<ResponseBody>(
        _downloadUrl,
        cancelToken: _cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: true,
          maxRedirects: 5,
          headers: _downloadedBytes > 0
              ? {'Range': 'bytes=$_downloadedBytes-'}
              : null,
        ),
      );

      final contentLength = int.tryParse(
        response.headers.value('content-length') ?? '',
      ) ?? 0;
      final totalBytes = _downloadedBytes + contentLength;

      final sink = File(_savePath!).openWrite(
        mode: _downloadedBytes > 0 ? FileMode.append : FileMode.write,
      );

      await for (final chunk in response.data!.stream) {
        sink.add(chunk);
        _downloadedBytes += chunk.length;
        if (mounted && totalBytes > 0) {
          setState(() => _progress = _downloadedBytes / totalBytes);
        }
      }

      await sink.flush();
      await sink.close();

      if (!mounted) return;
      setState(() => _downloading = false);

      if (Platform.isAndroid) {
        final result = await OpenFile.open(_savePath!);
        if (result.type == ResultType.done) {
          exit(0);
        } else {
          setState(() => _error = l10n.forceUpdateInstallError(result.message));
        }
      } else if (Platform.isWindows) {
        await Process.start(_savePath!, ['/SILENT', '/TASKS=']);
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = l10n.forceUpdateError(e.message ?? e.toString());
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = l10n.forceUpdateError(e.toString());
        });
      }
    }
  }

  void _pauseDownload() {
    _cancelToken?.cancel('paused');
    if (mounted) {
      setState(() {
        _isPaused    = true;
        _downloading = false;
      });
    }
  }

  void _resumeDownload() {
    if (!mounted) return;
    setState(() {
      _isPaused    = false;
      _downloading = true;
    });
    _startDownload();
  }

  void _showInstallPermissionDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.forceUpdatePermissionTitle),
        content: Text(l10n.forceUpdatePermissionContent),
        actions: [
          if (_androidSdk >= 26)
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
    final l10n        = AppLocalizations.of(context);
    final isAndroid26 = Platform.isAndroid && _androidSdk >= 26;
    final buttonColor = isAndroid26 && _hasInstallPermission ? _green : _orange;

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

                if (Platform.isWindows) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_outlined, size: 12, color: _muted),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _installPath,
                          style: const TextStyle(fontSize: 11, color: _muted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

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
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(
                        _isPaused
                            ? Icons.play_arrow_outlined
                            : Icons.download_outlined,
                      ),
                      label: Text(
                        _isPaused ? l10n.forceUpdateButtonResume : l10n.forceUpdateButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: _isPaused ? _resumeDownload : _update,
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
