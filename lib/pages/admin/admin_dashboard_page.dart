import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import '../login_page.dart';
import 'admin_categories_tab.dart';
import 'admin_reports_tab.dart';
import 'admin_users_tab.dart';
import 'admin_verification_tab.dart';

// =======================================================================
// HOME_ASIS - Dashboard Admin
// -----------------------------------------------------------------------
// SRS 4.10 "Dashboard Admin": "Antarmuka manajemen terpusat berbasis web
// untuk staf internal Home_Asis memantau kesehatan ekosistem aplikasi."
// Ditampilkan memakai TabBar 5 menu agar terasa seperti dashboard web
// meskipun dijalankan di dalam shell aplikasi mobile yang sama (SRS 2.3:
// admin memakai antarmuka terpisah dari pelanggan/pekerja).
//
// Struktur widget (parent -> child):
// AdminDashboardPage (StatefulWidget, TabController 5 tab)
// └── Scaffold
//     ├── appBar: judul + TabBar [Ringkasan, Verifikasi, Pengguna, Laporan, Kategori]
//     └── body: TabBarView
//         ├── _RingkasanTab (kartu statistik)
//         ├── AdminVerificationTab
//         ├── AdminUsersTab
//         ├── AdminReportsTab
//         └── AdminCategoriesTab
// =======================================================================
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 5, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Admin Home_Asis',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          actions: [
            IconButton(
              tooltip: 'Keluar',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => tampilkanKonfirmasiLogout(
                  context, appState.logout, const LoginPage()),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Ringkasan'),
              Tab(text: 'Verifikasi KTP'),
              Tab(text: 'Pengguna'),
              Tab(text: 'Laporan'),
              Tab(text: 'Kategori'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            _RingkasanTab(),
            AdminVerificationTab(),
            AdminUsersTab(),
            AdminReportsTab(),
            AdminCategoriesTab(),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// TAB RINGKASAN: metrik utama (SRS 4.10.2 - "Admin login ke dashboard ->
// Sistem menampilkan ringkasan metrik: total pengguna, pesanan hari ini,
// pendapatan").
// -------------------------------------------------------------------
class _RingkasanTab extends StatelessWidget {
  const _RingkasanTab();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final totalPengguna =
        appState.workers.length + appState.customerAccounts.length;
    final terverifikasi = appState.workers
        .where((w) => w.verificationStatus == VerificationStatus.verified)
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            StatCard(
                icon: Icons.group_rounded,
                value: '$totalPengguna',
                label: 'Total Pengguna',
                color: Colors.indigo),
            StatCard(
                icon: Icons.today_rounded,
                value: '${appState.pesananHariIni}',
                label: 'Pesanan Hari Ini',
                color: Colors.teal),
            StatCard(
                icon: Icons.payments_rounded,
                value: formatRupiahRibuan(appState.totalPendapatanBulanIni),
                label: 'Pendapatan Terkumpul',
                color: Colors.green),
            StatCard(
                icon: Icons.verified_user_rounded,
                value: '$terverifikasi/${appState.workers.length}',
                label: 'Mitra Terverifikasi',
                color: Colors.orange),
          ],
        ),
        const SizedBox(height: 8),
        const SectionTitle(title: 'Aktivitas Terbaru'),
        SoftCard(
          child: Column(
            children: appState.bookings.take(5).map((b) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: b.status.color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          '${b.customerName} memesan ${b.categoryName} dari ${b.workerName}',
                          style: const TextStyle(fontSize: 12.5)),
                    ),
                    BookingStatusPill(status: b.status),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Target uptime sistem 99.9% (Availability - High, SRS 5.4). Seluruh data pada dashboard ini bersifat simulasi.',
                  style: TextStyle(fontSize: 11.5, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
