import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../login_page.dart';
import '../notifications_page.dart';
import 'block_users_page.dart';

// =======================================================================
// HOME_ASIS - Tab Profil (Pelanggan)
// -----------------------------------------------------------------------
// Kumpulan menu akun: Notifikasi, Metode Pembayaran,
// Blokir Pengguna, dan Keluar Akun.
// =======================================================================
class CustomerProfileTab extends StatelessWidget {
  const CustomerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Profil',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          SoftCard(
            child: Row(
              children: [
                CircleAvatar(
                    radius: 30,
                    backgroundColor: scheme.primary,
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 30)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appState.currentUserName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('Akun Pelanggan Home_Asis',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MenuTile(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsPage())),
          ),
          _MenuTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Metode Pembayaran',
            onTap: () => _tampilkanMetodePembayaran(context),
          ),
          _MenuTile(
            icon: Icons.block_rounded,
            label: 'Blokir Pengguna',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BlockUsersPage())),
          ),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: 'Keluar Akun',
            danger: true,
            onTap: () => tampilkanKonfirmasiLogout(
                context, appState.logout, const LoginPage()),
          ),
        ],
      ),
    );
  }

  void _tampilkanMetodePembayaran(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Metode Pembayaran Tersimpan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            const ListTile(
                leading: Icon(Icons.account_balance_wallet_rounded),
                title: Text('GoPay'),
                subtitle: Text('Terhubung')),
            const ListTile(
                leading: Icon(Icons.account_balance_rounded),
                title: Text('Virtual Account BCA'),
                subtitle: Text('Terhubung')),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon,
      required this.label,
      this.danger = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final warna = danger ? Colors.red : Colors.grey.shade800;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: warna),
          title: Text(label,
              style: TextStyle(
                  color: warna, fontWeight: FontWeight.w600, fontSize: 13.5)),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ),
      ),
    );
  }
}
