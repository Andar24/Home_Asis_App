import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import 'customer_shell.dart';

// =======================================================================
// HOME_ASIS - Halaman Pembayaran
// -----------------------------------------------------------------------
// SRS 4.6 "Pembayaran Online": REQ-6.1 (VA/E-Wallet/Kartu Kredit),
// REQ-6.2 (escrow), BIZ-6.1 (batas waktu 60 menit). Standar Penanganan
// Error (SRS 3.1): "Apabila gagal memproses pembayaran, tampilkan pesan:
// 'Pembayaran gagal. Silakan coba lagi atau gunakan metode lain.'"
// =======================================================================
class PaymentPage extends StatefulWidget {
  final String bookingId;
  const PaymentPage({super.key, required this.bookingId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _MetodeBayar {
  final String kelompok;
  final String nama;
  final IconData icon;
  const _MetodeBayar(this.kelompok, this.nama, this.icon);
}

const _metodePembayaran = [
  _MetodeBayar(
      'Virtual Account', 'Virtual Account BCA', Icons.account_balance_rounded),
  _MetodeBayar('Virtual Account', 'Virtual Account Mandiri',
      Icons.account_balance_rounded),
  _MetodeBayar(
      'Virtual Account', 'Virtual Account BRI', Icons.account_balance_rounded),
  _MetodeBayar(
      'Virtual Account', 'Virtual Account BNI', Icons.account_balance_rounded),
  _MetodeBayar('E-Wallet', 'GoPay', Icons.account_balance_wallet_rounded),
  _MetodeBayar('E-Wallet', 'OVO', Icons.account_balance_wallet_rounded),
  _MetodeBayar('E-Wallet', 'DANA', Icons.account_balance_wallet_rounded),
  _MetodeBayar(
      'Kartu', 'Kartu Kredit Visa/Mastercard', Icons.credit_card_rounded),
];

class _PaymentPageState extends State<PaymentPage> {
  String? _metodeTerpilih;
  bool _memproses = false;
  Timer? _timer;
  Duration _sisaWaktu = const Duration(minutes: 60);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_sisaWaktu.inSeconds > 0) _sisaWaktu -= const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDurasi(Duration d) {
    final j = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$j:$m:$s';
  }

  Future<void> _bayarSekarang() async {
    if (_metodeTerpilih == null) {
      showAppSnackBar(context, 'Pilih metode pembayaran terlebih dahulu.',
          error: true);
      return;
    }
    setState(() => _memproses = true);
    await Future.delayed(
        const Duration(milliseconds: 900)); // simulasi proses gateway
    if (!mounted) return;
    setState(() => _memproses = false);

    context.read<AppState>().payBooking(widget.bookingId, _metodeTerpilih!);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded,
            color: Color(0xFF2E7D32), size: 48),
        title: const Text('Pembayaran Berhasil'),
        content: const Text(
          'Dana Anda ditahan sistem (escrow) dan akan dirilis ke mitra setelah layanan selesai dikonfirmasi.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Lanjutkan'),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CustomerShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final booking = appState.findBooking(widget.bookingId);
    if (booking == null) {
      return Scaffold(
          appBar: simpleAppBar('Pembayaran'),
          body: const Center(child: Text('Pesanan tidak ditemukan.')));
    }
    final scheme = Theme.of(context).colorScheme;
    final kelompok = _metodePembayaran.map((e) => e.kelompok).toSet().toList();

    return Scaffold(
      appBar: simpleAppBar('Pembayaran'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: scheme.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Selesaikan pembayaran dalam ${_formatDurasi(_sisaWaktu)} (BIZ-6.1), jika tidak pesanan dibatalkan otomatis.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              children: [
                _BarisRingkasan(label: 'ID Pesanan', value: booking.id),
                const SizedBox(height: 6),
                _BarisRingkasan(label: 'Mitra', value: booking.workerName),
                const SizedBox(height: 6),
                _BarisRingkasan(
                    label: 'Biaya Jasa',
                    value: formatRupiahRibuan(booking.serviceFee)),
                const SizedBox(height: 6),
                _BarisRingkasan(
                    label: 'Biaya Admin',
                    value: formatRupiahRibuan(booking.adminFee)),
                const Divider(height: 20),
                _BarisRingkasan(
                    label: 'Total Bayar',
                    value: formatRupiahRibuan(booking.totalFee),
                    tebal: true),
              ],
            ),
          ),
          for (final grup in kelompok) ...[
            SectionTitle(title: grup),
            ..._metodePembayaran.where((m) => m.kelompok == grup).map((m) {
              final aktif = _metodeTerpilih == m.nama;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  onTap: () => setState(() => _metodeTerpilih = m.nama),
                  child: Row(
                    children: [
                      Icon(m.icon,
                          color: aktif ? scheme.primary : Colors.grey.shade500),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(m.nama,
                              style: const TextStyle(fontSize: 13.5))),
                      Radio<String>(
                        value: m.nama,
                        groupValue: _metodeTerpilih,
                        onChanged: (v) => setState(() => _metodeTerpilih = v),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: PrimaryButton(
            label: _memproses
                ? 'Memproses...'
                : 'Bayar Sekarang (${formatRupiahRibuan(booking.totalFee)})',
            onPressed: _memproses ? null : _bayarSekarang,
          ),
        ),
      ),
    );
  }
}

class _BarisRingkasan extends StatelessWidget {
  final String label;
  final String value;
  final bool tebal;
  const _BarisRingkasan(
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
        Flexible(child: Text(value, style: style, textAlign: TextAlign.right)),
      ],
    );
  }
}
