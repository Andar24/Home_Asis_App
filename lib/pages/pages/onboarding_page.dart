import 'package:flutter/material.dart';

import 'login_page.dart';

// =======================================================================
// HOME_ASIS - Onboarding (Panduan Interaktif Dalam-Aplikasi)
// -----------------------------------------------------------------------
// SRS 2.6 "Dokumentasi Pengguna": layar perkenalan yang tampil saat
// pertama kali aplikasi dibuka, menjelaskan fitur utama, cara mencari
// jasa, dan cara melakukan pembayaran.
// =======================================================================
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _SlideData {
  final IconData icon;
  final String title;
  final String description;
  const _SlideData(
      {required this.icon, required this.title, required this.description});
}

const _slides = [
  _SlideData(
    icon: Icons.travel_explore_rounded,
    title: 'Temukan Mitra Terdekat',
    description:
        'Cari tukang listrik, cleaning service, babysitter, dan 6 kategori jasa lain di sekitar lokasi Anda.',
  ),
  _SlideData(
    icon: Icons.event_available_rounded,
    title: 'Pesan Sesuai Jadwal Anda',
    description:
        'Pilih tanggal & jam yang tersedia, lalu pantau status pesanan secara real-time.',
  ),
  _SlideData(
    icon: Icons.verified_user_rounded,
    title: 'Aman & Tepercaya',
    description:
        'Setiap mitra pekerja telah melalui verifikasi KTP, dan pembayaran ditahan (escrow) hingga layanan selesai.',
  ),
];

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _halaman = 0;

  void _lanjut() {
    if (_halaman == _slides.length - 1) {
      _keLogin();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _keLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
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
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _keLogin,
                child: const Text('Lewati'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _halaman = i),
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(slide.icon, size: 72, color: scheme.primary),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.grey.shade600,
                              height: 1.4),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final aktif = i == _halaman;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: aktif ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: aktif ? scheme.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _lanjut,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: Colors.white),
                  child: Text(_halaman == _slides.length - 1
                      ? 'Mulai Sekarang'
                      : 'Lanjut'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
