import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/splash_page.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

// =======================================================================
// HOME_ASIS - Sistem Penyedia Layanan Rumah Tangga dan Teknisi
// -----------------------------------------------------------------------
// Implementasi aplikasi Flutter berdasarkan SRS Home_Asis Versi 2.0.
// Karena proyek ini adalah prototipe front-end tanpa backend/API pihak
// ketiga sungguhan (PostgreSQL, Midtrans, Google Maps, Firebase), seluruh
// data disimulasikan memakai AppState (ChangeNotifier) yang berperan
// sebagai "server" dummy di memori -- lihat lib/state/app_state.dart.
//
// Alur navigasi utama:
//   SplashPage -> OnboardingPage -> LoginPage (pilih peran) -> lalu:
//     - UserRole.customer -> CustomerShell (Beranda/Pesanan/Riwayat/Profil)
//     - UserRole.worker   -> WorkerShell   (Beranda/Pesanan/Riwayat/Profil)
//     - UserRole.admin    -> AdminDashboardPage (dashboard bergaya web)
//
// Struktur folder:
//   lib/models    -> entitas data (User, Worker, Booking, Review, dst.)
//   lib/data      -> data dummy awal (mock_data.dart)
//   lib/state     -> AppState (pengganti backend, disuntik lewat Provider)
//   lib/theme     -> tema warna & tipografi (Material Design 3)
//   lib/widgets   -> widget bersama (kartu, tombol, status pill, dst.)
//   lib/pages     -> seluruh layar, dikelompokkan per peran pengguna
// =======================================================================
void main() {
  runApp(const HomeAsisApp());
}

/// Root widget aplikasi. Menyediakan [AppState] ke seluruh subtree lewat
/// [ChangeNotifierProvider] dan mengatur tema global agar tampilan
/// konsisten di seluruh layar.
class HomeAsisApp extends StatelessWidget {
  const HomeAsisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Home_Asis',
        theme: buildAppTheme(),
        home: const SplashPage(),
      ),
    );
  }
}
