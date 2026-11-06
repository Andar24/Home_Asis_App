import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Penjadwalan Mitra Pekerja
// -----------------------------------------------------------------------
// SRS 4.5 "Penjadwalan": REQ-5.2 (tampilan kalender mingguan), REQ-5.3
// (jam operasional & istirahat), BIZ-5.2 (maksimal 8 jam kerja/hari),
// REQ-5.1 (mencegah double-booking, divalidasi di AppState.isSlotBentrok
// saat pelanggan membuat pesanan baru).
// =======================================================================
class WorkerSchedulePage extends StatefulWidget {
  final String workerId;
  const WorkerSchedulePage({super.key, required this.workerId});

  @override
  State<WorkerSchedulePage> createState() => _WorkerSchedulePageState();
}

class _WorkerSchedulePageState extends State<WorkerSchedulePage> {
  static const _namaHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  Future<void> _pilihJam(BuildContext context, String label, String nilaiAwal,
      ValueChanged<String> onPicked) async {
    final parts = nilaiAwal.split('.');
    final initial = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
    final hasil = await showTimePicker(
        context: context, initialTime: initial, helpText: label);
    if (hasil != null) {
      onPicked(
          '${hasil.hour.toString().padLeft(2, '0')}.${hasil.minute.toString().padLeft(2, '0')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final worker = appState.findWorker(widget.workerId)!;
    final scheme = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final awalMinggu = now.subtract(Duration(days: now.weekday - 1));
    final hariMinggu =
        List.generate(7, (i) => awalMinggu.add(Duration(days: i)));

    return Scaffold(
      appBar: simpleAppBar('Jadwal Mingguan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const SectionTitle(
              title: 'Kalender Minggu Ini',
              subtitle: 'Slot yang sudah terisi ditandai warna'),
          SoftCard(
            child: SizedBox(
              height: 190,
              child: Row(
                children: List.generate(7, (i) {
                  final hari = hariMinggu[i];
                  final slotHari = appState.bookings.where((b) =>
                      b.workerId == worker.id &&
                      b.status != BookingStatus.cancelled &&
                      b.scheduledDate.year == hari.year &&
                      b.scheduledDate.month == hari.month &&
                      b.scheduledDate.day == hari.day);
                  final isHariIni = hari.day == now.day &&
                      hari.month == now.month &&
                      hari.year == now.year;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isHariIni
                            ? scheme.primary.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(_namaHari[i],
                              style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade600)),
                          Text('${hari.day}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: slotHari
                                    .map((b) => Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3),
                                          decoration: BoxDecoration(
                                              color: b.status.color
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text(
                                            formatJamSingkat(b.scheduledTime),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 9,
                                                color: b.status.color,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SectionTitle(
              title: 'Jam Operasional',
              subtitle: 'Maksimal 8 jam kerja per hari (BIZ-5.2)'),
          SoftCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.wb_sunny_outlined),
                  title: const Text('Jam Mulai'),
                  trailing: TextButton(
                    onPressed: () =>
                        _pilihJam(context, 'Jam Mulai', worker.jamMulai, (v) {
                      appState.setJamOperasional(worker.id,
                          mulai: v,
                          selesai: worker.jamSelesai,
                          istirahatMulai: worker.jamIstirahatMulai,
                          istirahatSelesai: worker.jamIstirahatSelesai);
                    }),
                    child: Text(worker.jamMulai),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.nightlight_outlined),
                  title: const Text('Jam Selesai'),
                  trailing: TextButton(
                    onPressed: () => _pilihJam(
                        context, 'Jam Selesai', worker.jamSelesai, (v) {
                      appState.setJamOperasional(worker.id,
                          mulai: worker.jamMulai,
                          selesai: v,
                          istirahatMulai: worker.jamIstirahatMulai,
                          istirahatSelesai: worker.jamIstirahatSelesai);
                    }),
                    child: Text(worker.jamSelesai),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.free_breakfast_outlined),
                  title: const Text('Istirahat Mulai'),
                  trailing: TextButton(
                    onPressed: () => _pilihJam(
                        context, 'Istirahat Mulai', worker.jamIstirahatMulai,
                        (v) {
                      appState.setJamOperasional(worker.id,
                          mulai: worker.jamMulai,
                          selesai: worker.jamSelesai,
                          istirahatMulai: v,
                          istirahatSelesai: worker.jamIstirahatSelesai);
                    }),
                    child: Text(worker.jamIstirahatMulai),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.free_breakfast_rounded),
                  title: const Text('Istirahat Selesai'),
                  trailing: TextButton(
                    onPressed: () => _pilihJam(context, 'Istirahat Selesai',
                        worker.jamIstirahatSelesai, (v) {
                      appState.setJamOperasional(worker.id,
                          mulai: worker.jamMulai,
                          selesai: worker.jamSelesai,
                          istirahatMulai: worker.jamIstirahatMulai,
                          istirahatSelesai: v);
                    }),
                    child: Text(worker.jamIstirahatSelesai),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
