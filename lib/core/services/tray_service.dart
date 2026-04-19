import 'dart:io';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as path;

class TrayService with TrayListener {
  TrayService._();
  static final instance = TrayService._();

  Future<void> init() async {
    if (!Platform.isWindows) return;
    trayManager.addListener(this);

    final iconPath = path.join(
      path.dirname(Platform.resolvedExecutable),
      'data',
      'flutter_assets',
      'assets',
      'icon',
      'denikey_logo.png',
    );

    await trayManager.setIcon(iconPath);
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(key: 'show', label: 'DeniKey\'i Aç'),
      MenuItem.separator(),
      MenuItem(key: 'exit', label: 'Çıkış'),
    ]));
  }

  void dispose() {
    trayManager.removeListener(this);
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        windowManager.show();
        windowManager.focus();
      case 'exit':
        trayManager.destroy();
        windowManager.destroy();
    }
  }
}
