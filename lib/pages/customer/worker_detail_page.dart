import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import 'booking_page.dart';

// =======================================================================
// HOME_ASIS - Detail Mitra Pekerja
// -----------------------------------------------------------------------
// SRS 4.3 & 4.7: menampilkan profil pekerja, status verifikasi (SRS 4.2),
// serta ulasan pelanggan sebelumnya (rating rata-rata & teks ulasan,
// REQ-7.3). Tombol "Pesan Sekarang" memulai SRS 4.4 Pemesanan Jasa.
// =======================================================================
class WorkerDetailPage extends StatelessWidget {
  final String workerId;
  const WorkerDetailPage({super.key, required this.workerId});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final worker = appState.findWorker(workerId);
    if (worker == null) {
      return Scaffold(
          appBar: simpleAppBar('Detail Mitra'),
          body: const Center(child: Text('Data tidak ditemukan.')));
    }
    final ulasan = appState.bookingsWithReviewFor(workerId);

    return Scaffold(
      appBar: simpleAppBar('Detail Mitra'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          SoftCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: worker.avatarColor,
                  child: Text(worker.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(worker.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(worker.categoryName,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                VerificationStatusPill(status: worker.verificationStatus),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatKecil(
                        label: 'Rating',
                        value: worker.rating.toStringAsFixed(1),
                        icon: Icons.star_rounded,
                        color: Colors.amber),
                    _StatKecil(
                        label: 'Ulasan',
                        value: '${worker.reviewCount}',
                        icon: Icons.reviews_rounded,
                        color: Colors.blueGrey),
                    _StatKecil(
                        label: 'Jarak',
                        value: '${worker.distanceKm} km',
                        icon: Icons.place_rounded,
                        color: Colors.redAccent),
                    _StatKecil(
                        label: 'Tarif',
                        value: formatRupiahRibuan(worker.pricePerHour),
                        icon: Icons.payments_rounded,
                        color: Colors.green),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Tentang Mitra'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(worker.bio,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
          ),
          const SectionTitle(
              title: 'Ulasan Pelanggan',
              subtitle: 'Rating dan review tidak dapat diubah setelah dikirim'),
          if (ulasan.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Belum ada ulasan untuk mitra ini.',
                  style:
                      TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
            )
          else
            ...ulasan.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            RatingStars(
                                rating: b.review!.rating.toDouble(), size: 14),
                            const SizedBox(width: 8),
                            Text(waktuRelatif(b.review!.createdAt),
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade500)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(b.review!.text,
                            style: const TextStyle(fontSize: 13)),
                        if (b.review!.workerReply != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.reply_rounded,
                                    size: 15, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                      'Balasan mitra: ${b.review!.workerReply}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          fontStyle: FontStyle.italic)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: PrimaryButton(
            label: worker.verificationStatus == VerificationStatus.verified
                ? 'Pesan Sekarang'
                : 'Mitra Belum Tersedia',
            icon: Icons.calendar_month_rounded,
            onPressed: worker.verificationStatus == VerificationStatus.verified
                ? () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BookingPage(workerId: worker.id)))
                : null,
          ),
        ),
      ),
    );
  }
}

class _StatKecil extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatKecil(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label,
            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
      ],
    );
  }
}
