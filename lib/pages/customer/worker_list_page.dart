import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import 'worker_detail_page.dart';

// =======================================================================
// HOME_ASIS - Daftar Pekerja per Kategori
// -----------------------------------------------------------------------
// SRS 4.3: REQ-3.3 "filter dinamis (harga per jam/hari, rating minimum,
// jarak)". VAL-3.1 (radius maks 30km), VAL-3.2 (rating 1.0-5.0 kelipatan
// 0.5).
// =======================================================================
class WorkerListPage extends StatefulWidget {
  final ServiceCategory category;
  const WorkerListPage({super.key, required this.category});

  @override
  State<WorkerListPage> createState() => _WorkerListPageState();
}

class _WorkerListPageState extends State<WorkerListPage> {
  double _hargaMaks = 100;
  double _ratingMin = 1.0;
  double _radiusMaks = 30;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final hasil =
        appState.searchableWorkers(categoryId: widget.category.id).where((w) {
      return w.pricePerHour <= _hargaMaks &&
          w.rating >= _ratingMin &&
          w.distanceKm <= _radiusMaks;
    }).toList();

    return Scaffold(
      appBar: simpleAppBar(widget.category.name, actions: [
        IconButton(
            onPressed: _bukaFilter, icon: const Icon(Icons.tune_rounded)),
      ]),
      body: hasil.isEmpty
          ? const EmptyState(
              icon: Icons.person_search_rounded,
              title: 'Tidak ada pekerja tersedia di area Anda',
              message:
                  'Coba longgarkan filter harga, rating, atau radius pencarian.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: hasil.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final worker = hasil[index];
                return SoftCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => WorkerDetailPage(workerId: worker.id)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: worker.avatarColor,
                        child: Text(worker.initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(worker.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.5)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                RatingStars(rating: worker.rating, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                    '${worker.rating.toStringAsFixed(1)} (${worker.reviewCount})',
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.grey.shade600)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                                '${worker.distanceKm} km • ${formatRupiahRibuan(worker.pricePerHour)}/jam',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _bukaFilter() async {
    double harga = _hargaMaks;
    double rating = _ratingMin;
    double radius = _radiusMaks;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter Pencarian',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(
                    'Harga maksimal per jam: ${formatRupiahRibuan(harga.round())}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Slider(
                  value: harga,
                  min: 20,
                  max: 100,
                  divisions: 16,
                  label: formatRupiahRibuan(harga.round()),
                  onChanged: (v) => setSheetState(() => harga = v),
                ),
                Text('Rating minimum: ${rating.toStringAsFixed(1)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Slider(
                  value: rating,
                  min: 1.0,
                  max: 5.0,
                  divisions: 8, // VAL-3.2: kelipatan 0.5
                  label: rating.toStringAsFixed(1),
                  onChanged: (v) => setSheetState(() => rating = v),
                ),
                Text('Radius maksimal: ${radius.round()} km',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Slider(
                  value: radius,
                  min: 1,
                  max: 30, // VAL-3.1: radius maksimal 30km
                  divisions: 29,
                  label: '${radius.round()} km',
                  onChanged: (v) => setSheetState(() => radius = v),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Terapkan Filter',
                  onPressed: () {
                    setState(() {
                      _hargaMaks = harga;
                      _ratingMin = rating;
                      _radiusMaks = radius;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
