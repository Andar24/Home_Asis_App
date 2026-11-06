import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Verifikasi KTP (Mitra Pekerja)
// -----------------------------------------------------------------------
// SRS 4.2 "Verifikasi KTP": REQ-2.1 (kompresi foto, disederhanakan),
// REQ-2.2 (OCR ekstraksi NIK & nama, disimulasikan), REQ-2.3 (liveness
// detection, disimulasikan), REQ-2.4 (dikirim ke antrean admin),
// VAL-2.1 (confidence score OCR minimal 70%), BIZ-2.2 (diproses maks.
// 1x24 jam). Karena ini prototipe UI, tidak ada akses kamera sungguhan --
// tombol "Ambil Foto" mensimulasikan hasil pengambilan gambar & OCR.
// =======================================================================
class KtpVerificationPage extends StatefulWidget {
  final String workerId;
  const KtpVerificationPage({super.key, required this.workerId});

  @override
  State<KtpVerificationPage> createState() => _KtpVerificationPageState();
}

class _KtpVerificationPageState extends State<KtpVerificationPage> {
  int _langkah = 0;
  bool _fotoKtpDiambil = false;
  bool _swafotoDiambil = false;
  bool _memproses = false;
  double _confidence = 0;

  final _nikController = TextEditingController();
  final _namaController = TextEditingController();

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _ambilFotoKtp() async {
    setState(() => _memproses = true);
    await Future.delayed(
        const Duration(milliseconds: 900)); // simulasi proses OCR
    if (!mounted) return;
    setState(() {
      _memproses = false;
      _fotoKtpDiambil = true;
      _confidence =
          0.86; // simulasi confidence score OCR (VAL-2.1: minimal 70%)
      _nikController.text =
          '12710108${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 12)}';
      _namaController.text =
          context.read<AppState>().currentWorker.name.toUpperCase();
    });
  }

  Future<void> _ambilSwafoto() async {
    setState(() => _memproses = true);
    await Future.delayed(
        const Duration(milliseconds: 900)); // simulasi liveness detection
    if (!mounted) return;
    setState(() {
      _memproses = false;
      _swafotoDiambil = true;
    });
  }

  void _kirimVerifikasi() {
    context.read<AppState>().submitKtpForVerification(
          widget.workerId,
          nik: _nikController.text.trim(),
          namaOcr: _namaController.text.trim(),
          confidence: _confidence,
        );
    showAppSnackBar(
        context, 'Dokumen dikirim ke admin. Diproses maksimal 1x24 jam.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final worker = appState.findWorker(widget.workerId)!;

    if (worker.verificationStatus == VerificationStatus.pending) {
      return Scaffold(
        appBar: simpleAppBar('Verifikasi KTP'),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top_rounded,
                  size: 56, color: VerificationStatus.pending.color),
              const SizedBox(height: 16),
              const Text('Sedang Ditinjau Admin',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                'Dokumen Anda sudah terkirim dan sedang diproses (maksimal 1x24 jam sesuai BIZ-2.2).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: simpleAppBar('Verifikasi KTP'),
      body: Stepper(
        currentStep: _langkah,
        onStepContinue: () {
          if (_langkah < 2) {
            setState(() => _langkah += 1);
          } else {
            _kirimVerifikasi();
          }
        },
        onStepCancel:
            _langkah == 0 ? null : () => setState(() => _langkah -= 1),
        controlsBuilder: (context, details) {
          final bisaLanjut = (_langkah == 0 && _fotoKtpDiambil) ||
              (_langkah == 1 && _swafotoDiambil) ||
              _langkah == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: bisaLanjut ? details.onStepContinue : null,
                    child: Text(_langkah == 2 ? 'Kirim ke Admin' : 'Lanjut'),
                  ),
                ),
                if (_langkah > 0) ...[
                  const SizedBox(width: 10),
                  OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Kembali')),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Foto KTP'),
            isActive: _langkah >= 0,
            state: _fotoKtpDiambil ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KotakFoto(
                  sudahDiambil: _fotoKtpDiambil,
                  memproses: _memproses,
                  icon: Icons.badge_outlined,
                  label: 'Foto KTP',
                  onTap: _ambilFotoKtp,
                ),
                if (_fotoKtpDiambil) ...[
                  const SizedBox(height: 14),
                  Text('Hasil OCR (REQ-2.2)',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  TextField(
                      controller: _nikController,
                      decoration: const InputDecoration(labelText: 'NIK')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: _namaController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Sesuai KTP')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Confidence score: ',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700)),
                      Text('${(_confidence * 100).round()}%',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _confidence >= 0.7
                                  ? Colors.green
                                  : Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _confidence,
                      minHeight: 8,
                      color: _confidence >= 0.7 ? Colors.green : Colors.red,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  Text('Minimal 70% agar dapat diproses otomatis (VAL-2.1).',
                      style: TextStyle(
                          fontSize: 10.5, color: Colors.grey.shade500)),
                ],
              ],
            ),
          ),
          Step(
            title: const Text('Swafoto'),
            isActive: _langkah >= 1,
            state: _swafotoDiambil ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KotakFoto(
                  sudahDiambil: _swafotoDiambil,
                  memproses: _memproses,
                  icon: Icons.face_retouching_natural_rounded,
                  label: 'Swafoto (Selfie)',
                  onTap: _ambilSwafoto,
                ),
                if (_swafotoDiambil) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                          child: Text(
                              'Liveness detection: wajah cocok dengan foto KTP (REQ-2.3).',
                              style: TextStyle(fontSize: 12))),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Step(
            title: const Text('Kirim untuk Ditinjau'),
            isActive: _langkah >= 2,
            content: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ringkasan Data',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  Text('NIK: ${_nikController.text}',
                      style: const TextStyle(fontSize: 12)),
                  Text('Nama: ${_namaController.text}',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    'Data akan dikirim ke antrean administrator untuk persetujuan final (REQ-2.4). '
                    'Proses maksimal 1x24 jam (BIZ-2.2).',
                    style:
                        TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KotakFoto extends StatelessWidget {
  final bool sudahDiambil;
  final bool memproses;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _KotakFoto(
      {required this.sudahDiambil,
      required this.memproses,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: memproses ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          color: sudahDiambil
              ? scheme.primary.withOpacity(0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: sudahDiambil ? scheme.primary : Colors.grey.shade300,
              style: BorderStyle.solid),
        ),
        child: Center(
          child: memproses
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(sudahDiambil ? Icons.check_circle_rounded : icon,
                        size: 36,
                        color: sudahDiambil
                            ? scheme.primary
                            : Colors.grey.shade500),
                    const SizedBox(height: 8),
                    Text(
                        sudahDiambil
                            ? '$label berhasil diambil'
                            : 'Ketuk untuk Ambil $label',
                        style: TextStyle(
                            fontSize: 12.5,
                            color: sudahDiambil
                                ? scheme.primary
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      ),
    );
  }
}
