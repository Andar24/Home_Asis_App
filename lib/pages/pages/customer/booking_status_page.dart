import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';
import 'customer_shell.dart';
import 'payment_page.dart';

// =======================================================================
// HOME_ASIS - Menunggu Konfirmasi Mitra Pekerja
// -----------------------------------------------------------------------
// SRS 4.4.2 (Stimulus/Respon): "Pekerja menerima pesanan dalam 30 menit ->
// Status berubah menjadi Diterima..."; BIZ-4.1 "Pekerja diberikan waktu
// respons maksimal 30 menit. Jika tidak ada respons, pesanan dibatalkan
// otomatis."
//
// Karena prototipe ini tidak memiliki proses worker terpisah yang selalu
// aktif, halaman ini menyediakan tombol demo agar penguji dapat
// mensimulasikan aksi mitra pekerja (Terima/Tolak) secara langsung, selain
// tetap bisa direspons sungguhan lewat WorkerOrdersTab bila diuji dengan
// login peran Mitra Pekerja secara terpisah.
// =======================================================================
class BookingStatusPage extends StatefulWidget {
  final String bookingId;
  const BookingStatusPage({super.key, required this.bookingId});

  @override
  State<BookingStatusPage> createState() => _BookingStatusPageState();
}

class _BookingStatusPageState extends State<BookingStatusPage> {
  Timer? _timer;
  Duration _sisaWaktu = const Duration(minutes: 30);
  bool _sudahNavigasi = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tickWaktu());
  }

  void _tickWaktu() {
    final appState = context.read<AppState>();
    final booking = appState.findBooking(widget.bookingId);
    if (booking?.respondDeadline == null) return;
    final sisa = booking!.respondDeadline!.difference(DateTime.now());
    setState(() => _sisaWaktu = sisa.isNegative ? Duration.zero : sisa);
    if (sisa.isNegative && booking.status == BookingStatus.pending) {
      appState.respondBooking(widget.bookingId, false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigasiSetelahRespons(Booking booking) {
    if (_sudahNavigasi) return;
    _sudahNavigasi = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (booking.status == BookingStatus.accepted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => PaymentPage(bookingId: booking.id)),
        );
      } else if (booking.status == BookingStatus.cancelled) {
        showAppSnackBar(
            context, 'Pesanan dibatalkan karena mitra tidak merespons/menolak.',
            error: true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CustomerShell()),
          (route) => false,
        );
      }
    });
  }

  String _formatDurasi(Duration d) {
    final menit = d.inMinutes.toString().padLeft(2, '0');
    final detik = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$menit:$detik';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final booking = appState.findBooking(widget.bookingId);
    if (booking == null) {
      return Scaffold(
          appBar: simpleAppBar('Status Pesanan'),
          body: const Center(child: Text('Pesanan tidak ditemukan.')));
    }

    if (booking.status != BookingStatus.pending) {
      _navigasiSetelahRespons(booking);
    }

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: simpleAppBar('Status Pesanan'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Icon(Icons.hourglass_top_rounded,
                    size: 56, color: scheme.primary),
              ),
              const SizedBox(height: 24),
              const Text('Menunggu Konfirmasi Mitra',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '${booking.workerName} memiliki waktu maksimal 30 menit untuk merespons pesanan ${booking.id}.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              Text(_formatDurasi(_sisaWaktu),
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary)),
              const Text('sisa waktu respons',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey)),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    Text(
                      'Mode Demo (tanpa backend nyata)',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Simulasikan respons mitra pekerja secara langsung, atau login sebagai Mitra Pekerja untuk merespons dari tab Pesanan.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                appState.respondBooking(booking.id, false),
                            child: const Text('Simulasikan Tolak'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                appState.respondBooking(booking.id, true),
                            child: const Text('Simulasikan Terima'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
