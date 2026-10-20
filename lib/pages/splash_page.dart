import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';
import 'onboarding_page.dart';

// =======================================================================
// HOME_ASIS - Splash / Loading Screen
// -----------------------------------------------------------------------
// Layar pembuka yang tampil saat aplikasi pertama kali dibuka, sebelum
// pengguna diarahkan ke halaman Login (lihat SRS bab 3, F-01 "Registrasi
// & Autentikasi"). Desain mengikuti prinsip UI "kekinian":
//  - Latar gradasi (bukan warna solid polos)
//  - Bentuk dekoratif "blob" melengkung di belakang logo (soft-shape trend)
//  - Logo & nama aplikasi muncul dengan animasi fade + scale
//  - Indikator loading custom (bukan CircularProgressIndicator polos)
//
// Setelah beberapa detik, layar otomatis berpindah ke LoginPage memakai
// transisi fade agar terasa halus (bukan perpindahan halaman yang kasar).
// =======================================================================

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _goToLoginAfterDelay();
  }

  Future<void> _goToLoginAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const OnboardingPage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              Color.lerp(scheme.primary, Colors.black, 0.35)!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Dekorasi blob melengkung di belakang (khas UI modern 2025+)
            Positioned(
              top: -70,
              right: -60,
              child: _Blob(size: 220, opacity: 0.10),
            ),
            Positioned(
              bottom: -90,
              left: -70,
              child: _Blob(size: 260, opacity: 0.10),
            ),
            Positioned(
              bottom: 120,
              right: -40,
              child: _Blob(size: 120, opacity: 0.08),
            ),

            // Konten utama: logo + nama + tagline + loading indicator
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: const AppLogoLockupVertical(markSize: 104),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeTransition(
                    opacity: _fade,
                    child: Text(
                      'Solusi jasa rumah tangga tepercaya',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  const _DotLoadingIndicator(),
                  const SizedBox(height: 14),
                  Text(
                    'Menyiapkan mitra terbaik untuk Anda...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bentuk lingkaran blur lembut sebagai elemen dekoratif latar belakang.
class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Indikator loading berupa 3 titik yang "berdenyut" bergantian --
/// alternatif yang lebih modern dibanding CircularProgressIndicator biasa.
class _DotLoadingIndicator extends StatefulWidget {
  const _DotLoadingIndicator();

  @override
  State<_DotLoadingIndicator> createState() => _DotLoadingIndicatorState();
}

class _DotLoadingIndicatorState extends State<_DotLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_controller.value - (i * 0.2)) % 1.0;
            final scale =
                0.55 + 0.45 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
