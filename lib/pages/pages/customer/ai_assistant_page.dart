import 'package:flutter/material.dart';

/// Data model for chat messages in AI Assistant session.
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Knowledge base used for keyword matching responses.
final Map<String, String> aiKnowledgeBase = {
  "pesan":
      "Untuk memesan layanan, silakan kembali ke halaman utama (Home), pilih kategori layanan rumah tangga yang Anda butuhkan, lalu pilih pekerja yang tersedia di jadwal Anda.",
  "bayar":
      "Pembayaran dapat dilakukan setelah pekerja menyelesaikan pekerjaannya. Anda bisa melakukan pembayaran melalui transfer bank, e-wallet, atau tunai sesuai kesepakatan.",
  "batal":
      "Anda dapat membatalkan pesanan maksimal 2 jam sebelum jadwal layanan dimulai. Masuk ke tab 'Orders', pilih pesanan Anda, lalu tekan tombol 'Batalkan Pesanan'.",
  "pekerja":
      "Semua pekerja di Home Asis telah melewati proses verifikasi identitas (KTP) dan pengecekan latar belakang untuk memastikan keamanan dan kenyamanan Anda.",
  "komplain":
      "Jika hasil kerja kurang memuaskan, Anda dapat memberikan rating dan ulasan setelah layanan selesai, atau melaporkan pekerja tersebut melalui halaman detail pesanan di tab 'History'.",
  "jadwal":
      "Anda bebas menentukan jadwal kedatangan pekerja. Saat membuat pesanan, sistem akan menampilkan pekerja mana saja yang *available* di tanggal dan jam yang Anda pilih.",
  "halo":
      "Halo! Saya Asisten Home Asis. Ada yang bisa saya bantu terkait pencarian pekerja, pemesanan layanan, atau kendala lainnya?",
  "terima kasih":
      "Sama-sama! Jangan ragu untuk bertanya lagi jika Anda butuh bantuan. Semoga hari Anda menyenangkan!"
};

/// UI Page for AI Support Assistant Chat Interface.
class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Halo! Saya Asisten Home Asis. Silakan tanyakan hal seputar pemesanan, pembayaran, jadwal, atau kendala layanan Anda.",
      isUser: false,
    ),
  ];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _findResponse(String query) {
    final lowerQuery = query.toLowerCase();
    for (final entry in aiKnowledgeBase.entries) {
      if (lowerQuery.contains(entry.key)) {
        return entry.value;
      }
    }
    return "Maaf, saya kurang mengerti. Bisa jelaskan lebih spesifik mengenai layanan Home Asis yang Anda butuhkan?";
  }

  Future<void> _handleSendMessage() async {
    final input = _textController.text.trim();
    if (input.isEmpty || _isTyping) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(text: input, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final responseText = _findResponse(input);
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: responseText, isUser: false));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: scheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Asisten Home Asis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _isTyping ? 'Mengetik balasan...' : 'Online • Siap membantu',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isTyping ? scheme.primary : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return const _TypingIndicatorBubble();
                  }
                  return _MessageBubble(message: _messages[index]);
                },
              ),
            ),
            _buildInputArea(scheme),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Tanyakan sesuatu tentang Home Asis...',
                hintStyle:
                    TextStyle(fontSize: 13, color: Colors.grey.shade500),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: scheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _handleSendMessage,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? scheme.primary : const Color(0xFFEFEFF4),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 13.5,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicatorBubble extends StatelessWidget {
  const _TypingIndicatorBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFEFEFF4),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Sedang mengetik...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
