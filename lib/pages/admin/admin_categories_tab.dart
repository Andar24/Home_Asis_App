import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Kelola Kategori Layanan (Admin)
// -----------------------------------------------------------------------
// REQ-10.4: "Admin harus dapat mengelola kategori layanan (menambah,
// mengedit, menonaktifkan kategori)."
// =======================================================================
class AdminCategoriesTab extends StatelessWidget {
  const AdminCategoriesTab({super.key});

  Future<void> _editNama(BuildContext context, AppState appState, String id,
      String namaAwal) async {
    final controller = TextEditingController(text: namaAwal);
    final hasil = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ubah Nama Kategori'),
        content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nama Kategori')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (hasil != null && hasil.isNotEmpty) {
      appState.renameCategory(id, hasil);
    }
  }

  Future<void> _tambahKategori(BuildContext context, AppState appState) async {
    final controller = TextEditingController();
    final hasil = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Kategori Baru'),
        content: TextField(
            controller: controller,
            decoration: const InputDecoration(
                labelText: 'Nama Kategori', hintText: 'Contoh: Jasa Pijat')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Tambah')),
        ],
      ),
    );
    if (hasil != null && hasil.isNotEmpty) {
      appState.addCategory(hasil, Icons.miscellaneous_services_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tambahKategori(context, appState),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: appState.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final kategori = appState.categories[index];
          return SoftCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(kategori.icon,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(kategori.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13.5)),
                ),
                IconButton(
                  tooltip: 'Ubah nama',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () =>
                      _editNama(context, appState, kategori.id, kategori.name),
                ),
                Switch(
                  value: kategori.isActive,
                  onChanged: (_) => appState.toggleCategoryActive(kategori.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
