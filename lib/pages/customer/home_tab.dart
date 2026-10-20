import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import '../notifications_page.dart';
import 'worker_detail_page.dart';
import 'worker_list_page.dart';

// =======================================================================
// HOME_ASIS - Tab Beranda (Pelanggan)
// -----------------------------------------------------------------------
// SRS 4.3 "Pencarian Jasa": REQ-3.1 (grid kategori), REQ-3.2 (urutan
// jarak + rating), REQ-3.4 (pencarian teks bebas).
//
// Struktur widget (parent -> child):
// CustomerHomeTab (StatefulWidget)
// └── CustomScrollView
//     ├── _HeaderBeranda [sapaan, notifikasi, kolom pencarian]
//     ├── _SeksiKategori [ListView horizontal -> _ChipKategori x9]
//     ├── SectionTitle("Mitra Terdekat")
//     └── SliverList -> _KartuMitra (diurutkan skorRekomendasi)
// =======================================================================
class CustomerHomeTab extends StatefulWidget {
  const CustomerHomeTab({super.key});

  @override
  State<CustomerHomeTab> createState() => _CustomerHomeTabState();
}

class _CustomerHomeTabState extends State<CustomerHomeTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final hasilPencarian = appState.searchableWorkers(query: _query);
    final sedangMencari = _query.trim().isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HeaderBeranda(
            nama: appState.currentUserName,
            searchController: _searchController,
            onSearchChanged: (v) => setState(() => _query = v),
            onTapNotifikasi: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            ),
          ),
        ),
        if (!sedangMencari) ...[
          SliverToBoxAdapter(
              child: _SeksiKategori(
                  categories:
                      appState.categories.where((c) => c.isActive).toList())),
          const SliverToBoxAdapter(
            child: SectionTitle(
              title: 'Mitra Terdekat',
              subtitle: 'Diurutkan berdasarkan jarak (40%) & rating (60%)',
            ),
          ),
        ] else
          SliverToBoxAdapter(
            child: SectionTitle(
                title: 'Hasil pencarian "$_query"',
                subtitle: '${hasilPencarian.length} mitra ditemukan'),
          ),
        if (hasilPencarian.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.person_search_rounded,
              title: 'Tidak ada pekerja tersedia di area Anda',
              message: 'Coba ubah kata kunci pencarian atau kategori lain.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverList.separated(
              itemCount: hasilPencarian.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final worker = hasilPencarian[index];
                return _KartuMitra(
                  worker: worker,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => WorkerDetailPage(workerId: worker.id)),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// -------------------------------------------------------------------
// 1) HEADER: sapaan, lokasi, notifikasi, kolom pencarian
// -------------------------------------------------------------------
class _HeaderBeranda extends StatelessWidget {
  final String nama;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onTapNotifikasi;
  const _HeaderBeranda({
    required this.nama,
    required this.searchController,
    required this.onSearchChanged,
    required this.onTapNotifikasi,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${nama.split(' ').first} 👋',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.white70, size: 16),
                        SizedBox(width: 4),
                        Text('Jl. Merdeka No. 10, Medan',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onTapNotifikasi,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Cari jasa: listrik, AC, bersih-bersih...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// 2) SEKSI KATEGORI JASA (REQ-3.1: sembilan kategori, scroll horizontal)
// -------------------------------------------------------------------
class _SeksiKategori extends StatelessWidget {
  final List<ServiceCategory> categories;
  const _SeksiKategori({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Kategori Jasa'),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final kategori = categories[index];
              return _ChipKategori(
                kategori: kategori,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => WorkerListPage(category: kategori)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChipKategori extends StatelessWidget {
  final ServiceCategory kategori;
  final VoidCallback onTap;
  const _ChipKategori({required this.kategori, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(kategori.icon, color: scheme.primary),
            ),
            const SizedBox(height: 6),
            Text(
              kategori.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// 3) KARTU MITRA (daftar pekerja terdekat)
// -------------------------------------------------------------------
class _KartuMitra extends StatelessWidget {
  final WorkerProfile worker;
  final VoidCallback onTap;
  const _KartuMitra({required this.worker, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SoftCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: worker.avatarColor,
            child: Text(worker.initials,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(worker.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (worker.verificationStatus ==
                        VerificationStatus.verified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded,
                          size: 15, color: Color(0xFF1E88E5)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(worker.categoryName,
                    style:
                        TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(worker.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w600)),
                    Text(' (${worker.reviewCount})',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(width: 10),
                    Icon(Icons.place_outlined,
                        size: 15, color: Colors.grey.shade500),
                    const SizedBox(width: 2),
                    Text('${worker.distanceKm} km',
                        style: TextStyle(
                            fontSize: 12.5, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${formatRupiahRibuan(worker.pricePerHour)}/jam',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.primary),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Pesan', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
