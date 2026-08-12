# 📑 STANDAR PENGODEAN & ARSITEKTUR PERANGKAT LUNAK (CODING STANDARD)
**Proyek: Aplikasi Pelayanan Kesehatan & Antrean Online Rumah Sakit**

---

## 1. PRINSIP UTAMA ARSITEKTUR (FEATURE-BASED MVVM & SINGLE RESPONSIBILITY SERVICES)

Proyek ini menerapkan arsitektur **MVVM (Model-View-ViewModel)** dipadukan dengan **Feature-Based Modular Package Structure** dan **Single-Responsibility Services**.

Setiap modul dan layanan memiliki pemisahan komponen terisolasi secara ketat:
1. **Views Layer (`views/`)**: Tempat antarmuka pengguna (`Widget`, `Screen`, `Drawer`, `Dialog`). Murni tampilan visual visual (Presentational Component), **bebas dari kode panggilan HTTP/Database langsung**.
2. **Components Layer (`views/components/`)**: Sub-komponen UI modular terpisah untuk menjaga kebersihan file layar utama.
3. **Logic Layer (`logic/`)**: Berfungsi sebagai jembatan pengendali alur antar UI dengan Service/ViewModel untuk modul tersebut. Setiap file logic dibuat terisolasi sesuai perannya.
4. **Models Layer (`models/`)**: Berisi entitas domain serta data state penampung form UI per modul.
5. **Services Layer (`lib/services/`)**: Pustaka layanan terpisah khusus untuk komunikasi API/SDK eksternal yang diisolasi per tanggung jawab (*Single Responsibility Services*).

---

## 2. STRUKTUR DIREKTORI PROYEK (`lib/`)

```text
lib/
├── services/                        # Service Layer (Tergolong terpisah per domain API)
│   ├── database/
│   │   └── supabase_service.dart    # Service khusus database & SDK Supabase
│   └── map/
│       └── osm_service.dart         # Service khusus API OpenStreetMap Nominatim Geocoding
├── viewmodels/                      # Global ViewModels (State Management Notifier Utama)
│   └── main_viewmodel.dart
├── routes/                          # Routing Layer (AppRoutes & RootRouter)
│   └── app_routes.dart
├── modules/                         # Feature Packages (Terpisah Per Fitur & Sub-Komponen)
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── auth/                        # Modul Otentikasi
│   │   ├── views/ (auth_views.dart)
│   │   ├── logic/ (auth_logic.dart)
│   │   └── models/ (auth_models.dart)
│   ├── patient/                     # Modul Pasien
│   │   ├── views/
│   │   │   ├── components/ (ticket_card.dart)
│   │   │   └── patient_home_view.dart
│   │   ├── logic/ (patient_logic.dart)
│   │   └── models/ (patient_models.dart)
│   ├── doctor/                      # Modul Dokter
│   │   ├── views/
│   │   │   ├── components/ (verify_patient_dialog.dart)
│   │   │   └── doctor_home_view.dart
│   │   ├── logic/ (doctor_logic.dart)
│   │   └── models/ (doctor_models.dart)
│   └── admin/                       # Modul Super Admin
│       ├── views/
│       │   ├── components/
│       │   │   ├── add_doctor_drawer.dart
│       │   │   ├── add_unit_drawer.dart
│       │   │   └── add_specialist_drawer.dart
│       │   └── admin_home_view.dart
│       ├── logic/ (admin_logic.dart)
│       └── models/ (admin_models.dart)
└── main.dart                        # Main Entry Point & MaterialApp Root
```

---

## 3. ATURAN PENULISAN KODE LOGIK & SERVICE (LOGIC & SERVICE RULES)

### A. Isolidasi File Service (Dedicated Service Files)
- **Single Responsibility Principle**: Setiap layanan API atau komunikasi SDK eksternal wajib dibuat di file service terpisah sesuai ranahnya:
  - `SupabaseService`: Khusus transaksi CRUD database Supabase & Auth.
  - `OSMService`: Khusus panggilan HTTP ke OpenStreetMap Nominatim Live Geocoding API.
- Dilarang keras menggabungkan dua layanan yang tidak sejenis ke dalam satu file service.

### B. Modularization & Pemisahan UI vs Logic
1. **Views & Components Murni Visual**: File UI Component (`Widget`, `Drawer`, `Dialog`) hanya bertugas menerima input dan meng-render tampilan. Tidak boleh ada logika HTTP request atau pengolahan data mentah langsung di dalam file UI.
2. **Logic File Per Modul**: Setiap modul fitur wajib memiliki file pengendali logic terpisah (`auth_logic.dart`, `patient_logic.dart`, `doctor_logic.dart`, `admin_logic.dart`).
3. **Drawer untuk Form Input**: Semua form input penambahan data master wajib menggunakan `EndDrawer` tersendiri di folder `views/components/`.

---

## 4. STANDAR INTEGRASI PETA & GEOCODING REAL

1. **Map Picker Interaktif**: Menggunakan `flutter_map` dengan `TileLayer` dari OpenStreetMap.
2. **Real-time OpenStreetMap Geocoding**: Pencarian alamat asli (seperti *Puskesmas Sungailiat*) memanggil `OSMService.searchPlaces` secara langsung tanpa data dummy.
3. **Auto-Fill Coordinates**: Pengetukan pada peta atau pemilihan daftar pencarian wajib otomatis memperbarui nilai **Latitude**, **Longitude**, dan alamat lengkap.

---

## 5. UI DESIGN & OVERFLOW PROTECTION

1. **Text Overflow Handling**: Setiap opsi `DropdownMenuItem` dan teks daftar wajib diberi properti `isExpanded: true` serta `TextOverflow.ellipsis` untuk mencegah masalah *Yellow-Black Striped Overflow*.
2. **Autocomplete Dropdown**: Form input data master yang dinamis wajib mendukung pencarian filter *Searchable Autocomplete*.
3. **Visual Feedback (`SnackBar`)**: Memberikan balasan visual `SnackBar` hijau (sukses) atau merah (gagal) pada setiap transaksi data pengguna.
