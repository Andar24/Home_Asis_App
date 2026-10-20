import 'package:flutter/material.dart';

import '../models/models.dart';

// =======================================================================
// HOME_ASIS - Data Dummy (Mock Data)
// -----------------------------------------------------------------------
// Menyediakan data awal (seed) untuk AppState. Sesuai ketentuan tugas,
// seluruh data bersifat statis/dummy -- tidak ada koneksi ke backend,
// PostgreSQL, Google Maps API, Midtrans, maupun Firebase sungguhan.
// =======================================================================
class MockData {
  MockData._();

  /// Sembilan kategori layanan utama (SRS 1.4).
  static List<ServiceCategory> categories() => [
        ServiceCategory(
            id: 'listrik',
            name: 'Tukang Listrik',
            icon: Icons.electrical_services_rounded),
        ServiceCategory(
            id: 'elektronik',
            name: 'Teknisi Elektronik',
            icon: Icons.tv_rounded),
        ServiceCategory(
            id: 'art',
            name: 'Pembantu Rumah Tangga',
            icon: Icons.emoji_people_rounded),
        ServiceCategory(
            id: 'kebun', name: 'Tukang Kebun', icon: Icons.yard_rounded),
        ServiceCategory(
            id: 'cleaning',
            name: 'Cleaning Service',
            icon: Icons.cleaning_services_rounded),
        ServiceCategory(
            id: 'ledeng', name: 'Tukang Ledeng', icon: Icons.plumbing_rounded),
        ServiceCategory(
            id: 'babysitter',
            name: 'Babysitter',
            icon: Icons.child_care_rounded),
        ServiceCategory(
            id: 'rumah',
            name: 'Teknisi Perbaikan Rumah',
            icon: Icons.handyman_rounded),
        ServiceCategory(
            id: 'laundry',
            name: 'Jasa Cuci & Setrika',
            icon: Icons.local_laundry_service_rounded),
      ];

  static List<WorkerProfile> workers() => [
        WorkerProfile(
          id: 'W1',
          name: 'Budi Santoso',
          initials: 'BS',
          avatarColor: const Color(0xFF00796B),
          categoryId: 'listrik',
          categoryName: 'Tukang Listrik',
          phone: '0812-3456-7890',
          bio:
              'Teknisi listrik rumah tangga & instalasi baru, pengalaman 8 tahun.',
          rating: 4.9,
          reviewCount: 132,
          distanceKm: 1.2,
          pricePerHour: 45,
          verificationStatus: VerificationStatus.verified,
        ),
        WorkerProfile(
          id: 'W2',
          name: 'Siti Rahma',
          initials: 'SR',
          avatarColor: const Color(0xFFEF6C00),
          categoryId: 'cleaning',
          categoryName: 'Cleaning Service',
          phone: '0813-2233-4455',
          bio:
              'Spesialis bersih-bersih rumah & apartemen, teliti dan tepat waktu.',
          rating: 4.8,
          reviewCount: 98,
          distanceKm: 2.4,
          pricePerHour: 35,
          verificationStatus: VerificationStatus.verified,
        ),
        WorkerProfile(
          id: 'W3',
          name: 'Agus Wijaya',
          initials: 'AW',
          avatarColor: const Color(0xFF5E35B1),
          categoryId: 'ledeng',
          categoryName: 'Tukang Ledeng',
          phone: '0821-9988-7766',
          bio: 'Perbaikan pipa bocor, instalasi kamar mandi, dan saluran air.',
          rating: 4.6,
          reviewCount: 54,
          distanceKm: 3.1,
          pricePerHour: 40,
          verificationStatus: VerificationStatus.verified,
        ),
        WorkerProfile(
          id: 'W4',
          name: 'Dewi Puspita',
          initials: 'DP',
          avatarColor: const Color(0xFFC2185B),
          categoryId: 'elektronik',
          categoryName: 'Teknisi Elektronik',
          phone: '0857-1122-3344',
          bio:
              'Servis AC, kulkas, mesin cuci, dan perangkat elektronik rumah tangga.',
          rating: 4.7,
          reviewCount: 76,
          distanceKm: 4.5,
          pricePerHour: 50,
          verificationStatus: VerificationStatus.verified,
        ),
        WorkerProfile(
          id: 'W5',
          name: 'Rahmat Hidayat',
          initials: 'RH',
          avatarColor: const Color(0xFF3949AB),
          categoryId: 'kebun',
          categoryName: 'Tukang Kebun',
          phone: '0878-5566-7788',
          bio: 'Perawatan taman, pangkas rumput, dan penataan tanaman hias.',
          rating: 4.5,
          reviewCount: 21,
          distanceKm: 5.6,
          pricePerHour: 30,
          verificationStatus: VerificationStatus.verified,
        ),
        WorkerProfile(
          id: 'W6',
          name: 'Ningsih Lestari',
          initials: 'NL',
          avatarColor: const Color(0xFF00838F),
          categoryId: 'babysitter',
          categoryName: 'Babysitter',
          phone: '0899-4433-2211',
          bio:
              'Pengasuh anak berpengalaman, bersertifikat pertolongan pertama.',
          rating: 4.9,
          reviewCount: 60,
          distanceKm: 2.0,
          pricePerHour: 38,
          verificationStatus: VerificationStatus.verified,
        ),
        WorkerProfile(
          id: 'W7',
          name: 'Joko Prasetyo',
          initials: 'JP',
          avatarColor: const Color(0xFF6D4C41),
          categoryId: 'rumah',
          categoryName: 'Teknisi Perbaikan Rumah',
          phone: '0812-7788-9900',
          bio: 'Perbaikan atap bocor, cat ulang dinding, dan renovasi ringan.',
          rating: 4.4,
          reviewCount: 15,
          distanceKm: 6.8,
          pricePerHour: 42,
          verificationStatus: VerificationStatus.pending,
          nik: '1271010203040005',
          ktpNamaOcr: 'JOKO PRASETYO',
          ocrConfidence: 0.86,
        ),
        WorkerProfile(
          id: 'W8',
          name: 'Yuli Andriani',
          initials: 'YA',
          avatarColor: const Color(0xFFAD1457),
          categoryId: 'laundry',
          categoryName: 'Jasa Cuci & Setrika',
          phone: '0813-0099-8877',
          bio: 'Cuci, kering, dan setrika rapi untuk kebutuhan rumah tangga.',
          rating: 4.8,
          reviewCount: 44,
          distanceKm: 1.8,
          pricePerHour: 28,
          verificationStatus: VerificationStatus.verified,
        ),
        WorkerProfile(
          id: 'W9',
          name: 'Sari Wulandari',
          initials: 'SW',
          avatarColor: const Color(0xFF558B2F),
          categoryId: 'art',
          categoryName: 'Pembantu Rumah Tangga',
          phone: '0819-6677-8899',
          bio: 'Membantu pekerjaan rumah harian, jujur dan berpengalaman.',
          rating: 4.3,
          reviewCount: 9,
          distanceKm: 7.9,
          pricePerHour: 32,
          verificationStatus: VerificationStatus.pending,
          nik: '1271010203040009',
          ktpNamaOcr: 'SARI WULANDARI',
          ocrConfidence: 0.74,
        ),
      ];

  static List<CustomerAccount> customers() => [
        CustomerAccount(
            id: 'C1',
            name: 'Rani Permatasari',
            email: 'rani@email.com',
            phone: '0812-1111-2222'),
        CustomerAccount(
            id: 'C2',
            name: 'Andra Saputra',
            email: 'andra@email.com',
            phone: '0813-3333-4444'),
        CustomerAccount(
            id: 'C3',
            name: 'Melati Kusuma',
            email: 'melati@email.com',
            phone: '0821-5555-6666'),
        CustomerAccount(
            id: 'C4',
            name: 'Fajar Nugraha',
            email: 'fajar@email.com',
            phone: '0857-7777-8888',
            isBlocked: true),
      ];

  static List<Booking> bookings() {
    final now = DateTime.now();
    return [
      Booking(
        id: 'HOMS17490001',
        workerId: 'W2',
        workerName: 'Siti Rahma',
        categoryName: 'Cleaning Service',
        customerName: 'Rani Permatasari',
        scheduledDate: now.subtract(const Duration(days: 6)),
        scheduledTime: const TimeOfDay(hour: 9, minute: 0),
        status: BookingStatus.completed,
        serviceFee: 70,
        adminFee: 7,
        isPaid: true,
        paymentMethod: 'GoPay',
        workerClaimedDone: true,
        createdAt: now.subtract(const Duration(days: 7)),
        review: ReviewItem(
          bookingId: 'HOMS17490001',
          rating: 5,
          text: 'Kerja rapi dan tepat waktu, sangat memuaskan!',
          createdAt: now.subtract(const Duration(days: 6)),
          workerReply: 'Terima kasih banyak atas kepercayaannya!',
        ),
      ),
      Booking(
        id: 'HOMS17490002',
        workerId: 'W1',
        workerName: 'Budi Santoso',
        categoryName: 'Tukang Listrik',
        customerName: 'Rani Permatasari',
        scheduledDate: now.subtract(const Duration(days: 2)),
        scheduledTime: const TimeOfDay(hour: 14, minute: 0),
        status: BookingStatus.cancelled,
        serviceFee: 45,
        adminFee: 5,
        createdAt: now.subtract(const Duration(days: 2, hours: 1)),
        note: 'Perbaikan instalasi lampu ruang tamu.',
      ),
      Booking(
        id: 'HOMS17490003',
        workerId: 'W3',
        workerName: 'Agus Wijaya',
        categoryName: 'Tukang Ledeng',
        customerName: 'Rani Permatasari',
        scheduledDate: now,
        scheduledTime: const TimeOfDay(hour: 16, minute: 0),
        status: BookingStatus.ongoing,
        serviceFee: 40,
        adminFee: 4,
        isPaid: true,
        paymentMethod: 'Virtual Account BCA',
        createdAt: now.subtract(const Duration(hours: 3)),
        note: 'Keran wastafel dapur bocor.',
      ),
    ];
  }

  static List<AppNotification> notifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'N1',
        title: 'Pesanan Dikonfirmasi',
        body: 'Agus Wijaya menerima pesanan Anda (HOMS17490003).',
        time: now.subtract(const Duration(hours: 3)),
        type: NotificationType.pesanan,
        targetRole: UserRole.customer,
      ),
      AppNotification(
        id: 'N2',
        title: 'Pembayaran Berhasil',
        body:
            'Pembayaran untuk pesanan HOMS17490003 telah diterima & ditahan (escrow).',
        time: now.subtract(const Duration(hours: 2, minutes: 50)),
        type: NotificationType.pembayaran,
        targetRole: UserRole.customer,
      ),
      AppNotification(
        id: 'N3',
        title: 'Promo Spesial',
        body: 'Diskon 20% untuk jasa Cleaning Service khusus minggu ini!',
        time: now.subtract(const Duration(days: 1)),
        type: NotificationType.promo,
        targetRole: UserRole.customer,
        isRead: true,
      ),
      AppNotification(
        id: 'N4',
        title: 'Pesanan Baru Masuk',
        body:
            'Anda mendapat pesanan baru dari Rani Permatasari. Segera respon dalam 30 menit.',
        time: now.subtract(const Duration(hours: 3, minutes: 5)),
        type: NotificationType.pesanan,
        targetRole: UserRole.worker,
      ),
      AppNotification(
        id: 'N5',
        title: 'Verifikasi Diproses',
        body: 'Dokumen KTP Anda sedang ditinjau oleh admin (maks. 1x24 jam).',
        time: now.subtract(const Duration(days: 1, hours: 4)),
        type: NotificationType.sistem,
        targetRole: UserRole.worker,
        isRead: true,
      ),
    ];
  }

  /// Kata yang difilter otomatis dari ulasan (REQ-7.2, disederhanakan).
  static const List<String> kataTerlarang = [
    'anjing',
    'bangsat',
    'goblok',
    'bodoh',
    'kontol',
    'tolol',
  ];
}
