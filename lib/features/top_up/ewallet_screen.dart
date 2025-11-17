import 'package:flutter/material.dart';
import 'ewallet_confirmation_screen.dart'; // <-- IMPORT HALAMAN BARU

// Menggunakan warna primer yang sudah ada di aplikasi Anda
const Color primaryColor = Color(0xFF42A5F5);

class EwalletScreen extends StatelessWidget {
  // Kita menerima nominal dari halaman sebelumnya
  final String amount;

  const EwalletScreen({super.key, required this.amount});

  // --- MODIFIKASI DIMULAI DI SINI ---
  // Fungsi helper untuk membuat baris e-wallet
  Widget _buildEwalletTile({
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
          width: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Tampilkan placeholder jika logo gagal dimuat
            return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
          },
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Aksi ketika e-wallet dipilih:
          // Navigasi ke halaman konfirmasi
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EwalletConfirmationScreen(
                ewalletName: title,
                logoUrl: logoUrl,
                amount: amount,
              ),
            ),
          );
        },
      ),
    );
  }
  // --- BATAS MODIFIKASI ---

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
                        "Pilih E-Wallet",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Konten (List E-Wallet)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pilih E-Wallet Tujuan",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // --- LINK LOGO DIPERBARUI ---
                        _buildEwalletTile(
                          context: context,
                          logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Gopay_logo.svg/2560px-Gopay_logo.svg.png", // Logo GoPay
                          title: "GoPay",
                        ),
                        _buildEwalletTile(
                          context: context,
                          logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/OVO_logo.svg/1280px-OVO_logo.svg.png", // Logo OVO
                          title: "OVO",
                        ),
                        _buildEwalletTile(
                          context: context,
                          logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Logo_dana_blue.svg/2560px-Logo_dana_blue.svg.png", // Logo DANA
                          title: "DANA",
                        ),
                        _buildEwalletTile(
                          context: context,
                          logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/ShopeePay_logo.svg/1280px-ShopeePay_logo.svg.png", // Logo ShopeePay
                          title: "ShopeePay",
                        ),
                        // --- BATAS PERUBAHAN ---
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