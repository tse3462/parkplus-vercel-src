# Parkhaus

Plaka tanımlı otopark: kamera girişi, QR ödeme, kilitli admin paneli.

## Vercel + Neon (kendi sunucunuz)

1. Bu özel GitHub reposunu [Vercel](https://vercel.com/new) içe aktarın.
2. [Neon](https://console.neon.tech) üzerinde Postgres oluşturun; connection string’i kopyalayın.
3. Vercel → Project → Settings → Environment Variables:

```
DATABASE_URL=postgres://...
VITE_AUTH_ENABLED=false
```

`VITE_AUTH_ENABLED` mutlaka `false` olsun — sürücü ödeme sayfası (`/pay`) giriş istemez.

4. Framework: **Other** / Vite. Node **22**. Deploy.

İlk derlemede şema (`migrations/0002`, `0003`) otomatik uygulanır.

## Admin kilidi

- İlk PIN: **246810**
- Admin → Fiyatlar’dan hemen değiştirin.
- Kamera, tahsilat, feragat ve fiyatlar PIN’siz açılmaz.
- Sürücü ödeme (`/pay`) ve tabela QR açık kalır.

## Ne çalışır

- ANPR / plaka ile giriş
- QR tabela → ödeme (Apple Pay, Google Pay, PayPal, kart — simülasyon)
- Ödenmeden çıkışta **€29,50** ceza (fiyatlardan değişir)
- Açık kayıtlar kırmızı; ücret içeride kaldıkça artar
- Elle çıkış, tahsil, feragat

## Not

Kart / Apple Pay / Google Pay / PayPal şu an simülasyondur. Gerçek tahsilat için ödeme sağlayıcısı (ör. Stripe) gerekir.
