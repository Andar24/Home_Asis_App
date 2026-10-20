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
// dikonfirmasi. SAFE-2: tombol "Laporan Darurat" wajib terlihat jelas di
// halaman detail pesanan aktif. BIZ-4.2/BR-3: aturan pembatalan berbeda
// tergantung status pesanan. BIZ-6.2: pelanggan mengonfirmasi selesai
// setelah mitra mengklaim pekerjaan rampung.
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

  Future<void> _laporanDarurat(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.emergency_share_rounded,
            color: Colors.red, size: 40),
        title: const Text('Laporan Darurat'),
        content: const Text(
          'Tim keamanan Home_Asis akan segera dihubungi (SAFE-2). '
          'Ini merupakan simulasi tampilan -- tidak ada panggilan sungguhan yang dikirim.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mengerti'),
            ),
          ),
        ],
      ),
    );
  }

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
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _laporanDarurat(context),
                  icon: const Icon(Icons.emergency_share_rounded,
                      color: Colors.red),
                  label: const Text('Laporan Darurat',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red)),
                ),
              ),
              if (booking.status == BookingStatus.pending ||
                  booking.status == BookingStatus.accepted) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _batalkanPesanan(context, booking),
                    child: const Text('Batalkan'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusStepper extends StatelessWidget {
  final BookingStatus status;
  final List<BookingStatus> tahapan;
  const _StatusStepper({required this.status, required this.tahapan});

  @override
  Widget build(BuildContext context) {
    final indexSekarang = tahapan.indexOf(status);
    return SoftCard(
      child: Row(
        children: List.generate(tahapan.length, (i) {
          final selesai = i <= indexSekarang;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (i > 0)
                      Expanded(
                          child: Divider(
                              color: selesai
                                  ? tahapan[i].color
                                  : Colors.grey.shade300,
                              thickness: 2)),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            selesai ? tahapan[i].color : Colors.grey.shade300,
                      ),
                    ),
                    if (i < tahapan.length - 1)
                      Expanded(
                          child: Divider(
                              color: i < indexSekarang
                                  ? tahapan[i].color
                                  : Colors.grey.shade300,
                              thickness: 2)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tahapan[i].label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9.5,
                      color: selesai ? Colors.black87 : Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }),
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
