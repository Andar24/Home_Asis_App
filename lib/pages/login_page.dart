import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/common_widgets.dart';
import 'admin/admin_dashboard_page.dart';
import 'auth/forgot_password_page.dart';
import 'auth/register_page.dart';
import 'customer/customer_shell.dart';
import 'worker/worker_shell.dart';

// =======================================================================
// HOME_ASIS - Halaman Login (Otomatis Deteksi Role berdasarkan Username)
// =======================================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _ingatSaya = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _prosesLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final appState = context.read<AppState>();
      final success = appState.loginWithUsernamePassword(
        _usernameController.text,
        _passwordController.text,
      );

      if (!success) {
        showAppSnackBar(context, 'Username atau password salah', error: true);
        return;
      }

      final role = appState.currentRole;
      showAppSnackBar(context, 'Berhasil masuk sebagai ${role?.label ?? ''}!');

      Widget tujuan;
      switch (role) {
        case UserRole.worker:
          tujuan = const WorkerShell();
          break;
        case UserRole.admin:
          tujuan = const AdminDashboardPage();
          break;
        case UserRole.customer:
        default:
          tujuan = const CustomerShell();
          break;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => tujuan),
        (route) => false,
      );
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
                  const SizedBox(height: headerHeight - 40),
                  _KartuFormLogin(
                    formKey: _formKey,
                    usernameController: _usernameController,
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
                const AppLogoMark(size: 80),
                const SizedBox(height: 12),
                Text(
                  'Selamat datang kembali!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13.5,
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

class _KartuFormLogin extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool ingatSaya;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onToggleIngat;
  final VoidCallback onLupaSandi;
  final VoidCallback onMasuk;
  final VoidCallback onDaftar;

  const _KartuFormLogin({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.ingatSaya,
    required this.onToggleObscure,
    required this.onToggleIngat,
    required this.onLupaSandi,
    required this.onMasuk,
    required this.onDaftar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
              'Gunakan username dan kata sandi terdaftar',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Masukkan username',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Username wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            PrimaryButton(label: 'Masuk', onPressed: onMasuk),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Belum punya akun?',
                  style:
                      TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
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
