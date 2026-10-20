import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Tab Pesanan (Mitra Pekerja)
// -----------------------------------------------------------------------
// SRS 4.4.2: pekerja menerima/menolak pesanan dalam 30 menit (BIZ-4.1).
// SRS 4.6.2: setelah dibayar (escrow), pekerja mengerjakan lalu menandai
// selesai untuk menunggu konfirmasi pelanggan (BIZ-6.2).
// =======================================================================
class WorkerOrdersTab extends StatefulWidget {
  const WorkerOrdersTab({super.key});

  @override
  State<WorkerOrdersTab> createState() => _WorkerOrdersTabState();
}

class _WorkerOrdersTabState extends State<WorkerOrdersTab> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Perbarui tampilan tiap detik agar hitung mundur 30 menit terlihat berjalan.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final workerId = appState.currentWorker.id;
    final semua = appState.bookingsForWorker(workerId);
    final menunggu =
        semua.where((b) => b.status == BookingStatus.pending).toList();
    final berjalan = semua
        .where((b) =>
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.ongoing)
        .toList();

    return Scaffold(
      appBar: AppBar(
          title: const Text('Pesanan Masuk',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: (menunggu.isEmpty && berjalan.isEmpty)
          ? const EmptyState(
              icon: Icons.assignment_outlined,
              title: 'Belum ada pesanan',
              message: 'Pesanan baru dari pelanggan akan muncul di sini.')
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                if (menunggu.isNotEmpty) ...[
                  const SectionTitle(
                      title: 'Menunggu Respon Anda',
                      subtitle: 'Respon maksimal 30 menit (BIZ-4.1)'),
                  ...menunggu.map((b) => _KartuMenunggu(booking: b)),
                ],
                if (berjalan.isNotEmpty) ...[
                  const SectionTitle(title: 'Sedang Berjalan'),
                  ...berjalan.map((b) => _KartuBerjalan(booking: b)),
                ],
              ],
            ),
    );
  }
}

class _KartuMenunggu extends StatelessWidget {
  final Booking booking;
  const _KartuMenunggu({required this.booking});

  @override
  Widget build(BuildContext context) {
    final sisa =
        booking.respondDeadline?.difference(DateTime.now()) ?? Duration.zero;
    final sisaAman = sisa.isNegative ? Duration.zero : sisa;
    final menit = sisaAman.inMinutes.toString().padLeft(2, '0');
    final detik = (sisaAman.inSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(booking.categoryName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14))),
                Icon(Icons.timer_outlined,
                    size: 15, color: Colors.orange.shade700),
                const SizedBox(width: 4),
                Text('$menit:$detik',
                    style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Pelanggan: ${booking.customerName}',
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
            Text(
                '${formatTanggalSingkat(booking.scheduledDate)} • ${formatJamSingkat(booking.scheduledTime)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            if (booking.note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('"${booking.note}"',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatRupiahRibuan(booking.totalFee),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => context
                          .read<AppState>()
                          .respondBooking(booking.id, false),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red)),
                      child: const Text('Tolak'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => context
                          .read<AppState>()
                          .respondBooking(booking.id, true),
                      child: const Text('Terima'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KartuBerjalan extends StatelessWidget {
  final Booking booking;
  const _KartuBerjalan({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(booking.categoryName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14))),
                BookingStatusPill(status: booking.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Pelanggan: ${booking.customerName}',
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
            Text(
                '${formatTanggalSingkat(booking.scheduledDate)} • ${formatJamSingkat(booking.scheduledTime)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 10),
            if (booking.status == BookingStatus.accepted)
              Text('Menunggu pelanggan menyelesaikan pembayaran...',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600))
            else if (!booking.workerClaimedDone)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<AppState>().workerClaimDone(booking.id);
                    showAppSnackBar(context,
                        'Pelanggan telah diberi notifikasi untuk konfirmasi.');
                  },
                  icon: const Icon(Icons.task_alt_rounded, size: 18),
                  label: const Text('Tandai Pekerjaan Selesai'),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('Menunggu konfirmasi pelanggan...',
                    style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
