import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

// =======================================================================
// HOME_ASIS - AppState (Sumber Kebenaran Data Dummy)
// -----------------------------------------------------------------------
// Kelas ini berperan sebagai pengganti sederhana dari "Backend Server"
// pada SRS (lihat Gambar 2.1 Diagram Blok Arsitektur). Karena tugas ini
// berupa prototipe UI, seluruh state (pengguna aktif, daftar pesanan,
// notifikasi, dsb.) disimpan di memori memakai ChangeNotifier dari
// package provider, BUKAN memakai REST API/PostgreSQL/JWT sungguhan.
//
// Setiap method publik di bawah ini merepresentasikan satu use case dari
// Bab 4 SRS (ditandai dengan komentar REQ/BIZ/SAFE terkait) sehingga
// mudah ditelusuri (traceability) ke dokumen SRS.
// =======================================================================
class AppState extends ChangeNotifier {
  AppState() {
    categories = MockData.categories();
    workers = MockData.workers();
    bookings = MockData.bookings();
    notifications = MockData.notifications();
    customerAccounts = MockData.customers();
  }

  // ------------------------- Sesi Pengguna Aktif -------------------------
  UserRole? currentRole;
  String currentUserName = 'Pengguna';
  String currentWorkerId = 'W1'; // worker "aku" saat login sebagai pekerja

  bool get isLoggedIn => currentRole != null;

  // ------------------------------ Data Dummy ------------------------------
  late List<ServiceCategory> categories;
  late List<WorkerProfile> workers;
  late List<Booking> bookings;
  late List<AppNotification> notifications;
  late List<CustomerAccount> customerAccounts;

  // ------------------------------- REQ-1 -----------------------------------
  void login(UserRole role, {String? name, String? workerId}) {
    currentRole = role;
    currentUserName =
        name?.trim().isNotEmpty == true ? name!.trim() : currentUserName;
    if (role == UserRole.worker) {
      currentWorkerId = workerId ?? workers.first.id;
      currentUserName = findWorker(currentWorkerId)?.name ?? currentUserName;
    } else if (role == UserRole.customer) {
      currentUserName =
          currentUserName == 'Pengguna' ? 'Rani Permatasari' : currentUserName;
    } else {
      currentUserName =
          currentUserName == 'Pengguna' ? 'Admin Home_Asis' : currentUserName;
    }
    notifyListeners();
  }

  void logout() {
    currentRole = null;
    notifyListeners();
  }

  /// REQ-1.2 / UI-1.2: registrasi pekerja baru dengan kategori keahlian.
  WorkerProfile registerWorker({
    required String name,
    required String phone,
    required String categoryId,
    required int tarifPerJam,
  }) {
    final kategori = categories.firstWhere((c) => c.id == categoryId,
        orElse: () => categories.first);
    final initials = name.trim().isEmpty
        ? 'MP'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();
    final worker = WorkerProfile(
      id: 'W${workers.length + 1}${DateTime.now().millisecondsSinceEpoch % 1000}',
      name: name,
      initials: initials,
      avatarColor: Colors.primaries[workers.length % Colors.primaries.length],
      categoryId: kategori.id,
      categoryName: kategori.name,
      phone: phone,
      bio: 'Mitra pekerja baru Home_Asis.',
      rating: 0,
      reviewCount: 0,
      distanceKm: 1.0,
      pricePerHour: tarifPerJam,
      verificationStatus: VerificationStatus.unverified,
    );
    workers.add(worker);
    currentWorkerId = worker.id;
    notifyListeners();
    return worker;
  }

  WorkerProfile? findWorker(String id) {
    try {
      return workers.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  WorkerProfile get currentWorker =>
      findWorker(currentWorkerId) ?? workers.first;

  // ----------------------------- REQ-3: Pencarian ---------------------------
  /// Daftar pekerja yang tampil di pencarian pelanggan: harus terverifikasi
  /// (BIZ-2.1), tidak diblokir, dan bisa difilter berdasarkan kategori.
  List<WorkerProfile> searchableWorkers(
      {String? categoryId, String query = ''}) {
    final q = query.trim().toLowerCase();
    return workers.where((w) {
      final cocokVerifikasi =
          w.verificationStatus == VerificationStatus.verified && !w.isBlocked;
      final cocokKategori = categoryId == null || w.categoryId == categoryId;
      final cocokQuery = q.isEmpty ||
          w.name.toLowerCase().contains(q) ||
          w.categoryName.toLowerCase().contains(q);
      return cocokVerifikasi && cocokKategori && cocokQuery;
    }).toList()
      ..sort((a, b) => b.skorRekomendasi.compareTo(a.skorRekomendasi));
  }

  // ----------------------------- REQ-4: Pemesanan ---------------------------
  /// Mengecek slot waktu bentrok (REQ-5.1: mencegah double-booking).
  bool isSlotBentrok(String workerId, DateTime date, TimeOfDay time) {
    return bookings.any((b) =>
        b.workerId == workerId &&
        b.status != BookingStatus.cancelled &&
        b.scheduledDate.year == date.year &&
        b.scheduledDate.month == date.month &&
        b.scheduledDate.day == date.day &&
        b.scheduledTime.hour == time.hour &&
        b.scheduledTime.minute == time.minute);
  }

  Booking createBooking({
    required WorkerProfile worker,
    required DateTime date,
    required TimeOfDay time,
    String note = '',
  }) {
    final adminFee = (worker.pricePerHour * 0.1).round();
    final booking = Booking(
      id: 'HOMS${DateTime.now().millisecondsSinceEpoch}',
      workerId: worker.id,
      workerName: worker.name,
      categoryName: worker.categoryName,
      customerName: currentUserName,
      scheduledDate: date,
      scheduledTime: time,
      status: BookingStatus.pending,
      serviceFee: worker.pricePerHour,
      adminFee: adminFee,
      note: note,
      createdAt: DateTime.now(),
      respondDeadline:
          DateTime.now().add(const Duration(minutes: 30)), // BIZ-4.1
    );
    bookings.insert(0, booking);
    _tambahNotifikasi(
      title: 'Pesanan Terkirim',
      body: 'Menunggu konfirmasi dari ${worker.name} (maks. 30 menit).',
      type: NotificationType.pesanan,
      role: UserRole.customer,
    );
    _tambahNotifikasi(
      title: 'Pesanan Baru Masuk',
      body:
          '$currentUserName memesan jasa ${worker.categoryName}. Segera respon!',
      type: NotificationType.pesanan,
      role: UserRole.worker,
    );
    notifyListeners();
    return booking;
  }

  Booking? findBooking(String id) {
    try {
      return bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// BIZ-4.1: pekerja menerima/menolak pesanan dalam 30 menit.
  void respondBooking(String bookingId, bool accept) {
    final b = findBooking(bookingId);
    if (b == null) return;
    b.status = accept ? BookingStatus.accepted : BookingStatus.cancelled;
    _tambahNotifikasi(
      title: accept ? 'Pesanan Diterima' : 'Pesanan Ditolak',
      body: accept
          ? '${b.workerName} menerima pesanan Anda. Lanjutkan ke pembayaran.'
          : '${b.workerName} tidak dapat memenuhi pesanan Anda.',
      type: NotificationType.pesanan,
      role: UserRole.customer,
    );
    notifyListeners();
  }

  /// BIZ-4.2 / BR-3: pembatalan oleh pelanggan.
  void cancelBooking(String bookingId) {
    final b = findBooking(bookingId);
    if (b == null) return;
    b.status = BookingStatus.cancelled;
    notifyListeners();
  }

  // ----------------------------- REQ-6: Pembayaran --------------------------
  void payBooking(String bookingId, String method) {
    final b = findBooking(bookingId);
    if (b == null) return;
    b.isPaid = true;
    b.paymentMethod = method;
    b.status = BookingStatus.ongoing; // dana ditahan (escrow) - REQ-6.2
    _tambahNotifikasi(
      title: 'Pembayaran Berhasil',
      body: 'Dana ditahan sistem (escrow) hingga layanan selesai.',
      type: NotificationType.pembayaran,
      role: UserRole.customer,
    );
    _tambahNotifikasi(
      title: 'Pembayaran Diterima',
      body: 'Pelanggan telah membayar pesanan ${b.id}. Silakan mulai bekerja.',
      type: NotificationType.pembayaran,
      role: UserRole.worker,
    );
    notifyListeners();
  }

  /// Pekerja mengklaim pekerjaan selesai (memicu konfirmasi pelanggan).
  void workerClaimDone(String bookingId) {
    final b = findBooking(bookingId);
    if (b == null) return;
    b.workerClaimedDone = true;
    _tambahNotifikasi(
      title: 'Konfirmasi Layanan Selesai',
      body: '${b.workerName} menandai pekerjaan selesai. Mohon konfirmasi.',
      type: NotificationType.pesanan,
      role: UserRole.customer,
    );
    notifyListeners();
  }

  void confirmBookingComplete(String bookingId) {
    final b = findBooking(bookingId);
    if (b == null) return;
    b.status = BookingStatus.completed;
    notifyListeners();
  }

  // ----------------------------- REQ-7: Rating & Ulasan ----------------------
  bool mengandungKataTerlarang(String text) {
    final lower = text.toLowerCase();
    return MockData.kataTerlarang.any((kata) => lower.contains(kata));
  }

  void submitReview(String bookingId, int rating, String text) {
    final b = findBooking(bookingId);
    if (b == null || b.review != null) return; // BIZ-7.1: tidak bisa diubah
    b.review = ReviewItem(
        bookingId: bookingId,
        rating: rating,
        text: text,
        createdAt: DateTime.now());
    final worker = findWorker(b.workerId);
    if (worker != null) {
      final total = (worker.rating * worker.reviewCount) + rating;
      worker.reviewCount += 1;
      worker.rating = total / worker.reviewCount;
    }
    notifyListeners();
  }

  List<Booking> bookingsWithReviewFor(String workerId) => bookings
      .where((b) => b.workerId == workerId && b.review != null)
      .toList();

  // ----------------------------- REQ-8: Notifikasi ---------------------------
  void _tambahNotifikasi({
    required String title,
    required String body,
    required NotificationType type,
    required UserRole role,
  }) {
    notifications.insert(
      0,
      AppNotification(
        id: 'N${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        body: body,
        time: DateTime.now(),
        type: type,
        targetRole: role,
      ),
    );
  }

  List<AppNotification> notificationsForCurrentRole() =>
      notifications.where((n) => n.targetRole == currentRole).toList();

  void markNotificationRead(String id) {
    final n = notifications.firstWhere((n) => n.id == id);
    n.isRead = true;
    notifyListeners();
  }

  // ----------------------------- REQ-2: Verifikasi KTP -----------------------
  void submitKtpForVerification(String workerId,
      {required String nik,
      required String namaOcr,
      required double confidence}) {
    final w = findWorker(workerId);
    if (w == null) return;
    w.nik = nik;
    w.ktpNamaOcr = namaOcr;
    w.ocrConfidence = confidence;
    w.verificationStatus =
        VerificationStatus.pending; // BIZ-2.2: diproses maks 1x24 jam
    notifyListeners();
  }

  List<WorkerProfile> get verificationQueue => workers
      .where((w) => w.verificationStatus == VerificationStatus.pending)
      .toList();

  void approveVerification(String workerId) {
    final w = findWorker(workerId);
    if (w == null) return;
    w.verificationStatus = VerificationStatus.verified;
    _tambahNotifikasi(
      title: 'Verifikasi Disetujui',
      body: 'Akun Anda kini berstatus Terverifikasi. Selamat bergabung!',
      type: NotificationType.sistem,
      role: UserRole.worker,
    );
    notifyListeners();
  }

  void rejectVerification(String workerId) {
    final w = findWorker(workerId);
    if (w == null) return;
    w.verificationStatus = VerificationStatus.rejected;
    _tambahNotifikasi(
      title: 'Verifikasi Ditolak',
      body: 'Dokumen KTP tidak dapat diverifikasi. Silakan unggah ulang.',
      type: NotificationType.sistem,
      role: UserRole.worker,
    );
    notifyListeners();
  }

  // ----------------------------- REQ-5: Penjadwalan ---------------------------
  void setJamOperasional(String workerId,
      {required String mulai,
      required String selesai,
      required String istirahatMulai,
      required String istirahatSelesai}) {
    final w = findWorker(workerId);
    if (w == null) return;
    w.jamMulai = mulai;
    w.jamSelesai = selesai;
    w.jamIstirahatMulai = istirahatMulai;
    w.jamIstirahatSelesai = istirahatSelesai;
    notifyListeners();
  }

  void setWorkerAvailability(String workerId, bool available) {
    final w = findWorker(workerId);
    if (w == null) return;
    w.isAvailable = available;
    notifyListeners();
  }

  // ----------------------------- REQ-10: Admin --------------------------------
  void toggleBlockWorker(String workerId) {
    final w = findWorker(workerId);
    if (w == null) return;
    w.isBlocked = !w.isBlocked;
    notifyListeners();
  }

  void toggleBlockCustomer(String customerId) {
    final c = customerAccounts.firstWhere((c) => c.id == customerId);
    c.isBlocked = !c.isBlocked;
    notifyListeners();
  }

  void addCategory(String name, IconData icon) {
    categories.add(ServiceCategory(
        id: 'cat${categories.length + 1}', name: name, icon: icon));
    notifyListeners();
  }

  void renameCategory(String id, String newName) {
    final c = categories.firstWhere((c) => c.id == id);
    final idx = categories.indexOf(c);
    categories[idx] = ServiceCategory(
        id: c.id, name: newName, icon: c.icon, isActive: c.isActive);
    notifyListeners();
  }

  void toggleCategoryActive(String id) {
    final c = categories.firstWhere((c) => c.id == id);
    c.isActive = !c.isActive;
    notifyListeners();
  }

  // ------------------------------ Statistik Admin -----------------------------
  int get totalPendapatanBulanIni => bookings
      .where((b) => b.status == BookingStatus.completed)
      .fold<int>(0, (sum, b) => sum + b.totalFee);

  int get pesananHariIni => bookings.where((b) {
        final now = DateTime.now();
        return b.scheduledDate.year == now.year &&
            b.scheduledDate.month == now.month &&
            b.scheduledDate.day == now.day;
      }).length;

  List<Booking> bookingsForWorker(String workerId) =>
      bookings.where((b) => b.workerId == workerId).toList();
}
