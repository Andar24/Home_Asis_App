import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Tab Riwayat (Mitra Pekerja)
// -----------------------------------------------------------------------
// Menampilkan pekerjaan selesai/dibatalkan beserta pendapatan bersih
// setelah dipotong biaya layanan 10% (BR-1).
// =======================================================================
class WorkerHistoryTab extends StatelessWidget {
  const WorkerHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final workerId = appState.currentWorker.id;
    final riwayat = appState
        .bookingsForWorker(workerId)
        .where((b) =>
            b.status == BookingStatus.completed ||
            b.status == BookingStatus.cancelled)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final totalBersih = riwayat
        .where((b) => b.status == BookingStatus.completed)
        .fold<int>(
            0, (sum, b) => sum + (b.serviceFee - (b.serviceFee * 0.1).round()));

    return Scaffold(
      appBar: AppBar(
          title: const Text('Riwayat Pekerjaan',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SoftCard(
              child: Row(
                children: [
                  const Icon(Icons.payments_rounded, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total pendapatan bersih',
                            style: TextStyle(
                                fontSize: 11.5, color: Colors.grey.shade600)),
                        Text(formatRupiahRibuan(totalBersih),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  Text('setelah potongan 10%\n(BR-1)',
                      textAlign: TextAlign.right,
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ),
          Expanded(
            child: riwayat.isEmpty
                ? const EmptyState(
                    icon: Icons.history_rounded,
                    title: 'Belum ada riwayat',
                    message: 'Pekerjaan yang selesai akan tercatat di sini.')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: riwayat.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final b = riwayat[index];
                      final bersih =
                          b.serviceFee - (b.serviceFee * 0.1).round();
                      return SoftCard(
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
                            Text('Pelanggan: ${b.customerName}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                            Text(formatTanggalSingkat(b.scheduledDate),
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade500)),
                            if (b.status == BookingStatus.completed) ...[
                              const SizedBox(height: 8),
                              Text(
                                  'Pendapatan bersih: ${formatRupiahRibuan(bersih)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5)),
                            ],
                            if (b.review != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RatingStars(
                                      rating: b.review!.rating.toDouble(),
                                      size: 13),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '"${b.review!.text}"',
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
}
