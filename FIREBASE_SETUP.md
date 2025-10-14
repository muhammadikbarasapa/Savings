# 🔥 Firebase Setup Instructions

Error yang Anda alami terjadi karena Firebase belum dikonfigurasi dengan benar. Berikut langkah-langkah untuk mengkonfigurasi Firebase:

## 📋 Langkah 1: Buat Project Firebase

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Create a project" atau "Add project"
3. Masukkan nama project: `savings-app` (atau nama yang Anda inginkan)
4. Pilih Google Analytics (opsional)
5. Klik "Create project"

## 📱 Langkah 2: Tambahkan Web App

1. Di Firebase Console, klik ikon Web (`</>`)
2. Masukkan nama app: `SmartSaving Pro`
3. Centang "Also set up Firebase Hosting" (opsional)
4. Klik "Register app"
5. **SALIN** konfigurasi Firebase yang diberikan

## ⚙️ Langkah 3: Update Konfigurasi

### A. Update `lib/firebase_options.dart`:

Ganti nilai-nilai placeholder dengan konfigurasi Firebase Anda:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSy...', // Ganti dengan apiKey Anda
  appId: '1:123456789:web:...', // Ganti dengan appId Anda
  messagingSenderId: '123456789', // Ganti dengan messagingSenderId Anda
  projectId: 'your-project-id', // Ganti dengan projectId Anda
  authDomain: 'your-project-id.firebaseapp.com', // Ganti dengan authDomain Anda
  storageBucket: 'your-project-id.appspot.com', // Ganti dengan storageBucket Anda
);
```

### B. Update `web/index.html`:

Ganti konfigurasi Firebase di web/index.html:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...", // Ganti dengan apiKey Anda
  authDomain: "your-project-id.firebaseapp.com", // Ganti dengan authDomain Anda
  projectId: "your-project-id", // Ganti dengan projectId Anda
  storageBucket: "your-project-id.appspot.com", // Ganti dengan storageBucket Anda
  messagingSenderId: "123456789", // Ganti dengan messagingSenderId Anda
  appId: "1:123456789:web:..." // Ganti dengan appId Anda
};
```

## 🔧 Langkah 4: Enable Authentication & Firestore

### Enable Authentication:
1. Di Firebase Console, klik "Authentication"
2. Klik "Get started"
3. Pilih tab "Sign-in method"
4. Enable "Email/Password"
5. Enable "Google" (opsional)

### Enable Firestore:
1. Di Firebase Console, klik "Firestore Database"
2. Klik "Create database"
3. Pilih "Start in test mode"
4. Pilih lokasi server (pilih yang terdekat)
5. Klik "Done"

## 🚀 Langkah 5: Jalankan Aplikasi

Setelah konfigurasi selesai, jalankan aplikasi:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

## 🔍 Troubleshooting

### Jika masih error:
1. Pastikan konfigurasi Firebase sudah benar
2. Cek apakah projectId, apiKey, dan appId sudah sesuai
3. Pastikan Authentication dan Firestore sudah di-enable
4. Coba restart development server

### Untuk mendapatkan konfigurasi yang benar:
1. Buka Firebase Console
2. Pilih project Anda
3. Klik ikon Settings (⚙️) > Project settings
4. Scroll ke bawah ke bagian "Your apps"
5. Klik ikon Web
6. Copy konfigurasi yang diberikan

## 📝 Contoh Konfigurasi Lengkap

```dart
// lib/firebase_options.dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
  appId: '1:123456789012:web:abcdef1234567890',
  messagingSenderId: '123456789012',
  projectId: 'savings-app-12345',
  authDomain: 'savings-app-12345.firebaseapp.com',
  storageBucket: 'savings-app-12345.appspot.com',
);
```

```javascript
// web/index.html
const firebaseConfig = {
  apiKey: "AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  authDomain: "savings-app-12345.firebaseapp.com",
  projectId: "savings-app-12345",
  storageBucket: "savings-app-12345.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890"
};
```

---

**Setelah mengikuti langkah-langkah ini, aplikasi Anda akan berjalan tanpa error Firebase!** 🎉
