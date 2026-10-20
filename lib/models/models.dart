import 'package:flutter/material.dart';

// =======================================================================
// HOME_ASIS - Model Data
// -----------------------------------------------------------------------
// Seluruh kelas di file ini merepresentasikan entitas utama pada SRS
// Home_Asis (Lampiran C - Database Design): Users/Workers, Categories,
// Bookings, Payments, Reviews. Karena aplikasi ini adalah prototipe UI
// tanpa backend sungguhan, entitas disederhanakan menjadi model Dart biasa
// yang disimpan di memori (lihat lib/state/app_state.dart).
// =======================================================================

/// Tiga kelas pengguna sesuai SRS bab 2.3.
enum UserRole { customer, worker, admin }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.customer:
        return 'Pelanggan';
      case UserRole.worker:
        return 'Mitra Pekerja';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}

/// Status verifikasi KTP pekerja (SRS 4.2, kolom StatusVerifikasi).
enum VerificationStatus { unverified, pending, verified, rejected }

extension VerificationStatusLabel on VerificationStatus {
  String get label {
    switch (this) {
      case VerificationStatus.unverified:
        return 'Belum Verifikasi';
      case VerificationStatus.pending:
        return 'Menunggu Peninjauan';
      case VerificationStatus.verified:
        return 'Terverifikasi';
      case VerificationStatus.rejected:
        return 'Ditolak';
    }
  }

  Color get color {
    switch (this) {
      case VerificationStatus.unverified:
        return Colors.grey;
      case VerificationStatus.pending:
        return const Color(0xFFF9A825);
      case VerificationStatus.verified:
        return const Color(0xFF2E7D32);
      case VerificationStatus.rejected:
        return const Color(0xFFC62828);
    }
  }
}

/// Status pesanan (SRS 4.4 & Lampiran C, kolom StatusBooking).
enum BookingStatus { pending, accepted, ongoing, completed, cancelled }

extension BookingStatusLabel on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Menunggu Konfirmasi';
      case BookingStatus.accepted:
        return 'Menunggu Pembayaran';
      case BookingStatus.ongoing:
        return 'Sedang Dikerjakan';
      case BookingStatus.completed:
        return 'Selesai';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFF9A825);
      case BookingStatus.accepted:
        return const Color(0xFF1E88E5);
      case BookingStatus.ongoing:
        return const Color(0xFF00796B);
      case BookingStatus.completed:
        return const Color(0xFF2E7D32);
      case BookingStatus.cancelled:
        return const Color(0xFFC62828);
    }
  }
}

/// Jenis notifikasi (SRS 4.8).
enum NotificationType { pesanan, pembayaran, promo, sistem }

extension NotificationTypeMeta on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.pesanan:
        return Icons.receipt_long_rounded;
      case NotificationType.pembayaran:
        return Icons.account_balance_wallet_rounded;
      case NotificationType.promo:
        return Icons.local_offer_rounded;
      case NotificationType.sistem:
        return Icons.info_rounded;
    }
  }

  String get label {
    switch (this) {
      case NotificationType.pesanan:
        return 'Pesanan';
      case NotificationType.pembayaran:
        return 'Pembayaran';
      case NotificationType.promo:
        return 'Promo';
      case NotificationType.sistem:
        return 'Sistem';
    }
  }
}

/// Kategori jasa (SRS 1.4: sembilan kategori layanan utama).
class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  bool isActive;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.isActive = true,
  });
}

/// Profil Mitra Pekerja (SRS Lampiran C - tabel Workers).
class WorkerProfile {
  final String id;
  final String name;
  final String initials;
  final Color avatarColor;
  final String categoryId;
  final String categoryName;
  final String phone;
  final String bio;
  double rating;
  int reviewCount;
  final double distanceKm;
  final int pricePerHour; // dalam ribuan rupiah
  VerificationStatus verificationStatus;
  bool isAvailable;
  bool isBlocked;
  String? nik;
  String? ktpNamaOcr;
  double? ocrConfidence;
  String jamMulai;
  String jamSelesai;
  String jamIstirahatMulai;
  String jamIstirahatSelesai;

  WorkerProfile({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.categoryId,
    required this.categoryName,
    required this.phone,
    required this.bio,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.pricePerHour,
    this.verificationStatus = VerificationStatus.verified,
    this.isAvailable = true,
    this.isBlocked = false,
    this.nik,
    this.ktpNamaOcr,
    this.ocrConfidence,
    this.jamMulai = '08.00',
    this.jamSelesai = '17.00',
    this.jamIstirahatMulai = '12.00',
    this.jamIstirahatSelesai = '13.00',
  });

  /// Skor gabungan jarak (40%) & rating (60%) sesuai REQ-3.2.
  double get skorRekomendasi {
    final skorJarak =
        (30 - distanceKm.clamp(0, 30)) / 30; // makin dekat makin tinggi
    final skorRating = rating / 5.0;
    return (skorJarak * 0.4) + (skorRating * 0.6);
  }
}

/// Akun pelanggan dummy untuk kebutuhan manajemen pengguna Admin (REQ-10.1).
class CustomerAccount {
  final String id;
  final String name;
  final String email;
  final String phone;
  bool isBlocked;

  CustomerAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.isBlocked = false,
  });
}

/// Ulasan pasca-layanan (SRS 4.7, tabel Reviews).
class ReviewItem {
  final String bookingId;
  final int rating;
  final String text;
  final DateTime createdAt;
  String? workerReply;

  ReviewItem({
    required this.bookingId,
    required this.rating,
    required this.text,
    required this.createdAt,
    this.workerReply,
  });
}

/// Pesanan / Booking (SRS 4.4 & 4.5, tabel Bookings + Payments).
class Booking {
  final String id;
  final String workerId;
  final String workerName;
  final String categoryName;
  final String customerName;
  DateTime scheduledDate;
  TimeOfDay scheduledTime;
  BookingStatus status;
  final int serviceFee; // ribuan rupiah
  final int adminFee; // ribuan rupiah
  String note;
  bool isPaid;
  String? paymentMethod;
  bool workerClaimedDone;
  final DateTime createdAt;
  DateTime? respondDeadline;
  ReviewItem? review;

  Booking({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.categoryName,
    required this.customerName,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    required this.serviceFee,
    required this.adminFee,
    this.note = '',
    this.isPaid = false,
    this.paymentMethod,
    this.workerClaimedDone = false,
    required this.createdAt,
    this.respondDeadline,
    this.review,
  });

  int get totalFee => serviceFee + adminFee;
}

/// Notifikasi push (SRS 4.8, disimulasikan secara lokal tanpa FCM).
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;
  final UserRole targetRole;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.targetRole,
    this.isRead = false,
  });
}
