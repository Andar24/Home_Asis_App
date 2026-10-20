import 'package:flutter/material.dart';

// =======================================================================
// HOME_ASIS - Fungsi bantu pemformatan (tanggal, jam, mata uang)
// -----------------------------------------------------------------------
// Ditulis manual (tanpa paket `intl`) agar dependensi proyek tetap
// ringkas, sesuai batasan ukuran aplikasi pada SRS 2.5.
// =======================================================================
const _namaHari = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu'
];
const _namaBulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String formatTanggalPanjang(DateTime date) {
  final hari = _namaHari[date.weekday - 1];
  final bulan = _namaBulan[date.month - 1];
  return '$hari, ${date.day} $bulan ${date.year}';
}

String formatTanggalSingkat(DateTime date) {
  final bulan = _namaBulan[date.month - 1].substring(0, 3);
  return '${date.day} $bulan ${date.year}';
}

String formatJamSingkat(TimeOfDay time) {
  final j = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$j.$m';
}

String formatRupiahRibuan(int nilaiRibuan) {
  final str = nilaiRibuan.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < str.length; i++) {
    final posFromEnd = str.length - i;
    buffer.write(str[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
  }
  return 'Rp${buffer.toString()}.000';
}

String waktuRelatif(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';
  return formatTanggalSingkat(time);
}
