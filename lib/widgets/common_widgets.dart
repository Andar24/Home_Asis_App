import 'package:flutter/material.dart';

import '../models/models.dart';

// =======================================================================
// HOME_ASIS - Widget Bersama (Reusable)
// -----------------------------------------------------------------------
// Kumpulan widget kecil yang dipakai berulang kali di berbagai layar agar
// method build() pada setiap halaman tetap ringkas dan konsisten secara
// visual (satu tanggung jawab per widget).
// =======================================================================

/// Judul seksi + subjudul opsional, dipakai di banyak layar.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionTitle(
      {super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Label kecil berwarna untuk menampilkan status (pesanan/verifikasi).
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class BookingStatusPill extends StatelessWidget {
  final BookingStatus status;
  const BookingStatusPill({super.key, required this.status});
  @override
  Widget build(BuildContext context) =>
      StatusPill(label: status.label, color: status.color);
}

class VerificationStatusPill extends StatelessWidget {
  final VerificationStatus status;
  const VerificationStatusPill({super.key, required this.status});
  @override
  Widget build(BuildContext context) =>
      StatusPill(label: status.label, color: status.color);
}

/// Deretan bintang rating (statis, non-interaktif) -- SRS 4.7.
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  const RatingStars({super.key, required this.rating, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon;
        if (rating >= i + 1) {
          icon = Icons.star_rounded;
        } else if (rating > i && rating < i + 1) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        return Icon(icon, size: size, color: Colors.amber);
      }),
    );
  }
}

/// Input bintang yang bisa disentuh untuk memilih rating (REQ-7 form ulasan).
class RatingInputStars extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;
  const RatingInputStars(
      {super.key,
      required this.value,
      required this.onChanged,
      this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < value;
        return IconButton(
          onPressed: () => onChanged(i + 1),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }
}

/// Kartu putih dengan bayangan lembut, dipakai sebagai wadah standar.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const SoftCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(14),
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
        borderRadius: BorderRadius.circular(16), onTap: onTap, child: card);
  }
}

/// Tampilan kosong (empty state) dipakai saat daftar data tidak ada.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Icon(icon, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

/// Kartu statistik kecil untuk dashboard (worker & admin).
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const StatCard(
      {super.key,
      required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

/// Tombol utama full-width dengan tinggi konsisten.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  const PrimaryButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
        label: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? scheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

void showAppSnackBar(BuildContext context, String message,
    {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? const Color(0xFFC62828) : null,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

/// AppBar sederhana dengan judul + tombol kembali konsisten di seluruh app.
PreferredSizeWidget simpleAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      actions: actions);
}

/// Dialog konfirmasi keluar akun + navigasi ke [tujuanLogin] (LoginPage),
/// dipakai bersama oleh halaman Profil Pelanggan maupun Mitra Pekerja.
Future<void> tampilkanKonfirmasiLogout(
    BuildContext context, VoidCallback onLogout, Widget tujuanLogin) async {
  final konfirmasi = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Keluar Akun'),
      content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal')),
        FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar')),
      ],
    ),
  );
  if (konfirmasi == true) {
    onLogout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => tujuanLogin),
        (route) => false,
      );
    }
  }
}
