import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Laporan Transaksi (Admin)
// -----------------------------------------------------------------------
// REQ-10.3: "Admin harus dapat melihat laporan transaksi harian,
// mingguan, dan bulanan." Grafik batang dibuat memakai widget dasar
// (tanpa paket chart eksternal) agar dependensi aplikasi tetap ringkas.
// =======================================================================
class AdminReportsTab extends StatefulWidget {
  const AdminReportsTab({super.key});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

enum _Periode { harian, mingguan, bulanan }

class _AdminReportsTabState extends State<AdminReportsTab> {
  _Periode _periode = _Periode.mingguan;

  // Data dummy jumlah transaksi per periode (disederhanakan, bukan agregasi nyata).
  static const _dataHarian = [3, 5, 2, 6, 4, 7, 5];
  static const _labelHarian = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _dataMingguan = [18, 24, 20, 27];
  static const _labelMingguan = ['M1', 'M2', 'M3', 'M4'];
  static const _dataBulanan = [65, 72, 80, 74, 90, 95];
  static const _labelBulanan = ['Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep'];

  (List<int>, List<String>) get _dataAktif {
    switch (_periode) {
      case _Periode.harian:
        return (_dataHarian, _labelHarian);
      case _Periode.mingguan:
        return (_dataMingguan, _labelMingguan);
      case _Periode.bulanan:
        return (_dataBulanan, _labelBulanan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final (data, label) = _dataAktif;
    final maksimal = data.reduce((a, b) => a > b ? a : b).toDouble();
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
                child: StatCard(
                    icon: Icons.receipt_long_rounded,
                    value: '${appState.bookings.length}',
                    label: 'Total Transaksi',
                    color: Colors.indigo)),
            const SizedBox(width: 12),
            Expanded(
                child: StatCard(
                    icon: Icons.payments_rounded,
                    value: formatRupiahRibuan(appState.totalPendapatanBulanIni),
                    label: 'Total Pendapatan',
                    color: Colors.green)),
          ],
        ),
        const SectionTitle(title: 'Grafik Jumlah Transaksi'),
        SoftCard(
          child: Column(
            children: [
              Row(
                children: _Periode.values.map((p) {
                  final aktif = p == _periode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _periode = p),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: aktif ? scheme.primary : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          p.name[0].toUpperCase() + p.name.substring(1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color:
                                  aktif ? Colors.white : Colors.grey.shade700),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(data.length, (i) {
                    final tinggi = (data[i] / maksimal) * 110;
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${data[i]}',
                              style: const TextStyle(
                                  fontSize: 10.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: tinggi,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(label[i],
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade600)),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.orange, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                    'Data grafik bersifat simulasi untuk keperluan demonstrasi antarmuka.',
                    style: TextStyle(fontSize: 11.5, color: Colors.orange)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
