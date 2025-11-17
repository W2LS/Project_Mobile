import 'dart:async'; // <-- Diperlukan untuk Timer
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Menggunakan warna primer yang sudah ada di aplikasi Anda
const Color primaryColor = Color(0xFF42A5F5);

// --- MODIFIKASI: Diubah ke StatefulWidget ---
class QrisPaymentScreen extends StatefulWidget {
  // Kita menerima nominal dari halaman sebelumnya
  final String amount;

  const QrisPaymentScreen({super.key, required this.amount});

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  Timer? _timer;
  String _paymentStatus = "PENDING";
  int _checkCount = 0; // Untuk simulasi

  @override
  void initState() {
    super.initState();
    // Memulai timer untuk mengecek status
    _startPaymentCheck();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Pastikan timer berhenti saat halaman ditutup
    super.dispose();
  }

  // Fungsi untuk memulai timer polling
  void _startPaymentCheck() {
    // Kita akan mengecek status setiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkPaymentStatus();
    });
  }

  // Fungsi untuk mengecek status pembayaran
  Future<void> _checkPaymentStatus() async {
    print("Mengecek status pembayaran... (Cek ke-${_checkCount + 1})");

    // --- INI HANYA SIMULASI ---
    // Di aplikasi nyata, Anda akan memanggil server Anda di sini, misalnya:
    // String status = await ApiService.getStatusPembayaran(idTransaksi);

    // Kita akan simulasikan pembayaran berhasil setelah 15 detik (cek ke-3)
    _checkCount++;
    if (_checkCount >= 3) {
      _paymentStatus = "PAID";
    }
    // --- BATAS SIMULASI ---

    // Jika status sudah "PAID" (Lunas)
    if (_paymentStatus == "PAID") {
      _timer?.cancel(); // Hentikan timer

      // Tampilkan halaman sukses
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PaymentSuccessScreen(),
        ),
      );
    } else {
      // Jika masih "PENDING", biarkan timer berjalan
      setState(() {
        // (Kita bisa update UI jika perlu, tapi untuk sekarang biarkan saja)
      });
    }
  }

  // Fungsi untuk format mata uang
  String _formatRupiah(String amount) {
    final number = double.tryParse(amount) ?? 0.0;
    final format =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(number);
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
                        "Pembayaran QRIS",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Konten (QR Code & Instruksi)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            "Scan untuk Membayar",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          // Nominal yang harus dibayar
                          Text(
                            _formatRupiah(widget.amount), // <-- Menggunakan widget.amount
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
                          ),
                          const SizedBox(height: 24),

                          // Ini adalah gambar QRIS Palsu (placeholder)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.network(
                              "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=ContohPembayaranDynamicSehargaRp${widget.amount}",
                              width: 250,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Instruksi
                          const Text(
                            "Instruksi:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "1. Buka aplikasi E-Wallet Anda (GoPay, OVO, DANA, ShopeePay, dll.) atau Mobile Banking.\n"
                                "2. Pilih menu \"Scan\" atau \"Bayar\".\n"
                                "3. Arahkan kamera ke kode QR di atas.\n"
                                "4. Pastikan nominal pembayaran sudah sesuai.\n"
                                "5. Masukkan PIN Anda untuk konfirmasi.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                          ),
                        ],
                      ),
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


// --- HALAMAN BARU UNTUK TAMPILAN SUKSES ---
// (Diletakkan di file yang sama agar mudah)

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              "Pembayaran Berhasil!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Saldo Anda akan segera diperbarui.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Kembali ke halaman paling awal (home)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text("Kembali ke Home"),
            )
          ],
        ),
      ),
    );
  }
}