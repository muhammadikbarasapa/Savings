# SmartSaving - Aplikasi Manajemen Keuangan

## 📱 Deskripsi Aplikasi

SmartSaving adalah aplikasi manajemen keuangan pribadi yang memungkinkan pengguna untuk:
- Mencatat pemasukan dan pengeluaran
- Melihat saldo keuangan secara real-time
- Menganalisis keuangan melalui grafik dan chart
- Melacak tabungan per bulan
- Mengelola transaksi dengan kategori yang terorganisir

## 🚀 Fitur Utama

### 1. **Autentikasi & Keamanan**
- Login dengan Email & Password
- Login dengan Google Sign-In
- Registrasi akun baru
- Logout yang aman

### 2. **Dashboard Keuangan**
- Kartu saldo dengan informasi lengkap
- Ringkasan pemasukan dan pengeluaran
- Transaksi terbaru (5 terakhir)
- Quick actions untuk menambah transaksi

### 3. **Manajemen Transaksi**
- Tambah pemasukan dengan kategori (Gaji, Bonus, Freelance, dll)
- Tambah pengeluaran dengan kategori (Makanan, Transportasi, Belanja, dll)
- Edit dan hapus transaksi
- Pilih tanggal transaksi
- Validasi input yang ketat

### 4. **Analisis & Grafik**
- **Chart Pie untuk Pengeluaran**: Menampilkan distribusi pengeluaran berdasarkan kategori
- **Chart Pie untuk Pemasukan**: Menampilkan distribusi pemasukan berdasarkan kategori
- **Chart Tabungan Bulanan**: Grafik kombinasi (column + line) yang menampilkan:
  - Pemasukan per bulan (column hijau)
  - Pengeluaran per bulan (column merah)
  - Tabungan per bulan (line biru)

### 5. **Halaman Semua Transaksi**
- Tampilkan semua transaksi dengan filter
- Filter berdasarkan: Semua, Pemasukan, atau Pengeluaran
- Summary card dengan total pemasukan, pengeluaran, dan saldo
- Urutan berdasarkan tanggal (terbaru dulu)
- Hapus transaksi dengan konfirmasi

## 🛠️ Teknologi yang Digunakan

### **Frontend (Flutter)**
- **Flutter 3.24.0** - Framework utama
- **Dart 3.5.0** - Bahasa pemrograman
- **Material Design 3** - UI/UX Design

### **Backend & Database**
- **Firebase Core** - Backend service
- **Firebase Authentication** - Sistem autentikasi
- **Cloud Firestore** - Database NoSQL
- **Google Sign-In** - OAuth authentication

### **Charts & Visualisasi**
- **Syncfusion Flutter Charts** - Library untuk grafik dan chart
- **Pie Chart** - Untuk distribusi kategori
- **Column Chart** - Untuk data bulanan
- **Line Chart** - Untuk trend tabungan

### **Utilities**
- **intl** - Formatting tanggal dan mata uang
- **path_provider** - Akses file system
- **shared_preferences** - Penyimpanan lokal
- **flutter_local_notifications** - Notifikasi lokal

## 📁 Struktur Project

```
lib/
├── main.dart                          # Entry point aplikasi
├── models/
│   └── transaction_model.dart         # Model data transaksi
├── services/
│   ├── auth_services.dart             # Service autentikasi
│   └── firebase_services.dart         # Service Firebase
├── screen/
│   ├── login_screen.dart              # Halaman login
│   ├── register_screen.dart           # Halaman registrasi
│   ├── home_screen.dart               # Dashboard utama
│   ├── add_transaction_screen.dart    # Tambah transaksi
│   ├── chart_screens.dart             # Halaman grafik
│   └── all_transactions_screen.dart   # Semua transaksi
├── widgets/
│   ├── balance_card.dart              # Widget kartu saldo
│   └── transaction_card.dart          # Widget kartu transaksi
└── utils/
    └── fotmatter.dart                 # Utility formatting
```

## 🎯 Cara Penggunaan

### **1. Registrasi & Login**
- Buka aplikasi SmartSaving
- Pilih "Daftar" untuk membuat akun baru
- Atau gunakan "Login dengan Google" untuk akses cepat

### **2. Menambah Transaksi**
- Dari dashboard, klik tombol "Tambah Pemasukan" atau "Tambah Pengeluaran"
- Isi judul transaksi, jumlah, dan pilih kategori
- Pilih tanggal transaksi
- Klik "Simpan"

### **3. Melihat Grafik**
- Dari dashboard, klik tombol "Lihat Grafik"
- Beralih antara tab:
  - **Pengeluaran**: Pie chart distribusi pengeluaran
  - **Pemasukan**: Pie chart distribusi pemasukan  
  - **Tabungan Bulanan**: Grafik trend tabungan per bulan

### **4. Mengelola Transaksi**
- Dari dashboard, klik "Lihat Semua" untuk melihat semua transaksi
- Gunakan filter untuk melihat pemasukan atau pengeluaran saja
- Hapus transaksi dengan klik icon delete

## 📊 Fitur Chart Unggulan

### **Chart Tabungan Bulanan**
- **Column Chart**: Menampilkan pemasukan (hijau) dan pengeluaran (merah) per bulan
- **Line Chart**: Menampilkan trend tabungan (biru) yang dihitung otomatis
- **Format Mata Uang**: Menggunakan format Rupiah Indonesia
- **Legend**: Memudahkan identifikasi data
- **Responsive**: Menyesuaikan dengan jumlah data

## 🔧 Konfigurasi Firebase

Pastikan Anda sudah mengkonfigurasi Firebase project:

1. **Firebase Console**: Buat project baru di [Firebase Console](https://console.firebase.google.com)
2. **Authentication**: Aktifkan Email/Password dan Google Sign-In
3. **Firestore**: Buat database dengan mode production atau test
4. **Android**: Download `google-services.json` dan letakkan di `android/app/`
5. **iOS**: Download `GoogleService-Info.plist` dan letakkan di `ios/Runner/`

## 🚀 Menjalankan Aplikasi

```bash
# Install dependencies
flutter pub get

# Run di web
flutter run -d chrome

# Run di Android
flutter run

# Build APK
flutter build apk --release
```

## 📱 Screenshots Fitur

- **Login Screen**: Interface login yang clean dengan Google Sign-In
- **Dashboard**: Kartu saldo, quick actions, dan transaksi terbaru
- **Add Transaction**: Form input dengan validasi dan kategori dropdown
- **Charts**: Grafik interaktif dengan 3 tab berbeda
- **All Transactions**: List lengkap dengan filter dan summary

## 🎨 UI/UX Features

- **Material Design 3**: Menggunakan design system terbaru
- **Color Scheme**: Blue primary dengan green (income) dan red (expense)
- **Responsive**: Menyesuaikan berbagai ukuran layar
- **Loading States**: Indikator loading untuk semua operasi async
- **Error Handling**: Pesan error yang informatif
- **Empty States**: UI yang menarik ketika belum ada data

## 🔮 Potensi Pengembangan

- [ ] Export data ke PDF/Excel
- [ ] Notifikasi reminder tagihan
- [ ] Budget planning dan tracking
- [ ] Multi-currency support
- [ ] Backup data ke cloud
- [ ] Dark mode theme
- [ ] Biometric authentication
- [ ] Offline support dengan sync

---

**SmartSaving** - Kelola keuangan Anda dengan mudah dan efisien! 💰📊