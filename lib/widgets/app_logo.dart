import 'package:flutter/material.dart';

// =======================================================================
// LOGO APLIKASI HOME_ASIS
// -----------------------------------------------------------------------
// Logo didesain sebagai "mark" (lambang) + "wordmark" (nama) yang bisa
// dipakai terpisah maupun bersamaan (dipakai di SplashPage & LoginPage
// agar identitas visual aplikasi konsisten).
//
// Konsep visual: rumah (Icons.home_rounded) sebagai representasi "Home",
// dipadu badge kecil berisi ikon kunci pas (Icons.handyman_rounded) di
// sudut kanan-bawah sebagai representasi "Asis" (asisten jasa/tukang).
// Gaya badge-di-sudut ini mengikuti tren ikon aplikasi modern (mis. gaya
// Duolingo/Gojek) yang ramai dipakai aplikasi jasa saat ini ("kekinian").
// =======================================================================

/// Lambang (mark) aplikasi berupa kotak membulat (squircle) bergradasi
/// dengan ikon rumah + badge kunci pas di sudut.
class AppLogoMark extends StatelessWidget {
  final double size;
  const AppLogoMark({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final badgeSize = size * 0.36;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Kotak utama dengan gradasi teal (identitas warna aplikasi)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary,
                  Color.lerp(scheme.primary, Colors.black, 0.28)!,
                ],
              ),
              borderRadius: BorderRadius.circular(size * 0.28),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.35),
                  blurRadius: size * 0.25,
                  offset: Offset(0, size * 0.10),
                ),
              ],
            ),
            child: Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: size * 0.56,
            ),
          ),
          // Badge kunci pas (representasi mitra pekerja / jasa)
          Positioned(
            right: -badgeSize * 0.12,
            bottom: -badgeSize * 0.12,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: const Color(0xFFFFA726), // oranye: aksen "aksi/jasa"
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: size * 0.035),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.handyman_rounded,
                color: Colors.white,
                size: badgeSize * 0.56,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nama aplikasi ("Home_Asis") dengan dua warna berbeda per suku kata
/// supaya wordmark terlihat modern & mudah diingat.
class AppWordmark extends StatelessWidget {
  final double fontSize;
  final Color primaryTextColor;
  final Color accentTextColor;
  const AppWordmark({
    super.key,
    this.fontSize = 26,
    this.primaryTextColor = Colors.white,
    this.accentTextColor = const Color(0xFFFFA726),
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
        children: [
          TextSpan(text: 'Home', style: TextStyle(color: primaryTextColor)),
          TextSpan(text: '_Asis', style: TextStyle(color: accentTextColor)),
        ],
      ),
    );
  }
}

/// Gabungan mark + wordmark tersusun vertikal, dipakai di SplashPage.
class AppLogoLockupVertical extends StatelessWidget {
  final double markSize;
  const AppLogoLockupVertical({super.key, this.markSize = 100});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogoMark(size: markSize),
        const SizedBox(height: 18),
        AppWordmark(fontSize: markSize * 0.30),
      ],
    );
  }
}
