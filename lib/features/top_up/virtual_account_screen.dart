import 'package:flutter/material.dart';
import 'payment_instruction_screen.dart'; // <-- Pastikan ini sudah diimpor

// Menggunakan warna primer yang sudah ada di aplikasi Anda
const Color primaryColor = Color(0xFF42A5F5);

class VirtualAccountScreen extends StatelessWidget {
  // Kita menerima nominal dari halaman sebelumnya
  final String amount;

  const VirtualAccountScreen({super.key, required this.amount});

  // Fungsi helper untuk membuat baris bank
  Widget _buildBankTile({
    required BuildContext context,
    required String logoUrl,
    required String title,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Image.network(
          logoUrl,
          width: 50,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
          },
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // --- INI ADALAH BAGIAN YANG DIPERBARUI ---
          // Aksi ketika bank dipilih:
          // Navigasi ke halaman instruksi pembayaran manual
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentInstructionScreen(
                bankName: title, // Nama bank tujuan transfer (milik owner)
                logoUrl: logoUrl, // Logo bank tujuan transfer (milik owner)
                amount: amount,
                // ownerAccountNumber & ownerAccountName akan diambil dari
                // konstanta di dalam PaymentInstructionScreen
              ),
            ),
          );
          // --- BATAS PERUBAHAN ---
        },
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      // Judul diubah sedikit agar sesuai konsep
                      const Text(
                        "Pilih Bank Tujuan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Konten (List Bank)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul diubah sedikit agar sesuai konsep
                        const Text(
                          "Pilih Bank Tujuan Transfer",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Link gambar yang sudah diperbarui
                        _buildBankTile(
                          context: context,
                          logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Bank_Central_Asia_logo.svg/2560px-Bank_Central_Asia_logo.svg.png", // Logo BCA
                          title: "Bank BCA",
                        ),
                        _buildBankTile(
                          context: context,
                          logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/BANK_BRI_logo.svg/2560px-BANK_BRI_logo.svg.png", // Logo BRI
                          title: "Bank BRI",
                        ),
                        _buildBankTile(
                          context: context,
                          logoUrl: "https://upload.wikimedia.org/wikipedia/id/thumb/5/55/BNI_logo.svg/1280px-BNI_logo.svg.png", // Logo BNI
                          title: "Bank BNI",
                        ),
                        _buildBankTile(
                          context: context,
                          logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Bank_Mandiri_logo_2016.svg/2560px-Bank_Mandiri_logo_2016.svg.png", // Logo Mandiri
                          title: "Bank Mandiri",
                        ),
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