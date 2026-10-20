import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../admin/admin_dashboard_page.dart';
import '../customer/customer_shell.dart';
import '../worker/worker_shell.dart';
import 'otp_page.dart';

// =======================================================================
// HOME_ASIS - Halaman Pendaftaran (Register)
// -----------------------------------------------------------------------
// REQ-1 (High): "Sistem harus menyediakan antarmuka pendaftaran untuk tiga
// peran berbeda (Pelanggan, Pekerja, Admin internal)". Admin tidak
// disediakan formulir publik karena bersifat internal (SRS 2.3), sehingga
// halaman ini hanya menyediakan opsi Pelanggan & Mitra Pekerja.
//
// UI-1.2: "Formulir pendaftaran untuk pekerja harus mencakup pilihan
// kategori keahlian dari sembilan kategori yang tersedia."
// VAL-1.1 s.d. VAL-1.3: validasi format email, kata sandi, dan telepon.
// =======================================================================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _identitasController = TextEditingController();
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
    _identitasController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    _tarifController.dispose();
    super.dispose();
  }

  Future<void> _daftar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final berhasilOtp = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OtpPage(
            role: _peran, tujuanKontak: _identitasController.text.trim()),
      ),
    );
    if (berhasilOtp != true || !mounted) return;

    final appState = context.read<AppState>();
    Widget tujuan;
    if (_peran == UserRole.worker) {
      final worker = appState.registerWorker(
        name: _namaController.text.trim(),
        phone: _identitasController.text.trim(),
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
    final scheme = Theme.of(context).colorScheme;

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
                  controller: _identitasController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon / Email',
                    hintText: 'contoh: 0812xxxxxxx atau nama@email.com',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  validator: _validasiIdentitas, // VAL-1.1 & VAL-1.3
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
                  validator: _validasiPassword, // VAL-1.2
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
                    'Kategori Keahlian', // UI-1.2
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
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: scheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Setelah mendaftar, akun Anda perlu Verifikasi KTP (SRS 4.2) '
                            'sebelum dapat muncul di pencarian pelanggan.',
                            style: TextStyle(
                                fontSize: 11.5, color: scheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                PrimaryButton(label: 'Daftar & Kirim OTP', onPressed: _daftar),
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

  String? _validasiIdentitas(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Nomor telepon atau email wajib diisi';
    }
    final value = v.trim();
    final emailRegex =
        RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$'); // VAL-1.1 (disederhanakan)
    final teleponRegex = RegExp(r'^(08|\+62)\d{8,11}$'); // VAL-1.3
    if (!emailRegex.hasMatch(value) && !teleponRegex.hasMatch(value)) {
      return 'Format harus email valid atau telepon (08xx / +62xx)';
    }
    return null;
  }

  String? _validasiPassword(String? v) {
    if (v == null || v.length < 8) {
      return 'Kata sandi minimal 8 karakter'; // VAL-1.2
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
          color: aktif ? scheme.primary.withOpacity(0.1) : Colors.white,
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
