import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Manajemen Pengguna (Admin)
// -----------------------------------------------------------------------
// REQ-10.1: "Admin harus dapat melakukan penangguhan (suspend) akun
// pengguna atau pekerja yang melanggar ketentuan layanan."
// =======================================================================
class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab>
    with SingleTickerProviderStateMixin {
  late final TabController _sub = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _sub.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TabBar(
            controller: _sub,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [Tab(text: 'Pelanggan'), Tab(text: 'Mitra Pekerja')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _sub,
            children: [
              ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: appState.customerAccounts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final c = appState.customerAccounts[index];
                  return SoftCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                            radius: 20, child: Text(c.name.substring(0, 1))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5)),
                              Text(c.email,
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        _tombolSuspend(
                          diblokir: c.isBlocked,
                          onTap: () {
                            appState.toggleBlockCustomer(c.id);
                            showAppSnackBar(
                                context,
                                c.isBlocked
                                    ? '${c.name} ditangguhkan.'
                                    : '${c.name} diaktifkan kembali.');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: appState.workers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final w = appState.workers[index];
                  return SoftCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                            radius: 20,
                            backgroundColor: w.avatarColor,
                            child: Text(w.initials,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5)),
                              Text(
                                  '${w.categoryName} • ${w.verificationStatus.label}',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        _tombolSuspend(
                          diblokir: w.isBlocked,
                          onTap: () {
                            appState.toggleBlockWorker(w.id);
                            showAppSnackBar(
                                context,
                                w.isBlocked
                                    ? '${w.name} ditangguhkan.'
                                    : '${w.name} diaktifkan kembali.');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tombolSuspend({required bool diblokir, required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: diblokir ? Colors.green.shade700 : Colors.red,
        side: BorderSide(color: diblokir ? Colors.green.shade700 : Colors.red),
      ),
      child: Text(diblokir ? 'Aktifkan' : 'Tangguhkan'),
    );
  }
}
