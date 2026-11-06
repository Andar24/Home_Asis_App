import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Blokir Pengguna
// -----------------------------------------------------------------------
// SAFE-4: "Sistem harus menyediakan fitur blokir pengguna (pelanggan dapat
// memblokir pekerja dan sebaliknya)." Mitra yang diblokir tidak akan
// muncul lagi pada hasil pencarian pelanggan (lihat AppState.searchableWorkers).
// =======================================================================
class BlockUsersPage extends StatelessWidget {
  const BlockUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: simpleAppBar('Blokir Pengguna'),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: appState.workers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final worker = appState.workers[index];
          return SoftCard(
            child: Row(
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
                              fontWeight: FontWeight.w600, fontSize: 13.5)),
                      Text(worker.categoryName,
                          style: TextStyle(
                              fontSize: 11.5, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    appState.toggleBlockWorker(worker.id);
                    showAppSnackBar(
                        context,
                        worker.isBlocked
                            ? '${worker.name} telah diblokir.'
                            : '${worker.name} tidak lagi diblokir.');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        worker.isBlocked ? Colors.red : Colors.grey.shade700,
                    side: BorderSide(
                        color: worker.isBlocked
                            ? Colors.red
                            : Colors.grey.shade400),
                  ),
                  child: Text(worker.isBlocked ? 'Buka Blokir' : 'Blokir'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
