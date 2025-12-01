import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';

// 🔥 KOREKSI PATH IMPOR AKHIR BERDASARKAN STRUKTUR FOLDER
// Path disesuaikan: naik dua level (../../) untuk keluar dari features/account,
// lalu masuk ke folder 'location'.

// 1. Live Location (Eksplorasi)
import '../../../location/views/location_view.dart';
import '../../../location/bindings/location_binding.dart';

// 2. GPS Location (Lokasi Cabang Toko)
import '../../../location/views/gps_location_view.dart';
import '../../../location/bindings/gps_location_binding.dart';

// 3. Network Location (Alamat Saya)
import '../../../location/views/network_location_view.dart';
import '../../../location/bindings/network_location_binding.dart';
// ----------------------------------------------------


const Color primaryColor = Color(0xFF42A5F5);
const Color screenBackgroundColor = Color(0xFFF0F8FF);

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Widget _buildAccountListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontSize: 16, color: color)),
      trailing: Icon(Icons.chevron_right, color: color),
      onTap: onTap ?? () {
        Get.snackbar(
            "Halaman Belum Ada",
            'Halaman $title belum dibuat.',
            snackPosition: SnackPosition.BOTTOM
        );
      },
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStatsColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    const double headerHeight = 280;
    const double cardOverlap = 40;
    const double cardHeight = 110;
    const double spaceBelowCard = 16.0;

    final double cardTopPosition = headerHeight - cardOverlap;

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: Stack(
        children: [
          // --- LAPISAN BAWAH: Konten Scrollable ---
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: cardTopPosition + cardHeight + spaceBelowCard,
              bottom: 30,
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card( // Card Menu Utama
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // --- Menu Biasa ---
                      _buildAccountListTile(context: context, icon: Icons.person_outline, title: "Informasi Akun", color: Colors.grey.shade600),
                      Divider(height: 1, indent: 16, endIndent: 16),

                      // ✅ 1. NAVIGASI ALAMAT SAYA (Menggunakan Network Location - Cepat)
                      _buildAccountListTile(
                          context: context,
                          icon: Icons.location_on_outlined,
                          title: "Alamat Saya (Net)",
                          color: Colors.grey.shade600,
                          onTap: () {
                            // 🔥 Navigasi ke Network Location View
                            Get.to(
                                  () => const NetworkLocationView(),
                              binding: NetworkLocationBinding(),
                            );
                          }
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),

                      // ✅ 2. NAVIGASI LOKASI CABANG TOKO (Menggunakan GPS Location - Akurat)
                      _buildAccountListTile(
                          context: context,
                          icon: Icons.storefront,
                          title: "Lokasi Cabang Toko (GPS)",
                          color: primaryColor,
                          onTap: () {
                            // 🔥 Navigasi ke GPS Location View
                            Get.to(
                                  () => const GpsLocationView(),
                              binding: GpsLocationBinding(),
                            );
                          }
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),

                      _buildAccountListTile(context: context, icon: Icons.favorite_border, title: "Favorit Saya", color: Colors.grey.shade600),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(context: context, icon: Icons.chat_bubble_outline, title: "Diskusi Barang", color: Colors.grey.shade600),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(context: context, icon: Icons.list_alt_outlined, title: "Daftar Antrian Transaksi", color: Colors.grey.shade600),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(
                          context: context,
                          icon: Icons.account_balance_wallet_outlined,
                          title: "Riwayat Saldo & TopUp",
                          color: Colors.grey.shade600,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(title: Text("Riwayat Saldo")), body: Center(child: Text("Halaman Riwayat Saldo")))));
                          }
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(context: context, icon: Icons.rate_review_outlined, title: "Testimoni Luminae", color: Colors.grey.shade600),
                      Divider(height: 1, indent: 16, endIndent: 16),

                      // ✅ 3. NAVIGASI EKSPLORASI AKURASI LOKASI (Menggunakan Live Location - Modul 5)
                      _buildAccountListTile(
                          context: context,
                          icon: Icons.alt_route,
                          title: "Eksplorasi Akurasi Lokasi (Modul 5)",
                          color: Colors.red.shade700,
                          onTap: () {
                            // 🔥 Navigasi ke Live Location View (dengan toggle GPS/Net)
                            Get.to(
                                  () => const LocationView(),
                              binding: LocationBinding(),
                            );
                          }
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),

                      _buildAccountListTile(context: context, icon: Icons.info_outline, title: "About", color: Colors.grey.shade600),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildAccountListTile(context: context, icon: Icons.settings_outlined, title: "Pengaturan", color: Colors.grey.shade600),
                      Divider(height: 1, indent: 16, endIndent: 16),

                      // Tombol Log Out
                      _buildAccountListTile(
                        context: context,
                        icon: Icons.logout,
                        title: "Logout Akun",
                        color: Colors.red.shade700,
                        onTap: () {
                          authController.logout();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),

          // --- LAPISAN TENGAH: Header Biru (Tetap Sama) ---
          Container(
            width: double.infinity,
            height: headerHeight,
            padding: const EdgeInsets.only(top: 50, bottom: 40),
            decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  )
                ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: Text(
                    "D",
                    style: TextStyle(fontSize: 35, color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "CS Dicky",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),

          // --- LAPISAN ATAS: Card Statistik (Tetap Sama) ---
          Positioned(
            top: cardTopPosition,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatsColumn("Invoice", "0"),
                    _buildStatsColumn("Dikirim", "2"),
                    _buildStatsColumn("Sukses", "136"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}