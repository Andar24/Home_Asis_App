import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Verifikasi OTP
// -----------------------------------------------------------------------
// SRS 4.1.2 (Stimulus/Respon): "Pengguna mengisi data dan mengirimkan OTP"
// -> "Sistem mengirimkan kode OTP ke email/telepon" -> "Pengguna memasukkan
// OTP yang valid -> Sistem mencatat pengguna...". Dipakai baik saat
// registrasi maupun saat memilih "Masuk dengan Kode OTP" pada LoginPage.
//
// Halaman ini murni tampilan: kode apa pun sepanjang 6 digit dianggap
// valid (tidak ada pengiriman SMS/email sungguhan).
// =======================================================================
class OtpPage extends StatefulWidget {
  final UserRole role;
  final String? tujuanKontak;
  const OtpPage({super.key, required this.role, this.tujuanKontak});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _sisaDetik = 30;

  @override
  void initState() {
    super.initState();
    _mulaiHitungMundur();
  }

  void _mulaiHitungMundur() {
    _sisaDetik = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sisaDetik == 0) {
        timer.cancel();
      } else {
        setState(() => _sisaDetik--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _kodeGabungan => _controllers.map((c) => c.text).join();

  void _verifikasi() {
    if (_kodeGabungan.length < 6) {
      showAppSnackBar(context, 'Masukkan 6 digit kode OTP terlebih dahulu.',
          error: true);
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi OTP')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const AppLogoMark(size: 72),
              const SizedBox(height: 20),
              const Text(
                'Masukkan Kode OTP',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Kode 6 digit telah dikirim ke ${widget.tujuanKontak ?? "nomor/email Anda"} '
                '(simulasi -- masukkan angka apa saja).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 44,
                    height: 54,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(counterText: ''),
                      onChanged: (value) {
                        if (value.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        } else if (value.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                        setState(() {});
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Verifikasi', onPressed: _verifikasi),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _sisaDetik == 0
                    ? () {
                        _mulaiHitungMundur();
                        showAppSnackBar(
                            context, 'Kode OTP baru telah dikirim.');
                      }
                    : null,
                child: Text(
                  _sisaDetik == 0
                      ? 'Kirim ulang kode OTP'
                      : 'Kirim ulang dalam $_sisaDetik detik',
                  style: TextStyle(
                      color: _sisaDetik == 0 ? scheme.primary : Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
