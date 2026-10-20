import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import '../help_center_page.dart';
import '../login_page.dart';
import '../notifications_page.dart';
import '../privacy_policy_page.dart';
import 'ktp_verification_page.dart';

// =======================================================================
// HOME_ASIS - Tab Profil (Mitra Pekerja)
// -----------------------------------------------------------------------
// Menampilkan profil, kategori keahlian, tarif per jam, status verifikasi
// KTP (SRS 4.2), dan menu akun umum lainnya.
// =======================================================================
class WorkerProfileTab extends StatelessWidget {
  const WorkerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final worker = appState.currentWorker;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Profil',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          SoftCard(
            child: Column(
              children: [
                CircleAvatar(
                    radius: 34,
                    backgroundColor: worker.avatarColor,
                    child: Text(worker.initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                Text(worker.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(worker.categoryName,
                    style:
                        TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                VerificationStatusPill(status: worker.verificationStatus),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(
                        label: 'Rating',
                        value: worker.rating.toStringAsFixed(1)),
                    _Stat(label: 'Ulasan', value: '${worker.reviewCount}'),
                    _Stat(
                        label: 'Tarif/Jam',
                        value: formatRupiahRibuan(worker.pricePerHour)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (worker.verificationStatus != VerificationStatus.verified)
            _MenuTile(
              icon: Icons.verified_user_outlined,
              label: 'Verifikasi KTP',
              trailingText: worker.verificationStatus.label,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => KtpVerificationPage(workerId: worker.id))),
            ),
          _MenuTile(
            icon: Icons.badge_outlined,
            label: 'Informasi Kontak',
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Informasi Kontak'),
                content: Text(
                    'Nomor Telepon: ${worker.phone}\nKategori: ${worker.categoryName}'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tutup'))
                ],
              ),
            ),
          ),
          _MenuTile(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsPage())),
          ),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            label: 'Pusat Bantuan & FAQ',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpCenterPage())),
          ),
          _MenuTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Kebijakan Privasi',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
          ),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: 'Keluar Akun',
            danger: true,
            onTap: () => tampilkanKonfirmasiLogout(
                context, appState.logout, const LoginPage()),
          ),
          const SizedBox(height: 16),
          Text(
            'Saldo dapat ditarik minimal Rp50.000 dengan proses transfer maksimal 2x24 jam (BR-2).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final bool danger;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon,
      required this.label,
      this.trailingText,
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
          trailing: trailingText != null
              ? Text(trailingText!,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5))
              : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ),
      ),
    );
  }
}
