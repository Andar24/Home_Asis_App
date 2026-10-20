import 'package:flutter/material.dart';

import 'history_tab.dart';
import 'home_tab.dart';
import 'orders_tab.dart';
import 'profile_tab.dart';

// =======================================================================
// HOME_ASIS - Shell Navigasi Pelanggan
// -----------------------------------------------------------------------
// SRS 3.1 (Antarmuka Pengguna): "Navigasi utama menggunakan Bottom
// Navigation Bar dengan menu: Beranda, Pesanan, Riwayat, Profil."
//
// Struktur widget (parent -> child):
// CustomerShell (StatefulWidget)
// └── Scaffold
//     ├── body: IndexedStack [HomeTab, OrdersTab, HistoryTab, ProfileTab]
//     └── bottomNavigationBar: NavigationBar (4 destinasi)
// =======================================================================
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  static const _tabs = [
    CustomerHomeTab(),
    CustomerOrdersTab(),
    CustomerHistoryTab(),
    CustomerProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: _index, children: _tabs),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Beranda'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
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
