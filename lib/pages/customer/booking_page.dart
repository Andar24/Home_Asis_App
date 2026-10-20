import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import 'booking_status_page.dart';

// =======================================================================
// HOME_ASIS - Formulir Pemesanan (Booking)
// -----------------------------------------------------------------------
// SRS 4.4 "Pemesanan Jasa (Booking)": REQ-4.1 (Booking ID unik),
// REQ-4.3 (rincian biaya transparan: jasa + admin), BIZ-5.1 (durasi
// minimum 1 jam). SRS 4.5 "Penjadwalan": REQ-5.1 mencegah double-booking
// (divalidasi lewat AppState.isSlotBentrok).
// =======================================================================
class BookingPage extends StatefulWidget {
  final String workerId;
  const BookingPage({super.key, required this.workerId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _tanggal;
  TimeOfDay? _jam;
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (hasil != null) setState(() => _tanggal = hasil);
  }

  Future<void> _pilihJam() async {
    final hasil =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (hasil != null) setState(() => _jam = hasil);
  }

  void _konfirmasi(BuildContext context) {
    if (_tanggal == null || _jam == null) {
      showAppSnackBar(context, 'Pilih tanggal dan jam terlebih dahulu.',
          error: true);
      return;
    }
    final appState = context.read<AppState>();
    final worker = appState.findWorker(widget.workerId)!;

    if (appState.isSlotBentrok(worker.id, _tanggal!, _jam!)) {
      showAppSnackBar(
          context, 'Slot waktu tidak tersedia. Silakan pilih jadwal lain.',
          error: true);
      return;
    }

    final booking = appState.createBooking(
        worker: worker,
        date: _tanggal!,
        time: _jam!,
        note: _catatanController.text.trim());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => BookingStatusPage(bookingId: booking.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final worker = appState.findWorker(widget.workerId)!;
    final scheme = Theme.of(context).colorScheme;
    final adminFee = (worker.pricePerHour * 0.1).round();
    final total = worker.pricePerHour + adminFee;

    return Scaffold(
      appBar: simpleAppBar('Pesan ${worker.categoryName}'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          SoftCard(
            child: Row(
              children: [
                CircleAvatar(
                    radius: 24,
                    backgroundColor: worker.avatarColor,
                    child: Text(worker.initials,
                        style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(worker.categoryName,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Pilih Jadwal'),
          SoftCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      Icon(Icons.calendar_today_rounded, color: scheme.primary),
                  title: const Text('Tanggal'),
                  subtitle: Text(_tanggal == null
                      ? 'Belum dipilih'
                      : formatTanggalPanjang(_tanggal!)),
                  trailing: TextButton(
                      onPressed: _pilihTanggal, child: const Text('Pilih')),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      Icon(Icons.access_time_rounded, color: scheme.primary),
                  title: const Text('Jam'),
                  subtitle: Text(
                      _jam == null ? 'Belum dipilih' : formatJamSingkat(_jam!)),
                  trailing: TextButton(
                      onPressed: _pilihJam, child: const Text('Pilih')),
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Catatan untuk Mitra (opsional)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Contoh: keran wastafel dapur bocor...'),
            ),
          ),
          const SectionTitle(title: 'Rincian Biaya'),
          SoftCard(
            child: Column(
              children: [
                _BarisBiaya(
                    label: 'Biaya jasa (min. 1 jam)',
                    value: formatRupiahRibuan(worker.pricePerHour)),
                const SizedBox(height: 6),
                _BarisBiaya(
                    label: 'Biaya admin (10%)',
                    value: formatRupiahRibuan(adminFee)),
                const Divider(height: 20),
                _BarisBiaya(
                    label: 'Total Estimasi',
                    value: formatRupiahRibuan(total),
                    tebal: true),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mitra memiliki waktu 30 menit untuk merespons pesanan ini. Pembatalan gratis sebelum mitra menerima (BR-3).',
                    style: TextStyle(fontSize: 11.5, color: scheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: PrimaryButton(
              label: 'Konfirmasi Pesanan',
              onPressed: () => _konfirmasi(context)),
        ),
      ),
    );
  }
}

class _BarisBiaya extends StatelessWidget {
  final String label;
  final String value;
  final bool tebal;
  const _BarisBiaya(
      {required this.label, required this.value, this.tebal = false});

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
