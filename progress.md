# DeniKey Flutter — Oturum Progressi

## Son Güncelleme: 2026-04-17

---

## ✅ Tamamlananlar

### Güvenlik
- **Argon2id fix:** Backend `time_cost=2` → `3` (Flutter `iterations=3` ile eşitlendi)
- **CORS kısıtlandı:** `["*"]` → `["https://denikey.website", ...]`
- **Master Lock ekranı eklendi:** Her uygulama açılışında master password zorunlu
  - `lib/features/auth/presentation/master_lock_screen.dart` → yeni dosya
  - AES-GCM ile doğrulama blob sistemi (şifre yanlışsa vault açılmaz)
  - `encryption_salt` ve `verification_blob` SecureStorage'a kaydediliyor
- **Splash fix:** Token varsa → direkt `/master-lock` (eskiden biyometrik bypass vardı)
- **onWindowFocus fix:** `/lock` → `/master-lock` (main.dart:186)

### Depolama
- **SecureStorage refactor:** Linux'ta libsecret (WSL2'de çalışmıyor) yerine `shared_preferences` kullanılıyor. Android'de `flutter_secure_storage` (Android Keystore) korundu.

### Görsel
- **Logo köşeleri yuvarlatıldı:** %18 radius, rounded square format
- **Windows ICO oluşturuldu:** 16/32/48/64/128/256px çok boyutlu ICO
- **Runner.rc güncellendi:** `denikey_app` → `DeniKey`
- **Linux desktop entry:** `~/.local/share/applications/denikey.desktop` oluşturuldu
- **Launcher ikonları yeniden üretildi:** `dart run flutter_launcher_icons`

### CI/CD
- **GitHub Actions:** `.github/workflows/build.yml` — Android + Windows + Linux ✅
- **Build hataları giderildi:**
  - Linux: `libsecret-1-dev` + ek paketler eklendi
  - Windows: `core.longpaths true` + `Zone.Identifier` dosyası git'ten silindi
- **GitHub Releases otomatik yayın:** `v*` tag push edilince tetiklenir ✅
  - APK → `DeniKey-Android.apk`
  - Windows → `DeniKey-Windows.zip`
  - Linux → `DeniKey-Linux.tar.gz`
- **v1.0.0 tag push edildi** — Release build çalışıyor/bitti
- **iOS:** Mac gerektirdiği için yapılmayacak

### E-posta
- **Resend DNS doğrulandı** ✅
- `email_service.py` → `from: noreply@denikey.website`

---

## ⏳ Bekleyenler

### 1. Android Keystore İmzalama (Play Store için)
- Şu an APK imzasız çıkıyor — direkt dağıtım için sorun yok, Play Store için zorunlu
- Komutlar:
  ```bash
  keytool -genkey -v -keystore ~/denikey.keystore -alias denikey -keyalg RSA -keysize 2048 -validity 10000
  # android/key.properties oluştur
  # build.gradle.kts signing config ekle
  flutter build appbundle --release
  ```

### 2. DEBUG=False
- Railway env var'da `DEBUG=True` → `False`
- Play Store'a göndermeden önce yapılacak

### 3. Play Store Yayını
- Google Play Developer hesabı ($25 tek seferlik)
- Keystore imzası tamamlandıktan sonra
- AAB yükle, ekran görüntüsü/açıklama ekle, incelemeye gönder

---

## Önemli Dosya ve URL'ler

| Konu | Değer |
|------|-------|
| Flutter repo | `github.com/Denisergocmen924/denikey-flutter` |
| Backend repo | `github.com/Denisergocmen924/denikey-backend` |
| Railway URL | `https://denikey-backend-production.up.railway.app` |
| Release URL | `github.com/Denisergocmen924/denikey-flutter/releases/latest` |
| Son tag | `v1.0.0` |
| Son commit | `f40ca2f` |

## Başlatma Komutları

```bash
# Linux çalıştır (debug)
cd /home/monster/denikey_app && flutter run -d linux

# Yeni release çıkar
cd /home/monster/denikey_app && git tag v1.x.x && git push origin v1.x.x

# Backend local
cd /home/monster/denikey/backend && source venv/bin/activate && uvicorn app.main:app --reload --port 8000

# Backend Railway push
cd /home/monster/denikey/backend && git add . && git commit -m "açıklama" && git push

# Flutter push
cd /home/monster/denikey_app && git add . && git commit -m "açıklama" && git push
```
