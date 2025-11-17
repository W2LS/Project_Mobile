import 'dart:async'; // <-- Diperlukan untuk Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'confirmation_upload_screen.dart'; // <-- IMPORT HALAMAN BARU

// Menggunakan warna primer yang sudah ada di aplikasi Anda
const Color primaryColor = Color(0xFF42A5F5);

// --- MODIFIKASI: Diubah ke StatefulWidget ---
class PaymentInstructionScreen extends StatefulWidget {
  // Kita menerima data dari halaman virtual_account_screen
  final String bankName; // Bank tujuan (milik owner)
  final String logoUrl;
  final String amount;

  // --- TAMBAHAN: Detail Rekening Owner (Hardcoded) ---
  // Ganti ini dengan data rekening Anda yang sebenarnya
  final String ownerAccountNumber = "1234567890";
  final String ownerAccountName = "Nama Pemilik Aplikasi";
  // --- BATAS TAMBAHAN ---

  const PaymentInstructionScreen({
    super.key,
    required this.bankName,
    required this.logoUrl,
    required this.amount,
  });

  @override
  State<PaymentInstructionScreen> createState() =>
      _PaymentInstructionScreenState();
}

class _PaymentInstructionScreenState extends State<PaymentInstructionScreen> {
  Timer? _timer;
  int _remainingSeconds = 600; // 10 menit * 60 detik

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Pastikan timer berhenti saat halaman ditutup
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        // Waktu habis, kembali ke halaman isi saldo
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Waktu pembayaran habis. Silakan ulangi."),
            backgroundColor: Colors.red,
          ),
        );
        // Kembali 2x (pop halaman instruksi & halaman pilih bank)
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      }
    });
  }

  // Format waktu MM:SS
  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$remainingSeconds";
  }


  // Fungsi untuk format mata uang
  String _formatRupiah(String amount) {
    final number = double.tryParse(amount) ?? 0.0;
    final format =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(number);
  }

  // Fungsi untuk menyalin teks ke clipboard
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Teks disalin: $text"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          // Latar belakang biru melengkung
          Container(
            height: 100, // Tinggi header
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
          ),

          // Konten halaman
          SafeArea(
            child: Column(
              children: [
                // AppBar Manual (Tombol Back & Judul)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                        const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Instruksi Pembayaran",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Konten (Detail Pembayaran)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Logo & Judul Bank
                        Center(
                          child: Column(
                            children: [
                              Image.network(widget.logoUrl, height: 40, fit: BoxFit.contain),
                              const SizedBox(height: 8),
                              Text(
                                "Transfer ke ${widget.bankName}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              // Chip diganti dengan timer
                            ],
                          ),
                        ),
                        const Divider(height: 32),

                        // --- MODIFIKASI: Tampilkan Rekening Owner ---
                        const Text(
                          "Nomor Rekening Tujuan",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.ownerAccountNumber, // <-- Nomor Rek Owner
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text("Salin"),
                              onPressed: () => _copyToClipboard(
                                  context, widget.ownerAccountNumber),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: primaryColor),
                                foregroundColor: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "a/n ${widget.ownerAccountName}", // <-- Nama Owner
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        // --- BATAS MODIFIKASI ---
                        const SizedBox(height: 20),

                        // 3. Nominal Pembayaran
                        const Text(
                          "Total Pembayaran",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatRupiah(widget.amount),
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor),
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text("Salin"),
                              onPressed: () =>
                                  _copyToClipboard(context, widget.amount),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: primaryColor),
                                foregroundColor: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 4. Batas Waktu dengan Timer
                        Card(
                          color: Colors.amber.shade50,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const Icon(Icons.timer, color: Colors.orange),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Selesaikan pembayaran sebelum ${_formatDuration(_remainingSeconds)}", // <-- Tampilkan timer
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 5. Petunjuk Umum
                        const Text(
                          "Petunjuk Umum Transfer",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "1. Lakukan transfer ke nomor rekening tujuan di atas.\n"
                              "2. Pastikan nominal transfer sesuai dengan total pembayaran.\n"
                              "3. Simpan bukti transfer Anda.\n"
                              "4. Setelah transfer berhasil, klik tombol \"Konfirmasi Pembayaran\" di bawah.",
                          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                        ),

                        const SizedBox(height: 32),

                        // --- MODIFIKASI: Tombol Konfirmasi ---
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              _timer?.cancel(); // Hentikan timer saat konfirmasi
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConfirmationUploadScreen(
                                    amount: widget.amount,
                                    bankName: widget.bankName,
                                    accountNumber: widget.ownerAccountNumber,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Konfirmasi Pembayaran", // <-- Ganti teks
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        // --- BATAS MODIFIKASI ---
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}