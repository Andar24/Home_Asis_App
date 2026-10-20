import 'package:flutter/material.dart';

import 'worker_history_tab.dart';
import 'worker_home_tab.dart';
import 'worker_orders_tab.dart';
import 'worker_profile_tab.dart';

// =======================================================================
// HOME_ASIS - Shell Navigasi Mitra Pekerja
// -----------------------------------------------------------------------
// Mengikuti standar navigasi SRS 3.1 (Beranda/Pesanan/Riwayat/Profil),
// diadaptasi untuk konteks Mitra Pekerja: Beranda menampilkan ringkasan
// & status ketersediaan, Pesanan menampilkan permintaan masuk & pekerjaan
// berjalan (SRS 4.4), Riwayat menampilkan pekerjaan selesai & pendapatan,
// Profil menampilkan status verifikasi (SRS 4.2) dan pengaturan akun.
// =======================================================================
class WorkerShell extends StatefulWidget {
  const WorkerShell({super.key});

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  int _index = 0;

  static const _tabs = [
    WorkerHomeTab(),
    WorkerOrdersTab(),
    WorkerHistoryTab(),
    WorkerProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(child: IndexedStack(index: _index, children: _tabs)),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Beranda'),
            NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Pesanan'),
            NavigationDestination(
                icon: Icon(Icons.history_rounded),
                selectedIcon: Icon(Icons.history_rounded),
                label: 'Riwayat'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
