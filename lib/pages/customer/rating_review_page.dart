import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';

// =======================================================================
// HOME_ASIS - Rating & Ulasan
// -----------------------------------------------------------------------
// SRS 4.7 "Rating dan Review": REQ-7.1 (hanya untuk pesanan Selesai),
// REQ-7.2 (filter kata kasar), BIZ-7.1 (tidak dapat diubah/dihapus setelah
// dikirim).
// =======================================================================
class RatingReviewPage extends StatefulWidget {
  final String bookingId;
  const RatingReviewPage({super.key, required this.bookingId});

  @override
  State<RatingReviewPage> createState() => _RatingReviewPageState();
}

class _RatingReviewPageState extends State<RatingReviewPage> {
  int _rating = 5;
  final _ulasanController = TextEditingController();

  @override
  void dispose() {
    _ulasanController.dispose();
    super.dispose();
  }

  void _kirim(BuildContext context) {
    final appState = context.read<AppState>();
    if (_ulasanController.text.trim().isEmpty) {
      showAppSnackBar(context, 'Tulis ulasan singkat sebelum mengirim.',
          error: true);
      return;
    }
    if (appState.mengandungKataTerlarang(_ulasanController.text)) {
      showAppSnackBar(
          context, 'Ulasan mengandung kata tidak pantas. Mohon perbaiki.',
          error: true);
      return;
    }
    appState.submitReview(
        widget.bookingId, _rating, _ulasanController.text.trim());
    showAppSnackBar(context, 'Terima kasih atas ulasan Anda!');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final booking = appState.findBooking(widget.bookingId);
    if (booking == null) {
      return Scaffold(
          appBar: simpleAppBar('Rating & Ulasan'),
          body: const Center(child: Text('Pesanan tidak ditemukan.')));
    }

    if (booking.review != null) {
      return Scaffold(
        appBar: simpleAppBar('Rating & Ulasan'),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32), size: 56),
              const SizedBox(height: 16),
              const Text('Ulasan sudah dikirim',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                'Rating dan ulasan tidak dapat diubah setelah dikirim (BIZ-7.1).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              RatingStars(rating: booking.review!.rating.toDouble(), size: 22),
              const SizedBox(height: 10),
              Text('"${booking.review!.text}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: simpleAppBar('Beri Rating & Ulasan'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Bagaimana layanan dari ${booking.workerName}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(booking.categoryName,
                  style:
                      TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              RatingInputStars(
                  value: _rating,
                  onChanged: (v) => setState(() => _rating = v)),
              const SizedBox(height: 4),
              Text(_labelRating(_rating),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              TextField(
                controller: _ulasanController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Tulis ulasan Anda',
                  hintText:
                      'Ceritakan pengalaman Anda menggunakan layanan ini...',
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                  label: 'Kirim Ulasan',
                  icon: Icons.send_rounded,
                  onPressed: () => _kirim(context)),
            ],
          ),
        ),
      ),
    );
  }

  String _labelRating(int rating) {
    switch (rating) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Buruk';
      case 3:
        return 'Cukup';
      case 4:
        return 'Baik';
      default:
        return 'Sangat Baik';
    }
  }
}
