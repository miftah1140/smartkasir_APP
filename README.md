# SmartKasir App (Praktikum Minggu 10)

Aplikasi Kasir POS Digital - Praktikum Mobile Programming Poliban.

## Cara pakai (± 3 menit)

1. Buka terminal di `C:\Flutter` lalu buat proyek kosong:
   ```
   flutter create smartkasir_app
   ```
2. Hapus folder `lib` bawaan di `smartkasir_app`, lalu salin folder `lib` dari zip ini sebagai gantinya.
3. Masuk ke folder proyek dan pasang library:
   ```
   cd smartkasir_app
   flutter pub add sqflite path shared_preferences intl
   ```
   Jika muncul peringatan symlink, jalankan `start ms-settings:developers`, aktifkan Developer Mode, lalu `flutter pub get`.
4. Pilih target Chrome, lalu Run -> Run Without Debugging (Ctrl+F5).
5. Buka GitHub Desktop -> Add Local Repository -> pilih folder proyek -> Commit -> Publish repository (hilangkan centang private).

## Live Tweak yang sudah diterapkan
1. Tema warna: `Colors.teal` (lib/main.dart)
2. Splash screen 10 detik (lib/pages/splash_screen_page.dart)
3. Produk Kopi Susu diskon 20% (lib/models/produk.dart)
