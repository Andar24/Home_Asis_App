import 'package:flutter/material.dart';

import 'ai_assistant_page.dart';
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
//     ├── floatingActionButton: Akses cepat Asisten Chat Home Asis
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AiAssistantPage()),
            );
          },
          tooltip: 'Bantuan Asisten',
          child: const Icon(Icons.support_agent_rounded),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Beranda'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Pesanan'),
            NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history_rounded),
                label: 'Riwayat'),
            NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
