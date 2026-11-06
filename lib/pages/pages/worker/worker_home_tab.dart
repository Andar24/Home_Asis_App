import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import '../notifications_page.dart';
import 'ktp_verification_page.dart';
import 'worker_schedule_page.dart';

// =======================================================================
// HOME_ASIS - Tab Beranda (Mitra Pekerja)
// -----------------------------------------------------------------------
// Menggabungkan beberapa kebutuhan SRS: status verifikasi (4.2), toggle
// ketersediaan (mendukung 4.3 pencarian pelanggan), ringkasan statistik,
// dan pintasan ke Jadwal Mingguan (4.5).
// =======================================================================
class WorkerHomeTab extends StatelessWidget {
  const WorkerHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final worker = appState.currentWorker;
    final scheme = Theme.of(context).colorScheme;
    final pekerjaanSelesai = appState
        .bookingsForWorker(worker.id)
        .where((b) => b.status == BookingStatus.completed)
        .length;
    final pendapatan = appState
        .bookingsForWorker(worker.id)
        .where((b) => b.status == BookingStatus.completed)
        .fold<int>(
            0,
            (sum, b) =>
                sum +
                (b.serviceFee -
                    (b.serviceFee * 0.1).round())); // BR-1: potongan 10%
    final jadwalHariIni = appState.bookingsForWorker(worker.id).where((b) {
      final now = DateTime.now();
      return b.scheduledDate.year == now.year &&
          b.scheduledDate.month == now.month &&
          b.scheduledDate.day == now.day &&
          b.status != BookingStatus.cancelled;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Halo, ${worker.name.split(' ').first} 👋',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(worker.categoryName,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const NotificationsPage())),
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_none_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Icon(
                          worker.isAvailable
                              ? Icons.check_circle_rounded
                              : Icons.pause_circle_filled_rounded,
                          color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          worker.isAvailable
                              ? 'Anda sedang Tersedia untuk menerima pesanan'
                              : 'Anda sedang Tidak Tersedia',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Switch(
                        value: worker.isAvailable,
                        activeThumbColor: Colors.white,
                        onChanged: (v) =>
                            appState.setWorkerAvailability(worker.id, v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (worker.verificationStatus != VerificationStatus.verified)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SoftCard(
                child: Row(
                  children: [
                    Icon(Icons.verified_user_outlined,
                        color: worker.verificationStatus.color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${worker.verificationStatus.label}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                          Text(
                            worker.verificationStatus ==
                                    VerificationStatus.pending
                                ? 'Dokumen sedang ditinjau admin (maks. 1x24 jam).'
                                : 'Verifikasi wajib agar akun muncul di pencarian pelanggan (BIZ-2.1).',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    if (worker.verificationStatus != VerificationStatus.pending)
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    KtpVerificationPage(workerId: worker.id))),
                        child: const Text('Verifikasi'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Row(
              children: [
                Expanded(
                    child: StatCard(
                        icon: Icons.star_rounded,
                        value: worker.rating.toStringAsFixed(1),
                        label: 'Rating (${worker.reviewCount})',
                        color: Colors.amber)),
                const SizedBox(width: 12),
                Expanded(
                    child: StatCard(
                        icon: Icons.task_alt_rounded,
                        value: '$pekerjaanSelesai',
                        label: 'Pekerjaan Selesai',
                        color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(
                    child: StatCard(
                        icon: Icons.payments_rounded,
                        value: formatRupiahRibuan(pendapatan),
                        label: 'Pendapatan Bersih',
                        color: Colors.green)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionTitle(
            title: 'Jadwal Hari Ini',
            trailing: TextButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => WorkerSchedulePage(workerId: worker.id))),
              icon: const Icon(Icons.calendar_month_rounded, size: 16),
              label: const Text('Atur Jadwal'),
            ),
          ),
        ),
        if (jadwalHariIni.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Tidak ada jadwal untuk hari ini.',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey)),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.separated(
              itemCount: jadwalHariIni.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final b = jadwalHariIni[index];
                return SoftCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(formatJamSingkat(b.scheduledTime),
                            style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.customerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(b.categoryName,
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      BookingStatusPill(status: b.status),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
