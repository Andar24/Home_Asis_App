import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../admin/admin_dashboard_page.dart';
import '../customer/customer_shell.dart';
import '../worker/worker_shell.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  final _tarifController = TextEditingController(text: '35');

  UserRole _peran = UserRole.customer;
  String _kategoriId = 'listrik';
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    _tarifController.dispose();
    super.dispose();
  }

  Future<void> _daftar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final appState = context.read<AppState>();
    Widget tujuan;

    if (_peran == UserRole.worker) {
      final worker = appState.registerWorker(
        name: _namaController.text.trim(),
        username: _usernameController.text.trim(),
        categoryId: _kategoriId,
        tarifPerJam: int.tryParse(_tarifController.text.trim()) ?? 35,
      );
      appState.login(UserRole.worker, name: worker.name, workerId: worker.id);
      tujuan = const WorkerShell();
    } else if (_peran == UserRole.customer) {
      appState.login(UserRole.customer, name: _namaController.text.trim());
      tujuan = const CustomerShell();
    } else {
      appState.login(UserRole.admin, name: _namaController.text.trim());
      tujuan = const AdminDashboardPage();
    }

    if (!mounted) return;

    showAppSnackBar(context,
        'Pendaftaran berhasil! Selamat datang, ${_namaController.text.trim()}.');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => tujuan), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: simpleAppBar('Buat Akun Baru'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Daftar sebagai apa?',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _KartuPilihanPeran(
                        label: 'Pelanggan',
                        icon: Icons.person_rounded,
                        aktif: _peran == UserRole.customer,
                        onTap: () => setState(() => _peran = UserRole.customer),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KartuPilihanPeran(
                        label: 'Mitra Pekerja',
                        icon: Icons.handyman_rounded,
                        aktif: _peran == UserRole.worker,
                        onTap: () => setState(() => _peran = UserRole.worker),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'contoh: user_baru atau budi123',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: _validasiUsername,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure1,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                      icon: Icon(_obscure1
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                    ),
                    helperText:
                        'Minimal 8 karakter, kombinasi huruf besar/kecil & angka',
                    helperMaxLines: 2,
                  ),
                  validator: _validasiPassword,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _konfirmasiController,
                  obscureText: _obscure2,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Kata Sandi',
                    prefixIcon: const Icon(Icons.lock_person_outlined),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                      icon: Icon(_obscure2
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                    ),
                  ),
                  validator: (v) => v != _passwordController.text
                      ? 'Konfirmasi kata sandi tidak cocok'
                      : null,
                ),
                if (_peran == UserRole.worker) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Kategori Keahlian',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _kategoriId,
                    items: appState.categories
                        .map((c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _kategoriId = v ?? _kategoriId),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined)),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _tarifController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tarif per Jam (ribuan rupiah)',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (v) => (v == null || int.tryParse(v) == null)
                        ? 'Masukkan angka tarif yang valid'
                        : null,
                  ),
                ],
                const SizedBox(height: 26),
                PrimaryButton(label: 'Daftar Sekarang', onPressed: _daftar),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Sudah punya akun? Masuk'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validasiUsername(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Username wajib diisi';
    }
    final value = v.trim();
    if (value.length < 4) {
      return 'Username minimal 4 karakter';
    }
    return null;
  }

  String? _validasiPassword(String? v) {
    if (v == null || v.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    final adaBesar = v.contains(RegExp(r'[A-Z]'));
    final adaKecil = v.contains(RegExp(r'[a-z]'));
    final adaAngka = v.contains(RegExp(r'[0-9]'));
    if (!adaBesar || !adaKecil || !adaAngka) {
      return 'Harus ada huruf besar, huruf kecil, dan angka';
    }
    return null;
  }
}

class _KartuPilihanPeran extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool aktif;
  final VoidCallback onTap;
  const _KartuPilihanPeran(
      {required this.label,
      required this.icon,
      required this.aktif,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: aktif ? scheme.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: aktif ? scheme.primary : Colors.grey.shade300,
              width: aktif ? 1.6 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: aktif ? scheme.primary : Colors.grey.shade500),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: aktif ? scheme.primary : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
