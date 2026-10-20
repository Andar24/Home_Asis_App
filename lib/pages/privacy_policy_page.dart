import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Kebijakan Privasi & Syarat Ketentuan
// -----------------------------------------------------------------------
// SRS 2.6: "Halaman web statis...Penjelasan pengumpulan data, penggunaan
// data, perlindungan data pribadi, dan hak pengguna." Mengacu pada UU PDP
// No. 27 Tahun 2022 (SRS 1.5 & Bab 6).
// =======================================================================
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _bagian = [
    (
      'Pengumpulan Data',
      'Home_Asis mengumpulkan data pribadi seperti nama, nomor telepon, email, lokasi (GPS), dan untuk mitra '
          'pekerja: dokumen KTP serta swafoto untuk keperluan verifikasi identitas (SRS 4.2).',
    ),
    (
      'Penggunaan Data',
      'Data digunakan untuk memproses pemesanan, menampilkan mitra terdekat, memfasilitasi pembayaran, dan '
          'meningkatkan kualitas layanan. Data tidak dibagikan ke pihak ketiga tanpa persetujuan pengguna.',
    ),
    (
      'Perlindungan Data Pribadi',
      'Kata sandi disimpan terenkripsi (bcrypt), dokumen KTP disimpan pada storage aman dengan akses terbatas dan '
          'dienkripsi (AES-256), sesuai SEC-3. Seluruh komunikasi menggunakan protokol HTTPS (TLS 1.2+).',
    ),
    (
      'Hak Pengguna',
      'Pengguna berhak mengakses, memperbarui, dan mengunduh salinan data pribadinya (data portability, SEC-6), '
          'serta mengajukan penghapusan akun sesuai dengan Undang-Undang Perlindungan Data Pribadi (UU PDP) No. 27 Tahun 2022.',
    ),
    (
      'Kontak',
      'Pertanyaan seputar privasi dapat disampaikan ke privacy@homeasis.id.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar('Kebijakan Privasi'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Kebijakan Privasi & Syarat Ketentuan Home_Asis',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text('Terakhir diperbarui: 10 Juni 2026',
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          ..._bagian.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.$1,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(b.$2,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade700,
                              height: 1.5)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
