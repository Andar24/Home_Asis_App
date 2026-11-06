import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import 'rating_review_page.dart';

// =======================================================================
// HOME_ASIS - Detail & Pelacakan Pesanan
// -----------------------------------------------------------------------
// SAFE-1: kontak pekerja/pelanggan disembunyikan sebelum pesanan
// dikonfirmasi. BIZ-4.2/BR-3: aturan pembatalan berbeda tergantung status
// pesanan. BIZ-6.2: pelanggan mengonfirmasi selesai setelah mitra mengklaim
// pekerjaan rampung.
// =======================================================================
class OrderDetailPage extends StatelessWidget {
  final String bookingId;
  const OrderDetailPage({super.key, required this.bookingId});

  static const _tahapan = [
    BookingStatus.pending,
    BookingStatus.accepted,
    BookingStatus.ongoing,
    BookingStatus.completed,
  ];

  Future<void> _batalkanPesanan(BuildContext context, Booking booking) async {
    final adaBiaya = booking.status == BookingStatus.accepted;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: Text(
          adaBiaya
              ? 'Mitra telah menerima pesanan ini. Pembatalan sekarang dikenakan biaya 10% dari total harga (BIZ-4.2).'
              : 'Pesanan dapat dibatalkan tanpa biaya karena mitra belum berangkat (BR-3).',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tidak')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya, Batalkan')),
        ],
      ),
    );
    if (konfirmasi == true && context.mounted) {
      context.read<AppState>().cancelBooking(booking.id);
      showAppSnackBar(context, 'Pesanan telah dibatalkan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final booking = appState.findBooking(bookingId);
    if (booking == null) {
      return Scaffold(
          appBar: simpleAppBar('Detail Pesanan'),
          body: const Center(child: Text('Pesanan tidak ditemukan.')));
    }
    final scheme = Theme.of(context).colorScheme;
    final kontakTerbuka = booking.status == BookingStatus.ongoing ||
        booking.status == BookingStatus.completed;

    return Scaffold(
      appBar: simpleAppBar('Detail Pesanan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          SoftCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(booking.id,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                BookingStatusPill(status: booking.status),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (booking.status != BookingStatus.cancelled)
            _StatusStepper(status: booking.status, tahapan: _tahapan),
          const SectionTitle(title: 'Informasi Mitra'),
          SoftCard(
            child: Row(
              children: [
                CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.primary,
                    child: const Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.workerName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(booking.categoryName,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Icon(Icons.phone_rounded,
                    color:
                        kontakTerbuka ? scheme.primary : Colors.grey.shade400),
              ],
            ),
          ),
          if (!kontakTerbuka)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Kontak mitra akan tersedia setelah pesanan dikonfirmasi & pembayaran selesai (SAFE-1).',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic),
              ),
            ),
          const SectionTitle(title: 'Jadwal & Catatan'),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${formatTanggalPanjang(booking.scheduledDate)} • ${formatJamSingkat(booking.scheduledTime)}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                if (booking.note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(booking.note,
                      style: TextStyle(
                          fontSize: 12.5, color: Colors.grey.shade700)),
                ],
              ],
            ),
          ),
          const SectionTitle(title: 'Rincian Biaya'),
          SoftCard(
            child: Column(
              children: [
                _Baris(
                    label: 'Biaya Jasa',
                    value: formatRupiahRibuan(booking.serviceFee)),
                const SizedBox(height: 6),
                _Baris(
                    label: 'Biaya Admin',
                    value: formatRupiahRibuan(booking.adminFee)),
                const Divider(height: 20),
                _Baris(
                    label: 'Total',
                    value: formatRupiahRibuan(booking.totalFee),
                    tebal: true),
                if (booking.isPaid) ...[
                  const SizedBox(height: 6),
                  _Baris(label: 'Metode', value: booking.paymentMethod ?? '-'),
                ],
              ],
            ),
          ),
          if (booking.status == BookingStatus.ongoing &&
              booking.workerClaimedDone)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    const Text('Mitra menandai pekerjaan telah selesai.',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 10),
                    PrimaryButton(
                      label: 'Konfirmasi Layanan Selesai',
                      color: const Color(0xFF2E7D32),
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () {
                        context
                            .read<AppState>()
                            .confirmBookingComplete(booking.id);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) =>
                                  RatingReviewPage(bookingId: booking.id)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          if (booking.status == BookingStatus.completed &&
              booking.review == null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: PrimaryButton(
                label: 'Beri Rating & Ulasan',
                icon: Icons.star_outline_rounded,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => RatingReviewPage(bookingId: booking.id))),
              ),
            ),
        ],
      ),
      bottomNavigationBar: (booking.status == BookingStatus.pending ||
              booking.status == BookingStatus.accepted)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _batalkanPesanan(context, booking),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batalkan Pesanan'),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _StatusStepper extends StatelessWidget {
  final BookingStatus status;
  final List<BookingStatus> tahapan;

  const _StatusStepper({required this.status, required this.tahapan});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeIndex = tahapan.indexOf(status);
    final isCancelled = status == BookingStatus.cancelled;

    if (isCancelled) return const SizedBox.shrink();

    const dotSize = 16.0;
    const inactiveColor = Color(0xFFE2E8F0);

    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stepWidth = constraints.maxWidth / tahapan.length;
              final lineY = dotSize / 2;

              return Stack(
                children: [
                  Positioned(
                    top: lineY - 1,
                    left: stepWidth / 2,
                    right: stepWidth / 2,
                    child: Container(
                      height: 2,
                      color: inactiveColor,
                    ),
                  ),
                  if (activeIndex > 0)
                    Positioned(
                      top: lineY - 1,
                      left: stepWidth / 2,
                      width: stepWidth *
                          (activeIndex.clamp(0, tahapan.length - 1)),
                      child: Container(
                        height: 2,
                        color: scheme.primary,
                      ),
                    ),
                  Row(
                    children: List.generate(tahapan.length, (index) {
                      final isCompleted = index < activeIndex;
                      final isCurrent = index == activeIndex;

                      return Expanded(
                        child: Center(
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isCompleted || isCurrent)
                                  ? scheme.primary
                                  : inactiveColor,
                              border: isCurrent
                                  ? Border.all(
                                      color:
                                          scheme.primary.withValues(alpha: 0.3),
                                      width: 4,
                                    )
                                  : null,
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 10,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(tahapan.length, (index) {
              final isCurrent = index == activeIndex;
              final isPassed = index <= activeIndex;

              return Expanded(
                child: Text(
                  tahapan[index].label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight:
                        isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent
                        ? scheme.primary
                        : (isPassed
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF94A3B8)),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Baris extends StatelessWidget {
  final String label;
  final String value;
  final bool tebal;
  const _Baris({required this.label, required this.value, this.tebal = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
        fontSize: tebal ? 15 : 13,
        fontWeight: tebal ? FontWeight.bold : FontWeight.normal);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: style.copyWith(color: tebal ? null : Colors.grey.shade700)),
        Text(value, style: style)
      ],
    );
  }
}
