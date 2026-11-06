import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Verifikasi KTP (Admin)
// -----------------------------------------------------------------------
// SRS 4.10.2: "Admin membuka menu verifikasi KTP -> Sistem menampilkan
// antrean pekerja menunggu verifikasi." REQ-10.2: "Admin harus dapat
// melihat dan memvalidasi dokumen KTP yang diunggah pekerja."
// =======================================================================
class AdminVerificationTab extends StatelessWidget {
  const AdminVerificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final antrean = appState.verificationQueue;

    if (antrean.isEmpty) {
      return const EmptyState(
        icon: Icons.fact_check_outlined,
        title: 'Tidak ada antrean verifikasi',
        message: 'Pengajuan KTP baru dari mitra pekerja akan muncul di sini.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: antrean.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final worker = antrean[index];
        final confidence = worker.ocrConfidence ?? 0;
        return SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                      radius: 22,
                      backgroundColor: worker.avatarColor,
                      child: Text(worker.initials,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(worker.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        Text(worker.categoryName,
                            style: TextStyle(
                                fontSize: 11.5, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  VerificationStatusPill(status: worker.verificationStatus),
                ],
              ),
              const Divider(height: 24),
              _baris('NIK (hasil OCR)', worker.nik ?? '-'),
              const SizedBox(height: 4),
              _baris('Nama (hasil OCR)', worker.ktpNamaOcr ?? '-'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Confidence score OCR: ',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  Text('${(confidence * 100).round()}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              confidence >= 0.7 ? Colors.green : Colors.red)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: confidence,
                  minHeight: 7,
                  color: confidence >= 0.7 ? Colors.green : Colors.red,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        appState.rejectVerification(worker.id);
                        showAppSnackBar(
                            context, 'Verifikasi ${worker.name} ditolak.');
                      },
                      icon: const Icon(Icons.close_rounded, color: Colors.red),
                      label: const Text('Tolak',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        appState.approveVerification(worker.id);
                        showAppSnackBar(
                            context, 'Verifikasi ${worker.name} disetujui.');
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Setujui'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _baris(String label, String value) {
    return Row(
      children: [
        SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
