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
      'denikey.ico',
    );

    await trayManager.setIcon(iconPath);
    await trayManager.setToolTip('DeniKey');
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(key: 'show', label: 'DeniKey\'i Aç'),
      MenuItem.separator(),
      MenuItem(key: 'exit', label: 'Çıkış'),
    ]));
  }

  Future<void> destroy() async {
    trayManager.removeListener(this);
    await trayManager.destroy();
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseUp() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show':
        windowManager.show();
        windowManager.focus();
      case 'exit':
        await destroy();
        await windowManager.destroy();
    }
  }
}
