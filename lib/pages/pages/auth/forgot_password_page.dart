import 'package:flutter/material.dart';

import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Lupa Kata Sandi
// -----------------------------------------------------------------------
// SRS 4.1.2: "Pengguna lupa kata sandi -> Sistem mengirimkan tautan reset
// kata sandi melalui email." Halaman ini hanya mensimulasikan pengiriman
// tautan (tidak ada email sungguhan yang terkirim).
// =======================================================================
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _terkirim = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _kirimTautan() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _terkirim = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: simpleAppBar('Lupa Kata Sandi'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _terkirim ? _buildSukses(scheme) : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Reset Kata Sandi Anda',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan email terdaftar. Kami akan mengirimkan tautan untuk membuat kata sandi baru.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Terdaftar',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
              if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v.trim())) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Kirim Tautan Reset', onPressed: _kirimTautan),
        ],
      ),
    );
  }

  Widget _buildSukses(ColorScheme scheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mark_email_read_rounded, size: 72, color: scheme.primary),
        const SizedBox(height: 20),
        const Text(
          'Tautan Terkirim!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Kami telah mengirimkan tautan reset kata sandi ke ${_emailController.text.trim()}. '
          'Silakan periksa kotak masuk Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
            label: 'Kembali ke Login',
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
