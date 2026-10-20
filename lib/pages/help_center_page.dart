import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Pusat Bantuan & FAQ
// -----------------------------------------------------------------------
// SRS 2.6 "Dokumentasi Pengguna" -> Pusat Bantuan dan FAQ: "Panduan
// troubleshooting, kebijakan pembatalan, cara verifikasi KTP, kontak
// layanan pelanggan."
// =======================================================================
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  static const _faq = [
    (
      'Bagaimana cara memesan jasa?',
      'Pilih kategori jasa di Beranda, pilih mitra pekerja, tentukan tanggal & jam, lalu konfirmasi pesanan Anda.',
    ),
    (
      'Bagaimana kebijakan pembatalan pesanan?',
      'Pembatalan gratis jika dilakukan sebelum mitra menerima pesanan (BR-3). Setelah mitra menerima, pembatalan '
          'dikenakan biaya 10% dari total harga (BIZ-4.2).',
    ),
    (
      'Bagaimana cara verifikasi KTP untuk Mitra Pekerja?',
      'Buka menu Profil > Verifikasi Akun, ambil foto KTP dan swafoto. Tim admin akan meninjau dokumen dalam '
          'maksimal 1x24 jam (BIZ-2.2).',
    ),
    (
      'Kapan dana pembayaran diteruskan ke mitra?',
      'Dana ditahan sistem (escrow) dan dirilis ke mitra setelah pelanggan mengonfirmasi layanan selesai, atau '
          'otomatis 24 jam setelah mitra mengklaim selesai tanpa keberatan (BIZ-6.2).',
    ),
    (
      'Metode pembayaran apa saja yang tersedia?',
      'Virtual Account (BCA, Mandiri, BRI, BNI), E-Wallet (GoPay, OVO, DANA), dan Kartu Kredit (Visa/Mastercard).',
    ),
    (
      'Bagaimana jika saya mengalami situasi darurat saat layanan berlangsung?',
      'Gunakan tombol "Laporan Darurat" yang tersedia di halaman detail pesanan aktif untuk segera menghubungi tim keamanan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar('Pusat Bantuan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          SoftCard(
            child: Row(
              children: [
                const Icon(Icons.support_agent_rounded, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Butuh bantuan lebih lanjut?',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          'Hubungi layanan pelanggan di cs@homeasis.id atau 0800-1-234-567',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Pertanyaan yang Sering Diajukan'),
          ..._faq.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    title: Text(item.$1,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(item.$2,
                            style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade700,
                                height: 1.4)),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
