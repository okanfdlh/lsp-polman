#  Aplikasi Pelayanan Kesehatan & Antrean Rumah Sakit (Flutter)

Aplikasi mobile/web pelayanan kesehatan profesional berbasis **Flutter** yang mengintegrasikan alur pendaftaran pasien, pencarian jadwal dokter, reservasi online dengan tiket Barcode/QR Code, verifikasi antrean oleh dokter via scanner kamera, peta sebaran unit poliklinik interaktif berbasis GPS, serta pengelolaan master data oleh Super Admin.

---

##  Modern Professional Design System

Seluruh antarmuka aplikasi dirancang ulang menggunakan **Material3**, tipografi **Google Fonts Inter**, skema warna medis yang harmonis (**Medical Teal & Deep Slate**), *glassmorphism*, animasi logo halus, serta komponen UI responsif.

- **Primary Colors**: Medical Teal (`#0A7B6C`), Dark Teal (`#004D40`), Mint Accent (`#00BFA5`).
- **Typography**: Google Fonts Inter.
- **Visuals**: Card Shadows, Custom Gradient Headers, Dashboard Stat Cards, Ticket Boarding-Pass Style.

---

##  Fitur Utama & Multi-Role User

### 1. 👤 **Pasien / User Umum**
- **Home Dashboard**:
  - **Hero Greeting Banner**: Menyapa nama pasien terdaftar.
  - **Promo/Info PageView Slider**: Banner informasi layanan interaktif.
  - **Quick Access Menu Grid**: Akses cepat ke *Cari Dokter*, *Peta Unit*, *Tiket Antrean*, dan *Profil Saya*.
  - **Live Ticket Preview Card**: Preview tiket antrean aktif di beranda.
  - **Info & Artikel Kesehatan**: Kartu edukasi kesehatan, gizi, dan nutrisi.
- **Cari & Pilih Dokter**: Daftar dokter lengkap dengan foto, spesialisasi, nama unit poliklinik, serta jadwal praktek.
- **Reservasi Online**: Pemilihan tanggal & jam kedatangan dengan dialog bergradient, mendapatkan **Nomor Antrean Unik** (misal `A-001`) dan **Barcode/QR Code Digital** (`RES-...`).
- **Tiket Boarding Pass & Histori**: Tampilan tiket bergaya boarding pass dengan dashed divider, QR Code, dan tab riwayat reservasi (*Selesai* / *Batal*).
- **Peta Sebaran Unit (GPS)**: Peta interaktif OpenStreetMap (`flutter_map`) yang otomatis memusatkan posisi di lokasi GPS perangkat pasien, serta fitur navigasi rute ke Google Maps / Apple Maps.
- **Profil Pasien**: Ringkasan statistik reservasi (*Total*, *Selesai*, *Menunggu*), ID Pasien, dan status akun.

### 2.  **Dokter**
- **Antrean Aktif Hari Ini**: Daftar antrean pasien menunggu giliran secara *real-time* lengkap dengan pencarian & dropdown perubah status.
- **Riwayat Pemeriksaan**: Daftar riwayat pasien yang telah selesai diawasi atau dibatalkan.
- **Live Camera Barcode Scanner**: Pemindaian QR Code/Barcode tiket pasien menggunakan kamera via `mobile_scanner` dengan bingkai cutout animasi & kontrol torch/flash.
- **Input & Verifikasi Manual**: Pencarian kode tiket manual dan modal verifikasi status pasien.
- **Profil Dokter**: Statistik jumlah pasien ditangani & status keaktifan praktek.

### 3.  **Super Admin**
- **Dashboard Overview**: Ringkasan statistik total Dokter, Unit Poliklinik, Spesialisasi, dan Antrean Keseluruhan dengan kartu grid responsif.
- **Manajemen Dokter**: Pencarian & penambahan data dokter melalui Drawer bergradient (autocomplete spesialisasi & unit poli, picker hari/jam praktek).
- **Manajemen Unit Poliklinik**: Penambahan & edit unit poli lengkap dengan **Peta Interaktif (Tap Lokasi)**, pencarian alamat live OpenStreetMap Nominatim, serta integrasi GPS otomatis.
- **Manajemen Spesialisasi**: Pengelolaan bidang spesialisasi medis dokter.

---

##  Kredensial Pengujian (Demo Quick-Fill)

Pada layar Login, Anda dapat memilih tab role atau memasukkan akun demo berikut:

| Role | Email | Password | Layar Tujuan |
| :--- | :--- | :--- | :--- |
| **Super Admin** | `admin@gmail.com` | `admin123` | Dashboard Admin |
| **Dokter** | `dokter@gmail.com` | `dokter123` | Panel Dokter |
| **Pasien** | `okan@gmail.com` | `pasien123` | Home Dashboard Pasien |

---

## Arsitektur & Teknologi

- **Framework**: Flutter (Dart SDK >=3.0.0)
- **Design System**: Material3, Google Fonts (Inter), Custom Color System (`AppColors`)
- **Backend / Database**: Supabase Flutter SDK (Auth Gateway dengan Fallback Engine ke PostgreSQL Profile Table)
- **State Management**: `Provider` (`MainViewModel`)
- **Interactive Maps & GPS**: `flutter_map`, `latlong2`, `geolocator`
- **QR & Barcode**: `qr_flutter` (Generator) & `mobile_scanner` (Camera Reader)
- **Navigation & Launcher**: `url_launcher` (Integrasi Google Maps / Apple Maps)

---

## Cara Menjalankan Aplikasi

### 1. Install Dependensi
```bash
flutter pub get
```

### 2. Jalankan di Android Emulator / Device
```bash
flutter run -d emulator-5554
```

### 3. Jalankan di iOS Physical Device (iPhone)
Mode Debug (Terhubung ke USB & Xcode Debugger):
```bash
flutter run -d okn
```

Mode Release Standalone (Bebas Cabut Kabel USB):
```bash
flutter run -d okn --release
```

### 4. Build Production APK (Android Release)
```bash
flutter build apk --release
```
*Output APK*: `build/app/outputs/flutter-apk/app-release.apk`

---

##  Struktur Direktori Proyek

```text
lib/
├── main.dart                            # Entry Point, Theme System (AppColors & Google Fonts)
├── services/
│   ├── database/
│   │   └── supabase_service.dart        # Supabase API & Auth Fallback Handler
│   └── map/
│       ├── location_service.dart        # GPS Device Location Handler
│       └── osm_service.dart             # Geocoding & Nominatim Search Handler
├── viewmodels/
│   └── main_viewmodel.dart              # Main ViewModel (Provider State Notifier)
├── routes/
│   └── app_routes.dart                 # App Named Routes & Router Config
└── modules/
    ├── splash/
    │   └── splash_screen.dart           # Animated Splash Screen dengan Glassmorphism
    ├── auth/
    │   ├── views/ (auth_views.dart)     # LoginView & RegisterView
    │   ├── logic/ (auth_logic.dart)     # Otentikasi Logic
    │   └── models/ (auth_models.dart)   # Auth Domain Models
    ├── patient/
    │   ├── views/
    │   │   ├── components/
    │   │   │   ├── ticket_card.dart     # Boarding-Pass Style Ticket Card
    │   │   │   └── reservation_picker_dialog.dart # Custom Date/Time Reservation Picker
    │   │   └── patient_home_view.dart  # User Dashboard, Cari Dokter, Peta GPS, Tiket & Profil
    │   ├── logic/ (patient_logic.dart)  # Map & Navigation Logic
    │   └── models/ (patient_models.dart)# Reservation & Ticket Models
    ├── doctor/
    │   ├── views/
    │   │   ├── components/
    │   │   │   ├── barcode_scanner_modal.dart # Live Camera Barcode Reader Modal
    │   │   │   └── verify_patient_dialog.dart # Custom Verification Dialog
    │   │   └── doctor_home_view.dart   # Panel Antrean, Histori, Scan, & Profil Dokter
    │   ├── logic/ (doctor_logic.dart)   # Doctor Business Logic
    │   └── models/ (doctor_models.dart) # Doctor Models
    └── admin/
        ├── views/
        ├── components/
        │   ├── add_doctor_drawer.dart     # Side Drawer Form Tambah/Edit Dokter
        │   ├── add_unit_drawer.dart       # Side Drawer Interactive Map Unit Poli
        │   └── add_specialist_drawer.dart # Side Drawer Form Spesialis
        └── admin_home_view.dart        # Dashboard Admin Stat Grid & Master Data Cards
```
