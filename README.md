# Aplikasi Pelayanan Kesehatan & Antrean Rumah Sakit (Flutter)

Aplikasi mobile/web pelayanan kesehatan berbasis **Flutter** yang mengintegrasikan alur pendaftaran pasien, pencarian jadwal dokter, reservasi online dengan tiket Barcode/QR Code, verifikasi antrean oleh dokter, navigasi lokasi GPS unit poliklinik, serta pengawasan master data oleh Super Admin.

---

## 📌 Fitur Utama & Multi-Role User

### 1. 👤 **Pasien / User Umum**
- **Otentikasi**: Registrasi akun pasien baru & Login.
- **Cari Dokter & Spesialis**: Informasi lengkap dokter, spesialisasi, unit poliklinik, dan jadwal praktek.
- **Reservasi Antrean Online**: Membuat janji temu dan mendapatkan **Nomor Antrean Unik** (contoh: `A-001`) serta **Barcode / QR Code Digital** (`RES-20260811-001`).
- **Navigasi GPS Unit RS**: Pengarahan rute lokasi unit/poliklinik dari posisi pasien menuju koordinat Latitude/Longitude lokasi RS menggunakan peta (Google Maps/Apple Maps).

### 2. 👨‍⚕️ **Dokter**
- **Daftar Antrean Pasien**: Melihat daftar antrean pasien yang akan diperiksa hari ini secara *real-time*.
- **Scan / Verifikasi Barcode**: Memindai atau memasukkan kode barcode tiket pasien untuk memverifikasi kedatangan secara cepat.
- **Update Status Pemeriksaan**: Mengubah status antrean pasien (*Menunggu*, *Dipanggil*, hingga *Selesai*).

### 3. 🔐 **Super Admin**
- **Dashboard Overview**: Ringkasan statistik total Dokter, Unit Poliklinik, Spesialisasi, dan Antrean Keseluruhan.
- **Manajemen Master Data**: Pengelolaan data Dokter, Unit/Poli, Spesialisasi Medis, dan Jadwal Praktek.

---

## 🔑 Kredensial Pengujian (Demo Quick-Fill)

Pada layar Login, Anda dapat menggunakan tombol *Quick Fill* atau memasukkan akun berikut:

| Role | Email | Password |
| :--- | :--- | :--- |
| **Pasien** | `pasien@mail.com` | `123` |
| **Dokter** | `dokter@mail.com` | `123` |
| **Super Admin** | `admin@mail.com` | `123` |

---

## 🛠️ Arsitektur & Teknologi

- **Framework**: Flutter (Dart)
- **State Management**: `Provider`
- **QR / Barcode Generator**: `qr_flutter`
- **Peta & Navigasi**: `url_launcher` (Integrasi Google Maps / Apple Maps via koordinat Lat/Lng)
- **Scanner**: `mobile_scanner`

---

## 🚀 Cara Menjalankan Aplikasi

### 1. Install Dependensi
```bash
flutter pub get
```

### 2. Jalankan di Android Emulator
```bash
flutter run -d emulator-5554
```

### 3. Jalankan di Web (Chrome)
```bash
flutter run -d chrome
```

### 4. Jalankan di macOS Desktop
```bash
flutter run -d macos
```

---

## 📂 Struktur Direktori Proyek

```text
lib/
├── models/
│   └── models.dart                 # Data Models (User, Doctor, Unit, Specialist, Reservation)
├── services/
│   └── supabase_service.dart        # Services Layer (Supabase SDK & Data Layer)
├── viewmodels/
│   └── main_viewmodel.dart          # ViewModels Layer (State Notifier & Business Logic)
├── routes/
│   └── app_routes.dart             # Routing Layer (AppRoutes & Named Routes)
├── modules/
│   ├── auth/
│   │   └── auth_screens.dart        # Modul Otentikasi (Login & Registrasi Pasien)
│   ├── patient/
│   │   └── patient_home_screen.dart # Modul Pasien (Cari Dokter, Reservasi, Tiket Barcode, Navigasi Map)
│   ├── doctor/
│   │   └── doctor_home_screen.dart  # Modul Dokter (Daftar Antrean, Scan Barcode, Update Status)
│   └── admin/
│       └── admin_home_screen.dart   # Modul Super Admin (CRUD Dokter, Poli/Unit, Spesialisasi)
└── main.dart                        # Entry Point & Role Router
```
