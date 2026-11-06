import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import 'order_detail_page.dart';

// =======================================================================
// HOME_ASIS - Tab Riwayat Transaksi (Pelanggan)
// -----------------------------------------------------------------------
// SRS 4.9 "Riwayat Transaksi": REQ-9.1 (filter status), REQ-9.2 (ringkasan
// biaya), REQ-9.3 (unduh PDF -- disimulasikan sebagai fitur mendatang
// karena berprioritas Low).
// =======================================================================
class CustomerHistoryTab extends StatefulWidget {
  const CustomerHistoryTab({super.key});

  @override
  State<CustomerHistoryTab> createState() => _CustomerHistoryTabState();
}

enum _FilterRiwayat { semua, selesai, dibatalkan, berjalan }

class _CustomerHistoryTabState extends State<CustomerHistoryTab> {
  _FilterRiwayat _filter = _FilterRiwayat.semua;

  bool _cocokFilter(Booking b) {
    switch (_filter) {
      case _FilterRiwayat.semua:
        return true;
      case _FilterRiwayat.selesai:
        return b.status == BookingStatus.completed;
      case _FilterRiwayat.dibatalkan:
        return b.status == BookingStatus.cancelled;
      case _FilterRiwayat.berjalan:
        return b.status == BookingStatus.pending ||
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.ongoing;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final riwayat = appState.bookings.where(_cocokFilter).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
          title: const Text('Riwayat Transaksi',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('Semua', _FilterRiwayat.semua),
                _chip('Selesai', _FilterRiwayat.selesai),
                _chip('Dibatalkan', _FilterRiwayat.dibatalkan),
                _chip('Berjalan', _FilterRiwayat.berjalan),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: riwayat.isEmpty
                ? const EmptyState(
                    icon: Icons.history_rounded,
                    title: 'Belum ada riwayat',
                    message: 'Transaksi Anda akan tercatat di sini.')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: riwayat.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = riwayat[index];
                      return SoftCard(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailPage(bookingId: b.id))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text(b.categoryName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14))),
                                BookingStatusPill(status: b.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                                '${b.workerName} • ${formatTanggalSingkat(b.scheduledDate)}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formatRupiahRibuan(b.totalFee),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                                TextButton.icon(
                                  onPressed: () => showAppSnackBar(context,
                                      'Fitur unduh PDF akan tersedia pada rilis mendatang.'),
                                  icon: const Icon(Icons.download_rounded,
                                      size: 16),
                                  label: const Text('PDF',
                                      style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(10, 30)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, _FilterRiwayat value) {
    final aktif = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: aktif,
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }
}
