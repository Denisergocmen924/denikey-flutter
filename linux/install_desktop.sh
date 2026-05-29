#!/bin/bash
# DeniKey'i Linux uygulama başlatıcısına ve PATH'e ekler.
# Kullanım: ./install_desktop.sh [bundle_dizini]
# Örnek (debug): ./install_desktop.sh ../build/linux/x64/debug/bundle
# Örnek (release): ./install_desktop.sh  (varsayılan: release bundle)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BUNDLE="${1:-$SCRIPT_DIR/../build/linux/x64/release/bundle}"
BUNDLE="$(realpath "$BUNDLE")"

if [ ! -f "$BUNDLE/DeniKey" ]; then
  echo "Hata: $BUNDLE/DeniKey bulunamadı."
  echo "Önce uygulamayı derle: flutter build linux --release"
  echo "Debug için:   ./install_desktop.sh ../build/linux/x64/debug/bundle"
  exit 1
fi

# --- .desktop dosyası ---
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"
sed "s|BUNDLE_PATH|$BUNDLE|g" "$SCRIPT_DIR/denikey.desktop" \
  > "$DESKTOP_DIR/denikey.desktop"
update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
echo "✓ Launcher kuruldu: $DESKTOP_DIR/denikey.desktop"

# --- PATH komutu: ~/.local/bin/denikey ---
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
cat > "$BIN_DIR/denikey" << EOF
#!/bin/bash
exec "$BUNDLE/DeniKey" "\$@"
EOF
chmod +x "$BIN_DIR/denikey"
echo "✓ PATH komutu kuruldu: $BIN_DIR/denikey"

# ~/.local/bin PATH kontrolü
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo ""
  echo "⚠  $BIN_DIR henüz PATH'inde yok."
  echo "   Aşağıdaki satırı ~/.bashrc veya ~/.zshrc dosyasına ekle:"
  echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo "   Sonra: source ~/.bashrc"
else
  echo "✓ $BIN_DIR zaten PATH'inde"
fi

echo ""
echo "Kurulum tamamlandı. 'denikey' komutuyla veya uygulama menüsünden açabilirsin."
