import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import 'order_detail_page.dart';

// =======================================================================
// HOME_ASIS - Tab Pesanan Aktif (Pelanggan)
// -----------------------------------------------------------------------
// Menampilkan pesanan yang masih berjalan: menunggu konfirmasi, menunggu
// pembayaran, dan sedang dikerjakan (SRS 4.4 & 4.5).
// =======================================================================
class CustomerOrdersTab extends StatelessWidget {
  const CustomerOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final aktif = appState.bookings
        .where((b) =>
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.ongoing)
        .toList();

    return Scaffold(
      appBar: AppBar(
          title: const Text('Pesanan Aktif',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: aktif.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'Belum ada pesanan aktif',
              message: 'Pesanan yang sedang berjalan akan muncul di sini.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: aktif.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = aktif[index];
                return SoftCard(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => OrderDetailPage(bookingId: b.id))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(b.categoryName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5)),
                          ),
                          BookingStatusPill(status: b.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Mitra: ${b.workerName}',
                          style: TextStyle(
                              fontSize: 12.5, color: Colors.grey.shade700)),
                      const SizedBox(height: 2),
                      Text(
                          '${formatTanggalSingkat(b.scheduledDate)} • ${formatJamSingkat(b.scheduledTime)}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ID: ${b.id}',
                              style: TextStyle(
                                  fontSize: 10.5, color: Colors.grey.shade500)),
                          Text(formatRupiahRibuan(b.totalFee),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
