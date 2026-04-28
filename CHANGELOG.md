# DeniKey Değişiklik Geçmişi

## [1.0.6] — 2026-04-26

### Düzeltmeler
- Onboarding bypass kaldırıldı, debug hata mesajı üretim moduna uygun hale getirildi

### CI/CD
- GitHub Actions artifact'larına retention-days eklendi (main push: 5 gün, tag push: 30 gün)
- Main push'ta da APK/EXE artifact üretilir

---

## [Unreleased] — 2026-04-14

### Yeni Dosyalar
| Dosya | Açıklama |
|-------|----------|
| `lib/core/presentation/app_nav_bar.dart` | Bottom navigation bar (Kasam / Kütüphane / Ayarlar) |
| `lib/core/presentation/splash_screen.dart` | Animasyonlu açılış ekranı |
| `lib/core/presentation/loading_overlay.dart` | Global loading overlay widget'ı |
| `lib/core/presentation/app_shortcuts.dart` | Klavye kısayolları handler + kısayol listesi kartı |
| `lib/core/providers/shortcuts_provider.dart` | Kısayollar açık/kapalı durumu (SharedPreferences) |

---

### Değiştirilen Dosyalar

#### `lib/main.dart`
- **Renk şeması**: `#7C3AED` mor → `#090C08` Onyx / `#223841` Jet Black / `#FF5900` Blaze Orange
- **Material 3 tema**: CardTheme, FilledButton, AppBarTheme, NavigationBarTheme tek merkezden yönetiliyor
- **window_manager**: Uygulama maximize modunda açılır (görev çubuğu görünür, tam ekran değil)
- **WindowListener**: Odak kaybedince `_wasBlurred = true`; geri gelince `/lock` ekranına yönlendirir
- **LoadingOverlay** + **AppShortcuts** `MaterialApp.builder` içine sarıldı

#### `lib/core/router/app_router.dart`
- Eski `SplashScreen` sınıfı kaldırıldı, `splash_screen.dart`'a taşındı
- Kullanılmayan `import 'package:flutter/material.dart'` temizlendi

#### `lib/features/auth/presentation/settings_screen.dart`
- "Klavye Kısayolları" SwitchListTile eklendi (varsayılan kapalı)
- Kısayollar açıkken `ShortcutHintCard` gösteriliyor
- "Biyometrik Kilit" help tile kaldırıldı
- "Sıfır Bilgi Güvenliği" help tile genişletildi (Argon2id, AES-256-GCM detayları)
- AppNavBar eklendi (index: 2)

#### `lib/features/vault/presentation/vault_screen.dart`
- **Üst kısım**: Yatay kaydırılabilir kategori çipleri (Tümü + her kategori)
- **Filtreleme**: Seçili kategoriye göre şifre listesi filtreleniyor
- **Boş durum**: "Bu kategoride şifre yok" mesajı eklendi
- AppNavBar eklendi (index: 0)
- Hardcoded renkler → ColorScheme

#### `lib/features/categories/presentation/library_screen.dart`
- **Tür ekleme dialogu**: "Sabit Alanlar" bölümü eklendi
  - "Alan Ekle" butonu ile yeni alan eklenebilir
  - Her alan için ad + tür (Metin/Gizli/Sayı/Tarih) seçilebilir
  - Alan eklenmezse varsayılan "Şifre" alanı oluşturulur
- AppNavBar eklendi (index: 1)
- Hardcoded renkler → ColorScheme / tema

#### `lib/features/auth/presentation/login_screen.dart`
- Hardcoded `Colors.deepPurple` → ColorScheme
- `border: OutlineInputBorder()` satırları kaldırıldı (tema'da tanımlı)
- FilledButton style temizlendi (tema'dan geliyor)
- Logo: shield ikonu, "DeniKey" başlığı tema uyumlu

#### `lib/features/auth/presentation/register_screen.dart`
- Login screen ile aynı temizlik
- AppBar hardcoded renkleri kaldırıldı

#### `lib/features/item_types/data/item_type_repository.dart`
- `createItemType` metoduna `fields` parametresi eklendi

#### `lib/features/item_types/providers/item_type_provider.dart`
- `createItemType` metoduna `fields` parametresi eklendi

#### `pubspec.yaml`
- `window_manager: ^0.3.9` bağımlılığı eklendi

---

### Backend Değişiklikleri

#### `denikey/backend/app/api/v1/endpoints/item_type.py`
- `ItemTypeFieldCreate` schema sınıfı eklendi (`field_name`, `field_type`, `is_required`)
- `ItemTypeCreate` şemasına `fields: Optional[list[ItemTypeFieldCreate]]` eklendi

#### `denikey/backend/app/services/item_type_service.py`
- `create_item_type`: Kullanıcı alan tanımladıysa onları oluşturur
- Alan tanımlanmadıysa varsayılan "Şifre" (secret) alanı eklenir (eski davranış korundu)

---

### Klavye Kısayolları (Ayarlardan Açılır)

| Kısayol | Eylem |
|---------|-------|
| `Ctrl + 1` | Kasama git |
| `Ctrl + 2` | Kütüphaneye git |
| `Ctrl + 3` | Ayarlara git |
| `Ctrl + N` | Yeni şifre ekle |
| `Ctrl + F` | Arama |
| `Ctrl + G` | Şifre Üretici |
| `+` / `NumPad+` | Yeni şifre (kasam ekranında) |
| `←` / `→` | Sekmeler arası geçiş |
| `Escape` | Geri git |

---

### Güvenlik

- **Otomatik kilit**: Uygulama arka plana alınıp geri gelindiğinde (sekme değişimi dahil) kilit ekranına yönlendirilir
- **Ekran görüntüsü engeli**: Linux/GTK'da platform desteği olmadığından uygulanmadı (yalnızca Android/iOS destekler)
