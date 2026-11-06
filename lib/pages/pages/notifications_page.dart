import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Notifikasi
// -----------------------------------------------------------------------
// SRS 4.8 "Notifikasi": REQ-8.1/8.2 (notifikasi status pesanan &
// pembayaran, disimulasikan lokal tanpa Firebase Cloud Messaging).
// Dipakai bersama oleh Pelanggan maupun Mitra Pekerja (daftar disaring
// berdasarkan AppState.currentRole).
// =======================================================================
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final daftar = appState.notificationsForCurrentRole()
      ..sort((a, b) => b.time.compareTo(a.time));

    return Scaffold(
      appBar: simpleAppBar('Notifikasi', actions: [
        IconButton(
          tooltip: 'Pengaturan Notifikasi',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const NotificationSettingsPage())),
        ),
      ]),
      body: daftar.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Belum ada notifikasi',
              message: 'Notifikasi terbaru Anda akan muncul di sini.')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: daftar.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final n = daftar[index];
                return SoftCard(
                  onTap: () => appState.markNotificationRead(n.id),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            shape: BoxShape.circle),
                        child: Icon(n.type.icon,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(n.title,
                                      style: TextStyle(
                                          fontWeight: n.isRead
                                              ? FontWeight.w600
                                              : FontWeight.bold,
                                          fontSize: 13.5)),
                                ),
                                if (!n.isRead)
                                  Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(n.body,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade700)),
                            const SizedBox(height: 4),
                            Text(waktuRelatif(n.time),
                                style: TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

/// REQ-8.3: "Sistem harus menyediakan menu pengaturan notifikasi di
/// aplikasi (aktif/nonaktifkan per jenis notifikasi)."
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final Map<NotificationType, bool> _aktif = {
    for (final tipe in NotificationType.values) tipe: true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar('Pengaturan Notifikasi'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: NotificationType.values.map((tipe) {
          return SwitchListTile(
            secondary: Icon(tipe.icon),
            title: Text(tipe.label),
            value: _aktif[tipe] ?? true,
            onChanged: (v) => setState(() => _aktif[tipe] = v),
          );
        }).toList(),
      ),
    );
  }
}
