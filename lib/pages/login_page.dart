import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/common_widgets.dart';
import 'admin/admin_dashboard_page.dart';
import 'auth/forgot_password_page.dart';
import 'auth/otp_page.dart';
import 'auth/register_page.dart';
import 'customer/customer_shell.dart';
import 'worker/worker_shell.dart';

// =======================================================================
// HOME_ASIS - Halaman Login
// -----------------------------------------------------------------------
// Mengimplementasikan SRS 4.1 "Registrasi dan Login": pengguna masuk
// memakai nomor telepon/email + kata sandi, dengan opsi OTP, dan memilih
// salah satu dari tiga peran (REQ-1) untuk menentukan tampilan berikutnya
// (CustomerShell / WorkerShell / AdminDashboardPage). Karena ini adalah
// prototipe UI tanpa backend, "autentikasi" hanya memvalidasi form lalu
// menyimpan peran terpilih ke AppState (bukan JWT sungguhan).
//
// Struktur widget (garis besar, parent -> child):
//
// LoginPage (StatefulWidget)
// └── Scaffold
//     └── body: Stack
//         ├── _HeaderLengkung   (dekorasi gradasi + logo, bagian atas)
//         └── SafeArea > SingleChildScrollView
//             └── Column
//                 ├── _PemilihPeran (Pelanggan / Mitra Pekerja / Admin)
//                 ├── _KartuFormLogin (Container putih membulat)
//                 │     └── Form [identitas, password, ingat saya, tombol]
//                 └── Footer versi aplikasi
// =======================================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identitasController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _ingatSaya = true;
  UserRole _peranTerpilih = UserRole.customer;

  @override
  void dispose() {
    _identitasController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _masukKeBeranda(UserRole role) {
    final appState = context.read<AppState>();
    appState.login(role);
    Widget tujuan;
    switch (role) {
      case UserRole.customer:
        tujuan = const CustomerShell();
        break;
      case UserRole.worker:
        tujuan = const WorkerShell();
        break;
      case UserRole.admin:
        tujuan = const AdminDashboardPage();
        break;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => tujuan),
      (route) => false,
    );
  }

  void _prosesLogin() {
    // UI statis: validasi form hanya untuk menunjukkan interaksi, belum
    // terhubung ke backend/API autentikasi sungguhan (lihat SRS 4.1).
    if (_formKey.currentState?.validate() ?? false) {
      _masukKeBeranda(_peranTerpilih);
    }
  }

  Future<void> _masukDenganOtp() async {
    final berhasil = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => OtpPage(role: _peranTerpilih)),
    );
    if (berhasil == true && mounted) {
      _masukKeBeranda(_peranTerpilih);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const headerHeight = 220.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: Stack(
        children: [
          _HeaderLengkung(height: headerHeight, scheme: scheme),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: headerHeight - 74),
                  _PemilihPeran(
                    peranTerpilih: _peranTerpilih,
                    onChanged: (role) => setState(() => _peranTerpilih = role),
                  ),
                  const SizedBox(height: 14),
                  _KartuFormLogin(
                    formKey: _formKey,
                    identitasController: _identitasController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    ingatSaya: _ingatSaya,
                    onToggleObscure: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    onToggleIngat: (v) {
                      setState(() => _ingatSaya = v ?? true);
                    },
                    onLupaSandi: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage()),
                    ),
                    onMasuk: _prosesLogin,
                    onMasukOtp: _masukDenganOtp,
                    onDaftar: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Home_Asis v2.0.0',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 11.5),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// PEMILIH PERAN (Pelanggan / Mitra Pekerja / Admin) -- REQ-1
// -------------------------------------------------------------------
class _PemilihPeran extends StatelessWidget {
  final UserRole peranTerpilih;
  final ValueChanged<UserRole> onChanged;
  const _PemilihPeran({required this.peranTerpilih, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: UserRole.values.map((role) {
          final aktif = role == peranTerpilih;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: aktif ? scheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  role.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: aktif ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// -------------------------------------------------------------------
// HEADER LENGKUNG DEKORATIF (gradasi + logo kecil)
// -------------------------------------------------------------------
class _HeaderLengkung extends StatelessWidget {
  final double height;
  final ColorScheme scheme;
  const _HeaderLengkung({required this.height, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _LengkungClipper(),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              Color.lerp(scheme.primary, Colors.black, 0.30)!,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              children: [
                const AppLogoMark(size: 56),
                const SizedBox(height: 8),
                const AppWordmark(fontSize: 18),
                const SizedBox(height: 4),
                Text(
                  'Selamat datang kembali!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LengkungClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 46);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 46,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// -------------------------------------------------------------------
// KARTU FORM LOGIN
// -------------------------------------------------------------------
class _KartuFormLogin extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController identitasController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool ingatSaya;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onToggleIngat;
  final VoidCallback onLupaSandi;
  final VoidCallback onMasuk;
  final VoidCallback onMasukOtp;
  final VoidCallback onDaftar;

  const _KartuFormLogin({
    required this.formKey,
    required this.identitasController,
    required this.passwordController,
    required this.obscurePassword,
    required this.ingatSaya,
    required this.onToggleObscure,
    required this.onToggleIngat,
    required this.onLupaSandi,
    required this.onMasuk,
    required this.onMasukOtp,
    required this.onDaftar,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masuk ke Akun Anda',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Gunakan nomor telepon atau email terdaftar',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 22),

            // Nomor telepon / email (SRS 4.1: registrasi via nomor telepon/email)
            TextFormField(
              controller: identitasController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon / Email',
                hintText: 'contoh: 0812xxxxxxx atau nama@email.com',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nomor telepon atau email wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Kata sandi
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Kata Sandi',
                hintText: 'Masukkan kata sandi',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kata sandi wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 6),

            // Ingat saya + lupa sandi
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: ingatSaya,
                    onChanged: onToggleIngat,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Ingat saya', style: TextStyle(fontSize: 12.5)),
                const Spacer(),
                TextButton(
                  onPressed: onLupaSandi,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Lupa kata sandi?',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tombol masuk utama
            PrimaryButton(label: 'Masuk', onPressed: onMasuk),
            const SizedBox(height: 20),

            // Pemisah "atau"
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'atau masuk dengan',
                    style:
                        TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 16),

            // Masuk dengan OTP (sesuai SRS 4.1: validasi OTP)
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onMasukOtp,
                icon: const Icon(Icons.sms_outlined, size: 19),
                label: const Text('Masuk dengan Kode OTP'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.primary,
                  side: BorderSide(color: scheme.primary.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ajakan daftar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Belum punya akun?',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                ),
                TextButton(
                  onPressed: onDaftar,
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(left: 4)),
                  child: const Text(
                    'Daftar',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
