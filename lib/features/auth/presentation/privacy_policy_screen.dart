import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik Politikası')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text(
            'Son güncelleme: Nisan 2026',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          _Section(
            title: '1. Giriş',
            body:
                'DeniKey ("uygulama", "biz", "hizmet"), sıfır-bilgi (zero-knowledge) mimarisiyle '
                'çalışan bir şifre yöneticisidir. Bu Gizlilik Politikası, uygulamayı kullanırken '
                'hangi verilerin toplandığını, nasıl işlendiğini ve haklarınızı açıklamaktadır.',
          ),
          _Section(
            title: '2. Toplanan Veriler',
            body:
                '• E-posta adresi ve kullanıcı adı — hesap oluşturma ve kimlik doğrulama için.\n'
                '• Master şifrenizin türetilmiş doğrulama değeri (hash) — düz metin asla saklanmaz.\n'
                '• Şifrelenmiş kasa verileri — cihazınızda AES-256-GCM ile şifrelendikten sonra '
                'sunucuya gönderilir; içeriği yalnızca siz okuyabilirsiniz.\n'
                '• Oturum tokenları ve cihaz kimliği — çoklu cihaz yönetimi için.\n'
                '• Denetim kayıtları (audit log) — hesap güvenliğinizi izlemeniz için, yalnızca '
                'sizin erişiminize açıktır.',
          ),
          _Section(
            title: '3. Sıfır Bilgi Mimarisi',
            body:
                'DeniKey, master şifrenizi hiçbir zaman sunucuya göndermez ve hiçbir yerde '
                'saklamaz. Kasa verileriniz cihazınızda, Argon2id algoritmasıyla türetilen bir '
                'anahtar ile AES-256-GCM formatında şifrelenir. Sunucularımız yalnızca şifreli '
                '(encrypted) veri depolar; içeriğinize teknik olarak erişim imkânımız yoktur.\n\n'
                'Master şifrenizi unutursanız verilerinizi kurtarmanın hiçbir yolu yoktur — '
                'bu, gerçek sıfır-bilgi güvenliğinin kaçınılmaz sonucudur.',
          ),
          _Section(
            title: '4. Verilerin Kullanımı',
            body:
                'Topladığımız veriler yalnızca şu amaçlarla kullanılır:\n'
                '• Hesabınızın oluşturulması ve yönetilmesi\n'
                '• Kimlik doğrulama ve oturum güvenliği\n'
                '• E-posta doğrulama ve şifre sıfırlama bildirimleri\n'
                '• Destek taleplerinize yanıt verilmesi\n\n'
                'Verileriniz üçüncü taraflarla paylaşılmaz, reklam amacıyla kullanılmaz.',
          ),
          _Section(
            title: '5. Veri Güvenliği',
            body:
                '• Tüm iletişim HTTPS/TLS üzerinden şifrelenmiş biçimde gerçekleşir.\n'
                '• Kasa verileri sunucuda şifreli olarak saklanır.\n'
                '• Şifreler Argon2id (memory: 64 MB, iterations: 3, parallelism: 2) ile '
                'türetilir; kaba kuvvet saldırılarına karşı dayanıklıdır.\n'
                '• JWT tokenlar kısa ömürlüdür ve yenileme mekanizması ile yönetilir.',
          ),
          _Section(
            title: '6. Hesap Silme',
            body:
                'Hesabınızı istediğiniz zaman Ayarlar → Hesabı Kalıcı Olarak Sil adımından '
                'silebilirsiniz. Silme işlemi 4 adımlı onay gerektirir ve tüm verileriniz '
                '(kasa öğeleri, kategoriler, audit kayıtları dahil) kalıcı olarak kaldırılır. '
                'Bu işlem geri alınamaz.',
          ),
          _Section(
            title: '7. Çocukların Gizliliği',
            body:
                'DeniKey, 13 yaşın altındaki çocuklara yönelik değildir. Bilerek bu yaş '
                'grubundan veri toplamıyoruz.',
          ),
          _Section(
            title: '8. Politika Değişiklikleri',
            body:
                'Bu politikayı güncelleyebiliriz. Önemli değişiklikler kayıtlı e-posta '
                'adresinize bildirilir. Güncel politika her zaman uygulama içinden erişilebilir.',
          ),
          _Section(
            title: '9. İletişim',
            body:
                'Gizlilik ile ilgili sorularınız için destek talebi oluşturabilir ya da '
                'uygulama içindeki Destek Talebi ekranını kullanabilirsiniz.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
